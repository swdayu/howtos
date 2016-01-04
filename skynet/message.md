# Skynet消息

```c
struct message_queue {
  struct spinlock lock;
  uint32_t handle;               //服务的handle，表示该消息队列是哪个服务的消息队列
  int cap;                       //当前消息队列的最大容量
  int head;                      //消息队列头，该索引位置保存着第一个消息
  int tail;                      //消息队列尾，该索引位置用于接收下一个消息
  int release;                   //TODO
  int in_global;                 //TODO
  int overload;                  //TODO
  int overload_threshold;        //TODO
  struct skynet_message* queue;  //保存skynet_messge的消息队列，使用数组表示，当前最大容量为cap
  struct message_queue* next;    //TODO
};

//@[skynet_mq_create]创建一个与服务关联的消息队列
struct message_queue* skynet_mq_create(uint32_t handle) { //传入对应服务的handle
  struct message_queue* q = skynet_malloc(sizeof(*q));    //分配message_queue结构体
  q->handle = handle;                                     //保存所属服务的handle
  q->cap = DEFAULT_QUEUE_SIZE;                            //队列默认最大容量为64
  q->head = 0;                                            //队列头初始为0
  q->tail = 0;                                            //队列尾初始为0，头和尾相等时表示队列空
  SPIN_INIT(q)                                            //初始化spin锁
  //在skynet_context_new函数中，首先调用服务的create函数创建一个服务，再创建该服务的消息队列，
  //然后调用服务的init函数，最后调用skynet_globalmq_push将给服务的消息队列追加到全局队列尾
  q->in_global = MQ_IN_GLOBAL;                            //表示该消息队列已加入到全局队列中 //TODO
  q->release = 0;                                         //TODO
  q->overload = 0;                                        //TODO
  q->overload_threshold = MQ_OVERLOAD;                    //1024 //TODO
  q->queue = skynet_malloc(sizeof(struct skynet_message) * q->cap); //分配可保存64个消息的数组
  q->next = NULL;                                         //TODO
  return q;                                               //返回新创建的消息队列
}

//@[skynet_mq_push]将一个消息放入消息队列中
void skynet_mq_push(struct message_queue* q, struct skynet_message* message) {
  assert(message);
  SPIN_LOCK(q)
  q->queue[q->tail] = *message;     //将消息放入消息队列尾部
  if (++ q->tail >= q->cap) {       //循环消息队列，索引值达到最大值时置为0
    q->tail = 0;
  }
  if (q->head == q->tail) {         //当队列满时，将队列扩充到原来的2倍
    expand_queue(q);
  }
  if (q->in_global == 0) {          //如果消息队列没有放入全局队列中
    q->in_global = MQ_IN_GLOBAL;    //将标志置起
    skynet_globalmq_push(q);        //将消息队列追加到全局队列尾部
  }
  SPIN_UNLOCK(q)
}
```

# 消息源头一：套接字消息

```c

//@[socket-msg-flow]
//thread_socket
//skynet_socket_poll
//forward_message
//skynet_context_push
//skynet_mq_push

//@[thread_socket]套接字线程函数
void* thread_socket(void* p) {
  struct monitor* m = p;            //TODO
  skynet_initthread(THREAD_SOCKET); //将(-THREAD_SOCKET)保存到G_NODE.handle_key对应的thread local变量中
  for (;;) {
    int r = skynet_socket_poll();   //检查套接字是否有数据
    if (r == 0) break;              //返回0表示退出线程
    if (r > 0) {                    //大于0表示成功并且没有更多数据
      wakeup(m, 0);                 //TODO
    } else {                        //小于0表示未知套接字类型或有更多数据
      CHECK_ABORT                   //如果服务个数不为0继续运行，否则退出线程
    }
  }
  return NULL;
}

void wakeup(struct monitor* m, int busy) {
  if (m->sleep >= m->count - busy) {
    // signal sleep worker, "spurious wakeup" is harmless
    pthread_cond_signal(&m->cond);
  }
}

int skynet_socket_poll() {
  struct socket_server *ss = SOCKET_SERVER;
  assert(ss);
  struct socket_message result;
  int more = 1;
  int type = socket_server_poll(ss, &result, &more);
  switch (type) {
  case SOCKET_EXIT:
    return 0;
  case SOCKET_DATA:
    forward_message(SKYNET_SOCKET_TYPE_DATA, false, &result);
    break;
  case SOCKET_CLOSE:
    forward_message(SKYNET_SOCKET_TYPE_CLOSE, false, &result);
    break;
  case SOCKET_OPEN:
    forward_message(SKYNET_SOCKET_TYPE_CONNECT, true, &result);
    break;
  case SOCKET_ERROR:
    forward_message(SKYNET_SOCKET_TYPE_ERROR, true, &result);
    break;
  case SOCKET_ACCEPT:
    forward_message(SKYNET_SOCKET_TYPE_ACCEPT, true, &result);
    break;
  case SOCKET_UDP:
    forward_message(SKYNET_SOCKET_TYPE_UDP, false, &result);
    break;
  default:
    skynet_error(NULL, "Unknown socket message type %d.",type);
    return -1;
  }
  if (more) {
    return -1;
  }
  return 1;
}

void forward_message(int type, bool padding, struct socket_message* result) {
  struct skynet_socket_message* sm;
  size_t sz = sizeof(*sm);
  if (padding) {
    if (result->data) {
      size_t msg_sz = strlen(result->data);
      if (msg_sz > 128) {
        msg_sz = 128;
      }
      sz += msg_sz;
    } else {
      result->data = "";
    }
  }
  sm = (struct skynet_socket_message*)skynet_malloc(sz);
  sm->type = type;
  sm->id = result->id;
  sm->ud = result->ud;
  if (padding) {
    sm->buffer = NULL;
    memcpy(sm+1, result->data, sz - sizeof(*sm));
  } else {
    sm->buffer = result->data;
  }

  struct skynet_message message;
  message.source = 0;
  message.session = 0;
  message.data = sm;
  message.sz = sz | ((size_t)PTYPE_SOCKET << MESSAGE_TYPE_SHIFT);

  if (skynet_context_push((uint32_t)result->opaque, &message)) {
    // todo: report somewhere to close socket
    // don't call skynet_socket_close here (It will block mainloop)
    skynet_free(sm->buffer);
    skynet_free(sm);
  }
}

```

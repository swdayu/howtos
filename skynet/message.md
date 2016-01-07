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
  //然后调用服务的init函数，最后调用skynet_globalmq_push将该服务的消息队列追加到全局队列尾
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

# 消息源头二：错误消息

```c
//@[error-msg-flow]
//skynet_error
//skynet_context_push
//skynet_mq_push

//@[skynet_error]将context服务的错误消息发送到logger服务的消息队列
void skynet_error(struct skynet_context* context, const char* msg, ...) {
  //找到logger服务的handle
  static uint32_t logger = 0;
  if (logger == 0) {
    logger = skynet_handle_findname("logger");
  }
  //如果找不到logger服务则返回
  if (logger == 0) {
    return;
  }

  char tmp[LOG_MESSAGE_SIZE];
  char *data = NULL;
  va_list ap;

  //将错误信息打印到tmp数组中，这个数组的大小为256个字节
  va_start(ap,msg);
  int len = vsnprintf(tmp, LOG_MESSAGE_SIZE, msg, ap);
  va_end(ap);

  if (len >=0 && len < LOG_MESSAGE_SIZE) { //如果打印成功并且错误信息长度小于256个字节
    data = skynet_strdup(tmp);             //分配内存并将错误信息复制一份到内存中
  } else {                                 //否则成倍扩大内存直到打印出的错误信息小于分配的内存大小
    int max_size = LOG_MESSAGE_SIZE;
    for (;;) {
      max_size *= 2;
      data = skynet_malloc(max_size);

      va_start(ap,msg);
      len = vsnprintf(data, max_size, msg, ap);
      va_end(ap);

      if (len < max_size) {
        break;
      }
      skynet_free(data);
    }
  }

  //如果信息打印出错则释放内存并返回
  if (len < 0) {
    skynet_free(data);
    perror("vsnprintf error :");
    return;
  }

  //获取发生错误的服务的handle
  struct skynet_message smsg;
  if (context == NULL) {
    smsg.source = 0;
  } else {
    smsg.source = skynet_context_handle(context);
  }

  //设置好消息，并将消息发送到logger服务的消息队列
  smsg.session = 0;
  smsg.data = data;
  smsg.sz = len | ((size_t)PTYPE_TEXT << MESSAGE_TYPE_SHIFT);
  skynet_context_push(logger, &smsg);
}
```

# 消息源头三：计时器消息

```c
int skynet_timeout(uint32_t handle, int time, int session) {
  if (time <= 0) {
    //如果计时器立即超时，直接发送一个消息到handle对应的服务的消息队列中
    struct skynet_message message;
    message.source = 0;
    message.session = session;
    message.data = NULL;
    message.sz = (size_t)PTYPE_RESPONSE << MESSAGE_TYPE_SHIFT;
    if (skynet_context_push(handle, &message)) {
      return -1; //如果发送失败则返回-1
    }
  } 
  else {
    //否则添加一个计时器事件到全局计时器TI中
    struct timer_event event;
    event.handle = handle;
    event.session = session;
    timer_add(TI, &event, sizeof(event), time);
  }
  //返回session表示没有错误发生
  return session;
}

void* thread_timer(void* p) {
  struct monitor* m = p;             //TODO
  skynet_initthread(THREAD_TIMER);   //将(-THREAD_TIMER)保存到G_NODE.handle_key对应的thread local变量中
  for (;;) {
    skynet_updatetime();             //更新时间以及检查计时器是否超时
    CHECK_ABORT                      //如服务个数为0退出线程
    wakeup(m, m->count-1);           //TODO
    usleep(2500);                    //TODO
  }
  // wakeup socket thread
  skynet_socket_exit();              //TODO
  // wakeup all worker thread
  pthread_mutex_lock(&m->mutex);     //TODO
  m->quit = 1;                       //TODO
  pthread_cond_broadcast(&m->cond);  //TODO
  pthread_mutex_unlock(&m->mutex);   //TODO
  return NULL;
}

void skynet_updatetime(void) {
  uint64_t cp = gettime();                               //获取当前时间
  if(cp < TI->current_point) {                           //TI记录的时间不能比当前时间还大
    skynet_error(NULL, "time diff error: change from %lld to %lld", cp, TI->current_point);
    TI->current_point = cp;                              //否则报错并把TI记录的时间调小到当前时间
  } 
  else if (cp != TI->current_point) {                    //如果当前时间大于TI记录的时间
    uint32_t diff = (uint32_t)(cp - TI->current_point);  //计算当前时间超出的时间单位
    TI->current_point = cp;                              //更新TI记录的时间
    TI->current += diff;                                 //TODO
    int i;
    for (i=0;i<diff;i++) {                               //对每一个超出的时间单位
      timer_update(TI);                                  //更新一次计时器
    }
  }
}

//TI->current_point的初始值是TI创建时的时间
//
void timer_update(struct timer* T) {
  SPIN_LOCK(T);
  // try to dispatch timeout 0 (rare condition)
  timer_execute(T);
  // shift time first, and then dispatch timer message
  timer_shift(T);
  timer_execute(T);
  SPIN_UNLOCK(T);
}

//@[timer_node]计时器节点公共结构体
struct timer_node {        //该结构体只提供必要的信息
  struct timer_node *next; //单链表链接指针
  uint32_t expire;         //多久之后触发
};                         //更多的数据可以在动态分配时追加在这个结构体之后

struct timer {
  struct link_list near[TIME_NEAR];  //链表link_list是计时器节点单链表，TIMER_NEAR(256)个单链表
  struct link_list t[4][TIME_LEVEL]; //4 x TIME_LEVLE(64)个单链表（一共256个）
  struct spinlock lock;              //线程安全锁
  uint32_t time;                     //TODO
  uint32_t starttime;                //TODO
  uint64_t current;                  //TODO
  uint64_t current_point;            //TODO
};

void skynet_timer_init(void) {
	TI = timer_create_timer();
	uint32_t current = 0;
	systime(&TI->starttime, &current);
	TI->current = current;
	TI->current_point = gettime();
}

void timer_add(struct timer* T, void* arg, size_t sz, int time) {
  struct timer_node* node = (struct timer_node*)skynet_malloc(sizeof(*node)+sz);
  memcpy(node+1, arg, sz);       //分配计时器节点timer_node以及额外数据的空间，并初始化额外数据
  SPIN_LOCK(T);                  //线程安全加锁
  node->expire = time + T->time; //TODO
  add_node(T, node);             //添加计时器节点
  SPIN_UNLOCK(T);
}

//@[add_node]添加一个计时器节点
void add_node(struct timer* T,struct timer_node* node) {
  uint32_t time = node->expire;                                     //计时器多久后超时
  uint32_t current_time = T->time;                                  //当前TI记录的时间，创建时它的初始值为0
  if ((time | TIME_NEAR_MASK) == (current_time | TIME_NEAR_MASK)) { //TIME_NEAR_MASK 0xFF
    link(&T->near[time & TIME_NEAR_MASK], node);                    //如果计时器超时的时间与当前记录的时间只有最低字节不同，
  } 　　　　　　　　　　　　　　　　　　　　　                      //将这个计时器节点追加到对应的near[]单链表尾部
  else {                                                            //如果时间差更大
    int i;                                                          //TIME_NEAR 2^8, TIME_LEVEL_SHIFT 6 
    uint32_t mask = TIME_NEAR << TIME_LEVEL_SHIFT;                  //再判断是否只有低14-bit不同，或
    for (i = 0; i < 3; i++) {                                       //再判断是否只有低20-bit不同，或
      if ((time | (mask - 1)) == (current_time | (mask - 1))) {     //再判断是否只有低26-bit不同，或
        break;                                                      //再判断是否只有低32-bit不同
      }                                                             //如果是就结束判断
      mask <<= TIME_LEVEL_SHIFT;                                    //将计时器节点追加到对应的t[i][]单链表尾部
    }                               //因此near中保存的计时器会最早超时，然后依次是t[0], t[1], t[2], 最后是t[3]
    link(&T->t[i][((time >> (TIME_NEAR_SHIFT + i * TIME_LEVEL_SHIFT)) & TIME_LEVEL_MASK)], node);	
  }
}

void timer_execute(struct timer* T) {
  int idx = T->time & TIME_NEAR_MASK;
  while (T->near[idx].head.next) {
    struct timer_node *current = link_clear(&T->near[idx]);
    SPIN_UNLOCK(T);
    // dispatch_list don't need lock T
    dispatch_list(current);
    SPIN_LOCK(T);
  }
}

void timer_shift(struct timer* T) {
  int mask = TIME_NEAR;
  uint32_t ct = ++T->time;
  if (ct == 0) {
    move_list(T, 3, 0);
  } 
  else {
    uint32_t time = ct >> TIME_NEAR_SHIFT;
    int i=0;
    while ((ct & (mask-1))==0) {
      int idx=time & TIME_LEVEL_MASK;
      if (idx!=0) {
        move_list(T, i, idx);
        break;
      }
      mask <<= TIME_LEVEL_SHIFT;
      time >>= TIME_LEVEL_SHIFT;
      ++i;
    }
  }
}

//@[dispatch_list]释放这个链表的所有计时器，并将这些计时器对应的超时消息发送到对应服务的消息队列
void dispatch_list(struct timer_node* current) {
  do {
    struct timer_event* event = (struct timer_event*)(current+1);
    struct skynet_message message;
    message.source = 0;
    message.session = event->session;
    message.data = NULL;
    message.sz = (size_t)PTYPE_RESPONSE << MESSAGE_TYPE_SHIFT; //消息长度为0，高8-bit保存消息类型
    skynet_context_push(event->handle, &message);              //将这个计时器超时消息发送到handle对应得服务消息队列中
    struct timer_node* temp = current;                         //释放当前计时器节点，然后继续链表中下一个计时器节点
    current=current->next;                                     //直到链表为空
    skynet_free(temp);	
  } while (current);
```

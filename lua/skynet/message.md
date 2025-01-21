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

//@[skynet_message]Skynet消息结构体
struct skynet_message {
	uint32_t source; //发送消息的服务handle
	int session;     //TODO
	void* data;      //消息的数据
	size_t sz;       //数据的长度，以及消息的类型（高8位）
};

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

计时器相关结构体以及初始函数：
```c
//@[timer_node]计时器节点通用数据头部
struct timer_node {        //该结构体只提供必要信息：
  struct timer_node *next; //单链表链接指针，以及
  uint32_t expire;         //该计时器创建后多久超时；
};                         //更多的数据可以在动态分配时追加在这个结构体之后

//@[link_list]计时器节点单链表
struct link_list {         //链表结构：head.next->[1st timer]->...->[tail timer]->NULL, tail->[tail timer]
  struct timer_node head;  //链表头节点，实际链表第一个节点为head.next
  struct timer_node *tail; //尾节点指针，指向链表最后一个计时器节点
};

//@[timer]计时器全局变量TI对应的结构体
//各个链表数组中的计时器的超时时间：near大概2.5s内，t[0] 2.7分钟内，t[1] 2.9小时内，t[2] 7.7天内，t[3] 497.1天内
struct timer {                       //TIME_NEAR 256, TIME_LEVEL 64
  struct link_list near[TIME_NEAR];  //near中的所有单链表保存的计时器节点的超时时间点与TI->time比只有低8位不同
                                     //每个单链表保存着超时时间点相同的计时器节点
  struct link_list t[4][TIME_LEVEL]; //t[0]中的所有单链表保存的计时器节点的超时时间点与TI->time比只有低14位不同
                                     //t[1]只有低20位不同，t[2]只有低26位不同，t[3]只有低32位不同
  struct spinlock lock;              //线程安全锁
  uint32_t time;                     //计时器的基准时间，单位为10毫秒：Skynet大概每10毫秒更新这个值一次（+1）
  uint32_t starttime;                //TI创建的时间：变量TI创建时的时间，单位为秒
  uint64_t current;                  //TI已经创建的时间：变量TI创建后到现在有多久，单位为10毫秒
  uint64_t current_point;            //当前时间：从1970.1.1零点到现在有多久，单位为10毫秒
};

//@[link_clear]清除link_list中的所有节点，并返回这些节点组成的单链表
static struct timer_node* link_clear(struct link_list* list) {
  struct timer_node* ret = list->head.next; //要返回的第一个计时器节点指针
  list->head.next = 0;                      //将指向第一个节点的指针清为0
  list->tail = &(list->head);               //将尾节点指针指向头节点
  return ret;                               //返回单链表的第一个节点的指针
}

//@[link]将计时器节点添加到link_list的尾部
static void link(struct link_list* list, struct timer_node* node) {
  list->tail->next = node; //将节点添加到尾节点之后
  list->tail = node;       //将尾节点指针指向新加入的节点
  node->next = 0;          //将尾节点的下一节点指针清为0
}

//@[timer_create_timer]分配timer结构体并进行初始化
static struct timer* timer_create_timer() {
  struct timer* r = (struct timer*)skynet_malloc(sizeof(struct timer));
  memset(r, 0, sizeof(*r));            //分配结构体内存，并将内容清为0
  int i, j;
  for (i = 0; i < TIME_NEAR; i++) {    //对256个单链表
    link_clear(&r->near[i]);           //清除链表，使单链表head.next指向0，tail指向头节点
  }
  for (i = 0; i < 4; i++) {
    for (j = 0; j < TIME_LEVEL; j++) { //对4x64个单链表
      link_clear(&r->t[i][j]);         //清除链表，使单链表head.next指向0，tail指向头节点
    }
  }
  SPIN_INIT(r)
  r->current = 0;
  return r;
}

//@[skynet_timer_init]分配并初始化全局变量TI
void skynet_timer_init(void) {
  TI = timer_create_timer();
  uint32_t current = 0;
  systime(&TI->starttime, &current); //用当前系统时间初始化TI的创建时间startime，单位为秒
  TI->current = current;             //初始化TI已经创建的时间current，单位为10ms
  TI->current_point = gettime();     //初始化当前时间current_point，单位位10ms
}

static void systime(uint32_t* sec, uint32_t* cs) { //百分之一秒或10毫秒（centisecond）
#if !defined(__APPLE__)                     //非苹果Linux平台
  struct timespec ti;                       //精度为纳秒（nanoseconds）
  clock_gettime(CLOCK_REALTIME, &ti);       //获取当前时间，受系统调时影响
  *sec = (uint32_t)ti.tv_sec;               //秒
  *cs = (uint32_t)(ti.tv_nsec / 10000000);  //将纳秒转换成10毫秒
#else                                       //苹果平台
  struct timeval tv;                        //精度为微秒（microseconds）
  gettimeofday(&tv, NULL);                  //获取当前时间，受系统调时影响
  *sec = tv.tv_sec;                         //秒
  *cs = tv.tv_usec / 10000;                 //将微秒转换成10毫秒
#endif
}

static uint64_t gettime() {
  uint64_t t;
#if !defined(__APPLE__)
  struct timespec ti;                  //非苹果平台
  clock_gettime(CLOCK_MONOTONIC, &ti); //获取当前时间，不受系统调时影响（但受adjtime和NTP的影响）
  t = (uint64_t)ti.tv_sec * 100;       //将秒转换成10毫秒
  t += ti.tv_nsec / 10000000;          //将纳秒转换成10毫秒
#else
  struct timeval tv;                   //苹果平台
  gettimeofday(&tv, NULL);             //获取当前时间，受系统调时影响
  t = (uint64_t)tv.tv_sec * 100;       //将秒转换成10毫秒
  t += tv.tv_usec / 10000;             //将微秒转换成10毫秒
#endif
  return t;
}

//@[clock_gettime]retrieve the time of the specified clock clk_id, return 0 for success
//the timespec is defined in time.h: { time_t tv_sec; long tv_nsec; /* nanoseconds */ }
//a clock may be system-wide and hence visible for all processes, or per-process if 
//  it measures time only within a single process.
//CLOCK_REALTIME: all implemenations support this system-wide realtime clock;
//  its time represents seconds and nanoseconds since the Epoch (1970-01-01 00:00:00 UTC).
//  setting this clock requires appropriate privileges. this clock is affected by discontinuous 
//  jumps in the system time (e.g., if the system administrator manually changes the clock), 
//  and by the incremental adjustments performed by adjtime(3) and NTP.
//CLOCK_MONOTONIC: clock that cannot be set and represents monotonic time since some 
//  unspecified starting point. this clock is not affected by discontinuous jumps in the 
//  system time (e.g., if the system administrator manually changes the clock), but is affected 
//  by the incremental adjustments performed by adjtime(3) and NTP.
int clock_gettime(clockid_t clk_id, struct timespec* tp);

//@[gettimeofday]get the time as wall as a timezone, return 0 for success
//struct timeval is defined in sys/time.h: { time_t tv_sec; suseconds_t tv_usec; /* microseconds */ }
//  retrieve the number of seconds and microseconds since the Epoch (1970-01-01 00:00:00 UTC)
//the use of timezone is obsolete, the tz argument should normally be specified as NULL
//note: the time returned by gettimeofday() is affected by discontinuous jumps in the system time 
//  (e.g., if the system administrator manually changes the system time). if you need a monotonically 
//  increasing clock, see clock_gettime.
int gettimeofday(struct timeval* tv, struct timezone* tz);
```

在Lua中调用skynet.timeout(time, func), skynet.sleep(time)可以添加一个计时器，
最终调用C函数skynet_timeout将计时器添加到全局变量TI中，或立即超时:
```c
int skynet_timeout(uint32_t handle, int time, int session) {
  if (time <= 0) {
    //如果计时器立即超时，直接发送一个消息到handle对应的服务的消息队列中
    struct skynet_message message;
    message.source = 0;
    message.session = session;
    message.data = NULL; //消息的类型编码在sz的高8位
    message.sz = (size_t)PTYPE_RESPONSE << MESSAGE_TYPE_SHIFT;
    if (skynet_context_push(handle, &message)) {
      return -1;         //如果发送失败则返回-1
    }
  } 
  else {                 //否则添加一个计时器事件到全局变量TI中
    struct timer_event event;
    event.handle = handle;
    event.session = session;
    timer_add(TI, &event, sizeof(event), time);
  }
  return session;        //返回session表示没有错误发生
}

static void timer_add(struct timer* T, void* arg, size_t sz, int time) {
  struct timer_node* node = (struct timer_node*)skynet_malloc(sizeof(*node)+sz);
  memcpy(node+1, arg, sz);       //分配计时器节点timer_node以及额外数据的空间，并初始化额外数据
  SPIN_LOCK(T);                  //线程安全加锁
  node->expire = time + T->time; //将计时器的超时时间点设置为：计时器的基准时间 + 用户设置的超时
  add_node(T, node);             //添加计时器节点
  SPIN_UNLOCK(T);
}

//@[add_node]添加一个计时器节点
//保存在near中的计时器会最早超时，然后依次是t[0]、t[1]、t[2]、t[3]中的计时器
//以10ms为单位，无符号8-bit能表示2.5秒，14-bit 2.7分钟，20-bit 2.9小时，26-bit 7.7天，32-bit 497.1天
static void add_node(struct timer* T,struct timer_node* node) {
  uint32_t time = node->expire;                    //计时器的超时时间点
  uint32_t current_time = T->time;                 //计时器的基准时间，初始值为0，然后Skynet大概每10ms加1
  if ((time | TIME_NEAR_MASK) == (current_time | TIME_NEAR_MASK)) { //TIME_NEAR_MASK 0xFF
    link(&T->near[time & TIME_NEAR_MASK], node);   //如果计时器超时时间点与当前基准时间只有最低8-bit不同，
  }                                                //将这个计时器节点追加到near[time&0xFF]单链表尾部
  else {                                           //如果时间差更大（TIME_NEAR 2^8, TIME_LEVEL_SHIFT 6）
    int i;                                         //再判断是否只有低14-bit不同，或
    uint32_t mask = TIME_NEAR << TIME_LEVEL_SHIFT; //再判断是否只有低20-bit不同，或
    for (i = 0; i < 3; i++) {                      //再判断是否只有低26-bit不同，或
      if ((time | (mask - 1)) == (current_time | (mask - 1))) {
        break;                                     //再判断是否只有低32-bit不同
      }                                            //如果是就结束判断
      mask <<= TIME_LEVEL_SHIFT;                   //将计时器节点追加到t[i][(time>>(8+i*6))&0x3F]单链表尾部
    } 
    link(&T->t[i][((time >> (TIME_NEAR_SHIFT + i * TIME_LEVEL_SHIFT)) & TIME_LEVEL_MASK)], node);	
  }
}
```

全局变量TI中的计时器处理流程：
```c
//@[thread_timer]计时器处理线程
static void* thread_timer(void* p) {
  struct monitor* m = p;             //TODO
  skynet_initthread(THREAD_TIMER);   //将(-THREAD_TIMER)保存到G_NODE.handle_key对应的thread local变量中
  for (;;) {
    skynet_updatetime();             //更新时间以及检查计时器是否超时
    CHECK_ABORT                      //如服务个数为0退出线程
    wakeup(m, m->count-1);           //TODO
    usleep(2500);                    //睡2500微秒（2.5毫秒）
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

//@[skynet_updatetime]该函数每>2.5ms执行一次
void skynet_updatetime(void) {
  uint64_t cp = gettime();            //获取当前时间，这个时间可能受系统调时、adjtime或网络对时NTP影响
  if(cp < TI->current_point) {        //如果TI保存的当前时间比获取的当前时间还大（例如网络对时校准后比原来时间小）
    skynet_error(NULL, "time diff error: change from %lld to %lld", cp, TI->current_point);
    TI->current_point = cp;           //发送一个错误消息，并把TI记录的当前时间调小到获取的当前时间
  } 
  else if (cp != TI->current_point) { //如果获取的当前时间大于TI记录的当前时间
    uint32_t diff = (uint32_t)(cp - TI->current_point); //无符号32位整数可以表示497.1天的时间（以10ms为单位）
    TI->current_point = cp;           //更新TI记录的当前时间
    TI->current += diff;              //更新TI已创建的时间
    int i;
    for (i = 0; i < diff; i++) {      //对每一个超出的时间单位（diff个10ms）都更新一次计时器
      timer_update(TI);               //由于skynet_updatetime最短睡2.5ms运行一次，这个循环运行的次数应该不会过多
    }
  }                                   //如果获取的当前时间与TI记录的当前时间相等，这个函数不会做任何事情
}

//@[timer_update]该函数每个时间单位（10ms）都会执行一次
static void timer_update(struct timer* T) {
  SPIN_LOCK(T);
  // try to dispatch timeout 0 (rare condition)
  timer_execute(T); //使用旧的基准时间，派送链表near[time&0xFF]中计时器的超时消息
  timer_shift(T);   //更新计时器基准时间，并根据新基准时间重新添加链表t[i][j]中的计时器
  timer_execute(T); //使用新的基准时间，派送链表near[time&0xFF]中计时器的超时消息
  SPIN_UNLOCK(T);
}

//@[timer_execute]为链表near[time&0xFF]中的计时器派送超时消息
static void timer_execute(struct timer* T) {
  int idx = T->time & TIME_NEAR_MASK; //基准时间的低8位，基准时间更新时都会执行timer_execute
  while (T->near[idx].head.next) {    //如果当前时间单位对应的链表中有计时器
    struct timer_node* current = link_clear(&T->near[idx]);
    SPIN_UNLOCK(T);                   //清空这个链表，link_clear会返回原链表中的所有计时器
    dispatch_list(current);           //对每个计时器派发超时消息
    SPIN_LOCK(T);
  }
}

//@[dispatch_list]释放这个链表的所有计时器，并将这些计时器对应的超时消息发送到对应服务的消息队列
static void dispatch_list(struct timer_node* current) {
  do {
    struct timer_event* event = (struct timer_event*)(current+1);
    struct skynet_message message;                //获取计时器结构体尾部的额外数据timer_event
    message.source = 0;                           //初始化一个skynet_message
    message.session = event->session;
    message.data = NULL;                          //消息数据长度为0，高8-bit保存消息类型
    message.sz = (size_t)PTYPE_RESPONSE << MESSAGE_TYPE_SHIFT;
    skynet_context_push(event->handle, &message); //将这个计时器超时消息发送到handle对应得服务消息队列中
    struct timer_node* temp = current;            //释放当前计时器节点，然后继续链表中下一个计时器节点
    current = current->next;                      //直到链表为空
    skynet_free(temp);	
  } while (current);
}

//@[timer_shift]该函数每个时间单位（10ms）执行一次
static void timer_shift(struct timer* T) {
  int mask = TIME_NEAR;                 //mask 256, mask-1 0xFF
  uint32_t ct = ++T->time;              //基准时间加1
  if (ct == 0) {                        //如果基准时间低32位变成了0：
    move_list(T, 3, 0);                 //TODO
  } 
  else {                              
    uint32_t time = ct >> TIME_NEAR_SHIFT;
    int i = 0;
    while ((ct & (mask-1)) == 0) {      //如果基准时间低8位变成了0：重新添加t[0][[9,14]!=0]中的计时器并退出循环
      int idx = time & TIME_LEVEL_MASK; //如果基准时间低14位变成了0：重新添加t[1][[15,20]!=0]中的计时器并退出循环
      if (idx != 0) {                   //如果基准时间低20位变成了0：重新添加t[2][[21,26]!=0]中的计时器并退出循环
        move_list(T, i, idx);           //如果基准时间低26位变成了0：重新添加t[3][[27,32]!=0]中的计时器并退出循环
        break;                             
      }
      mask <<= TIME_LEVEL_SHIFT;
      time >>= TIME_LEVEL_SHIFT;
      ++i;
    }
  }
}

//@[move_list]清除链表t[level][idx]，并重新添加这个链表中的所有计时器节点
static void move_list(struct timer* T, int level, int idx) {
  struct timer_node* current = link_clear(&T->t[level][idx]);
  while (current) {
    struct timer_node* temp = current->next;
    add_node(T, current);
    current = temp;
  }
}
```

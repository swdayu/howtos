
## 消息队列，你到底是个怎么回事？

---
andre说消息通信可能是唯一正确的解决并行通信问题的方法
---

**Skynet的消息机制是怎么实现的**

默认消息队列大小为64个，全局队列最大6万5（0x10000为65535）。

```
#define DEFAULT_QUEUE_SIZE 64
#define MAX_GLOBAL_MQ 0x10000
```


队列有一个标志，0表示这个消息队列不再全局消息队列力，1表示
在全局消息队列，或表示这个消息队列正在分派（dispatching）。
MQ_OVERLOAD是个什么鬼，现在还不得而知。*** 疑问（1）

```
#define MQ_IN_GLOBAL 1
#define MQ_OVERLOAD 1024
```

存在一个全局队列，单向串联起一系列消息队列，其中第一个和最后
一个队列可直接访问。其中为什么会有一个 spin lock，要怎么用，现
在我也一点头绪没有。*** 疑问（2）

且其中每个消息队列都有一个 spin lock，到底搞哪样，同样很疑问。*** 疑问（3）

```
struct global_queue {
	struct message_queue *head;
	struct message_queue *tail;
	struct spinlock lock;
};

static struct global_queue *Q = NULL;
```

简单的，全局队列中就是有很多消息队列，每个消息队列长成这样：

```
struct message_queue {
	struct spinlock lock;
	uint32_t handle;
	int cap;
	int head;
	int tail;
	int release;
	int in_global;
	int overload;
	int overload_threshold;
	struct skynet_message *queue;
	struct message_queue *next;
};
```

而消息长这样：

```
struct skynet_message {
	uint32_t source;
	int session;
	void * data;
	size_t sz;
};
```

上面一些域含义很自然，cap表示消息队列当前容量（当前queue指向的
组数大小），head哪个是队列的第一个消息，tail哪个是最后一个消息。
in_global就是上面说的哪个标识，可以是0，或1（MQ_IN_GLOBAL）。
queue是实际保存消息的数组，next单向串联下一个消息队列。而每一
消息中，data指向实际的消息数据，sz消息数据大小。source是消息的
来源，session是消息所属会话，具体含义有待细看。*** 疑问（4）

还搞不明白的是，消息队列为什么都有一个 spin lock，和疑问（3）一起
看。每个消息队列为什么还都有一个 handle，与消息的 source、session
有什么不同，与疑问（4）一起看。release又是什么鬼。*** 疑问（5）
overload，overload_threshold同样是什么鬼，和疑问（1）一起看。



# 服务

Skynet的C服务是一个动态库模块，由skynet_module定义:
```c
struct skynet_module {
  const char* name;          //服务的名称
  void* module;              //服务对应动态库加载后的句柄
  skynet_dl_create create;   //用于创建服务实例：void* (*)(void)
  skynet_dl_init init;       //用于初始化服务实例：int (*)(void* inst, struct skynet_context* ctx, const char* parm)
  skynet_dl_release release; //用于释放服务实例：void (*)(void* inst)
  skynet_dl_signal signal;   //用于发送signal：void (*)(void* inst, int signal)
};
```

通过调用skynet_context_new(name, parm)可以创建一个新的服务实例。参数name是服务的名称，skynet会在环境
变量中搜索这个名称对应的动态库所在路径，然后加载这个动态库并调用其中的create函数和init函数来创建和
初始化服务实例，另外与服务对应的模块、句柄、以及消息队列，都会关联到全局模块M、全局句柄H、全局队列Q中。
参数parm是传递给服务初始化函数init的参数。

Skynet为服务的定义提供了最底层的基础设施，这些基础设施都定义在skynet_server.c源文件内。


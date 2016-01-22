
# 服务

Skynet最基本的服务都是使用C编写的，即使是上层使用Lua编写的服务，也都需要依赖底层的C服务才能运行。
Skynet的C服务由一组C函数组成，最终会编译成一个动态库模块，这个动态库模块在代码中使用skynet_module表示。
```c
struct skynet_module {
  const char* name;          //服务的名称
  void* module;              //服务对应的动态库加载后的句柄
  skynet_dl_create create;   //用于创建服务实例：void* (*)(void)
  skynet_dl_init init;       //用于初始化服务实例：int (*)(void* inst, skynet_context* ctx, parm)
  skynet_dl_release release; //用于释放服务实例：void (*)(void* inst)
  skynet_dl_signal signal;   //用于发送signal：void (*)(void* inst, int signal)
};
```

通过调用函数skynet_context_new(name, parm)可以创建一个新的服务实例。参数name是服务的名称，skynet会在环境
变量中搜索这个名称对应的动态库所在路径，然后加载这个动态库（如果对应的动态库已经加载了，可以在全局模块M中
找到相同名称的skynet_module对象，则直接使用这个已经加载了的模块来创建服务实例），并调用其中的create函数和
init函数来创建和初始化服务实例，另外与服务对应的模块、句柄、以及消息队列，都会关联到全局模块M、全局句柄H、
全局队列Q中。参数parm是传递给服务初始化函数init的参数。最终skynet_context_new会返回新创建服务实例的指针，
而创建的服务实例都会保存到全局变量H的slot数组中，服务是使用句柄（一个32位整数）进行标识的，可以通过服务的
句柄获取对应的服务实例。

Skynet为服务的定义提供了最底层的基础设施，这些基础设施都定义在skynet_server.c源文件中。

## 消息发送

## 消息处理

调用skynet_callback(ctx, ud, cb)可以设置服务的消息处理函数和处理函数的参数，当工作线程处理所有消息队列中的
消息时，会调用对应服务的消息处理函数，将发给该服务的消息传递给服务处理，参见dispatch_message函数中的调用：
`ctx->cb(ctx, ctx->cb_ud, type, msg->session, msg->source, msg->data, sz)`。
```c
void skynet_callback(struct skynet_context* context, void* ud, skynet_cb cb) {
	context->cb = cb;    //设置服务的消息处理函数
	context->cb_ud = ud; //设置服务消息处理函数的参数
}
```


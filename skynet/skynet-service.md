
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

## 发送消息

通过调用函数skynet_send或skynet_sendname，一个服务可以发送一条消息给另一个服务。
发送消息的一方称为源服务，即src_hdl对应的服务，如果src_hdl为0则源服务是ctx服务自身；
接收消息的一方称为目标服务，即dest_hdl或dest_name对应的服务，目标服务的句柄和名称不能为0，否则会错误返回不发送消息。
消息的内容包括消息的类型msg_type、消息会话msg_session、消息数据msg_data、以及消息的长度msg_sz。
其中session是发送方对消息的唯一标识，接收方收到消息后响应这条消息必须将session带回，使发送方知道响应的是哪条消息。
Session是一个非负整数，当服务的消息不需要回复时，可以使用0作为消息的session号。
```c
int skynet_send(skynet_context* ctx, src_hdl, dest_hdl, msg_type, msg_session, msg_data, msg_sz);
int skynet_sendname(skynet_context* ctx, src_hdl, dest_name, msg_type, msg_session, msg_data, msg_sz);
```

## 处理消息

调用skynet_callback(ctx, ud, cb)可以设置服务的消息处理函数和参数。
```c
void skynet_callback(struct skynet_context* context, void* ud, skynet_cb cb) {
	context->cb = cb;    //设置服务的消息处理函数
	context->cb_ud = ud; //设置服务消息处理函数的参数
}
```
当工作线程处理消息队列中的消息时，会调用对应服务的消息处理函数，将发给该服务的消息传递给服务处理，
参见dispatch_message函数中的调用。
```c
ctx->cb(ctx, ctx->cb_ud, type, msg->session, msg->source, msg->data, sz);
```

## 服务命令

```c
//@[cmd_timeout]添加一个context服务的计时器，返回消息session号对应的字符串
//计时器的超时时间通过字符串param传入，当计时器超时后，框架会发送一条消息给context对应的服务
static const char* cmd_timeout(skynet_context* context, const char* param) {
  char* session_ptr = NULL;
  int ti = strtol(param, &session_ptr, 10);
  int session = skynet_context_newsession(context);
  skynet_timeout(context->handle, ti, session);
  sprintf(context->result, "%d", session);
  return context->result;
}

//@[cmd_reg]为服务注册一个名称：如果传入的名称param为空，则注册名称":hex_str_of_service_handle"到ctx->result中；
//如果名称以字符点（.）开头，表示该服务名称属于当前skynet节点，最后服务的handle-name对被添加到数组H->name中；
//否则报错，不能C中注册一个全局名称；最后返回注册后的名称或NULL
static const char* cmd_reg(skynet_context* context, const char* param) {
  if (param == NULL || param[0] == '\0') {
    sprintf(context->result, ":%x", context->handle);
    return context->result;
  } else if (param[0] == '.') {
    return skynet_handle_namehandle(context->handle, param + 1);
  } else {
    skynet_error(context, "Can't register global name %s in C", param);
    return NULL;
  }
}

//@[cmd_query]查找名称为param的服务的handle，并将字符串":hex_str_of_service_handle"注册到ctx->result中；
//传入的param必须以字符点（.）开头，对应名称的服务必须存在；最后返回注册的字符串或NULL
static const char* cmd_query(skynet_context* context, const char* param) {
  if (param[0] == '.') {
    uint32_t handle = skynet_handle_findname(param+1);
    if (handle) {
      sprintf(context->result, ":%x", handle);
      return context->result;
    }
  }
  return NULL;
}

//@[cmd_name]将param里面的name-handle对".service_name :hex_str_of_service_handle"注册到数组H->name中；
//最后返回注册后的名称".service_name"，或传入param的格式不对则返回NULL
static const char* cmd_name(skynet_context* context, const char* param) {
  int size = strlen(param);
  char name[size+1];
  char handle[size+1];
  sscanf(param,"%s %s",name,handle);
  if (handle[0] != ':') {
    return NULL;
  }
  uint32_t handle_id = strtoul(handle+1, NULL, 16);
  if (handle_id == 0) {
    return NULL;
  }
  if (name[0] == '.') {
    return skynet_handle_namehandle(handle_id, name + 1);
  } else {
    skynet_error(context, "Can't set global name %s in C", name);
  }
  return NULL;
}

//@[cmd_launch]创建一个制定名称的服务实例，参数param的格式为"service_name init_args"，
//用于传入服务的名称以及传递给服务初始化函数init的参数，如果创建失败则返回NULL；
//如果创建成功，将字符串":hex_str_of_service_handle"注册到context->result，最后返回注册的字符串
static const char* cmd_launch(skynet_context* context, const char* param) {
  size_t sz = strlen(param);
  char tmp[sz+1];
  strcpy(tmp, param);
  char* args = tmp;
  char* mod = strsep(&args, " \t\r\n");
  args = strsep(&args, "\r\n");
  struct skynet_context* inst = skynet_context_new(mod, args);
  if (inst == NULL) {
    return NULL;
  } else {
    id_to_hex(context->result, inst->handle);
    return context->result;
  }
}

//@[cmd_getenv]获取环境变量字符串对应的值，这些环境变量保存在skynet的全局环境中的lua_State（E->L）的全局变量中
static const char* cmd_getenv(skynet_context* context, const char* param) {
  return skynet_getenv(param);
}

//@[cmd_setenv]设置环境变量键值对设置到skynet的全局环境中（E->L），传入的参数param的格式为"key value"
static const char* cmd_setenv(skynet_context* context, const char* param) {
  size_t sz = strlen(param);
  char key[sz+1];
  int i;
  for (i=0; param[i] != ' ' && param[i]; i++) {
    key[i] = param[i];
  }
  if (param[i] == '\0')
    return NULL;
  key[i] = '\0';
  param += i+1;
  skynet_setenv(key, param);
  return NULL;
}

//@[cmd_starttime]获取skynet启动的时间，以秒为单位，返回的结果保存在context->result字符中
static const char* cmd_starttime(skynet_context* context, const char* param) {
  uint32_t sec = skynet_starttime();
  sprintf(context->result, "%u", sec);
  return context->result;
}

//@[cmd_endless]获取当前的服务是否为endless，返回的结果保存在context->result中
//如果当前服务为endless则获取后将endless设为false，如果当前服务不处于endless状态则返回NULL
static const char* cmd_endless(skynet_context* context, const char* param) {
  if (context->endless) {
    strcpy(context->result, "1");
    context->endless = false;
    return context->result;
  }
  return NULL;
}

//@[cmd_kill]杀掉指定名称的服务，传入的名称param可以是形如":hex_str_of_service_handle"或".service_name"的字符串
static const char* cmd_kill(skynet_context* context, const char* param) {
  uint32_t handle = tohandle(context, param);
  if (handle) {
    handle_exit(context, handle);
  }
  return NULL;
}

//@[cmd_exit]杀掉服务context自身，参数param没有使用
static const char* cmd_exit(skynet_context* context, const char* param) {
  handle_exit(context, 0);
  return NULL;
}

//@[cmd_abort]杀死当前skynet节点所有的服务
static const char* cmd_abort(skynet_context* context, const char* param) {
  skynet_handle_retireall();
  return NULL;
}

//@[cmd_mqlen]获取服务消息队列中的消息个数，返回的结果保存在context->result中
static const char* cmd_mqlen(skynet_context* context, const char* param) {
  int len = skynet_mq_length(context->queue);
  sprintf(context->result, "%d", len);
  return context->result;
}

//@[cmd_monitor]将指定服务名称的handle设置到G_NODE.monitor_exit，或获取当前的monitor_exit
//如果param为空，monitor_exit已经设置的话将结果保存在context->result中返回，否则返回NULL；
//如果param指定了形如":hex_str_of_service_handle"或".service_name"的服务名称，
//找到对应服务的handle赋给monitor_exit并返回NULL
static const char* cmd_monitor(skynet_context* context, const char* param) {
  uint32_t handle=0;
  if (param == NULL || param[0] == '\0') {
    if (G_NODE.monitor_exit) {
      // return current monitor serivce
      sprintf(context->result, ":%x", G_NODE.monitor_exit);
      return context->result;
    }
    return NULL;
  } else {
    handle = tohandle(context, param);
  }
  G_NODE.monitor_exit = handle;
  return NULL;
}

//@[cmd_logon]将指定服务名称的logfile打开
static const char* cmd_logon(skynet_context* context, const char* param) {
  uint32_t handle = tohandle(context, param);
  if (handle == 0)
    return NULL;
  struct skynet_context* ctx = skynet_handle_grab(handle);
  if (ctx == NULL)
    return NULL;
  FILE* f = NULL;
  FILE* lastf = ctx->logfile;
  if (lastf == NULL) {
    f = skynet_log_open(context, handle);
    if (f) {
      if (!ATOM_CAS_POINTER(&ctx->logfile, NULL, f)) {
        // logfile opens in other thread, close this one.
        fclose(f);
      }
    }
  }
  skynet_context_release(ctx);
  return NULL;
}

//@[cmd_logoff]关闭指定服务名称的logfile
static const char* cmd_logoff(skynet_context* context, const char* param) {
  uint32_t handle = tohandle(context, param);
  if (handle == 0)
    return NULL;
  struct skynet_context * ctx = skynet_handle_grab(handle);
  if (ctx == NULL)
    return NULL;
  FILE* f = ctx->logfile;
  if (f) {
    // logfile may close in other thread
    if (ATOM_CAS_POINTER(&ctx->logfile, f, NULL)) {
      skynet_log_close(context, f, handle);
    }
  }
  skynet_context_release(ctx);
  return NULL;
}

//@[cmd_signal]调用服务定义的signal函数发送指定的signal
//传入的param的参数格式为":hex_str_of_service_handle signal_number"或者".service_name signal_number"
static const char* cmd_signal(skynet_context* context, const char* param) {
  uint32_t handle = tohandle(context, param);
  if (handle == 0)
    return NULL;
  struct skynet_context* ctx = skynet_handle_grab(handle);
  if (ctx == NULL)
    return NULL;
  param = strchr(param, ' ');
  int sig = 0;
  if (param) {
    sig = strtol(param, NULL, 0);
  }
  // NOTICE: the signal function should be thread safe.
  skynet_module_instance_signal(ctx->mod, ctx->instance, sig);
  skynet_context_release(ctx);
  return NULL;
}
```

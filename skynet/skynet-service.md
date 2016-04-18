
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

static struct command_func cmd_funcs[] = {
  { "TIMEOUT", cmd_timeout },
  { "REG", cmd_reg },
  { "QUERY", cmd_query },
  { "NAME", cmd_name },
  { "EXIT", cmd_exit },
  { "KILL", cmd_kill },
  { "LAUNCH", cmd_launch },
  { "GETENV", cmd_getenv },
  { "SETENV", cmd_setenv },
  { "STARTTIME", cmd_starttime },
  { "ENDLESS", cmd_endless },
  { "ABORT", cmd_abort },
  { "MONITOR", cmd_monitor },
  { "MQLEN", cmd_mqlen },
  { "LOGON", cmd_logon },
  { "LOGOFF", cmd_logoff },
  { "SIGNAL", cmd_signal },
  { NULL, NULL },
};
//@[skynet_command]执行指定的服务命令
const char* skynet_command(skynet_context* context, const char* cmd, const char* param) {
  struct command_func* method = &cmd_funcs[0];
  while(method->name) {
    if (strcmp(cmd, method->name) == 0) {
      return method->func(context, param);
    }
    ++method;
  }
  return NULL;
}
```

# Logger服务

Logger服务是skynet节点启动的第一个服务，用于接收和处理服务发给它的skynet_error信息。
Logger服务定义在service_logger.c源文件中，服务的定义必须实现skynet_module定义的相关函数接口。

Logger服务的创建
```c
//@[logger_create]分配并初始化Logger服务的结构体
struct logger* logger_create(void) {
  struct logger* inst = skynet_malloc(sizeof(*inst));
  inst->handle = NULL;
  inst->close = 0;
  return inst;
}
```

Logger服务的初始化
```c
//@[logger_init]传给init函数的参数parm必须是一个文件路径或为空
//根据传入的log文件路径，打开log文件或将log输出到标准输出
//为Logger服务设置消息处理函数_logger，并为Logger服务注册一个名称".looger"
//消息处理函数_logger将指定消息打印到log文件中或标准输出
//函数如果执行成功则返回0，否则返回1
int logger_init(struct logger* inst, skynet_context* ctx, const char* parm) {
  if (parm) {
    inst->handle = fopen(parm, "w");
    if (inst->handle == NULL) {
      return 1;
    }
    inst->close = 1;
  } else {
    inst->handle = stdout;
  }
  if (inst->handle) {
    skynet_callback(ctx, inst, _logger);
    skynet_command(ctx, "REG", ".logger");
    return 0;
  }
  return 1;
}
```

Logger服务的释放
```c
void logger_release(struct logger* inst) {
  if (inst->close) {
    fclose(inst->handle);
  }
  skynet_free(inst);
}
```

# Snlua服务

Snlua服务定义在service_snlua.c源文件中，用于加载Lua服务。
使用Lua编写的skynet服务都需要通过snlua服务来加载和运行。
Skynet节点启动的第二个服务是通过snlua服务加载和运行的bootstrap.lua服务。
这个Lua服务用于配置skynet节点的参数。另外，加载和运行一个Lua服务都会创建一个新的snlua服务实例。

Snlua服务的创建
```c
//@[snlua_create]分配snlua结构体并创建一个全新的lua_State
struct snlua* snlua_create(void) {
  struct snlua* l = skynet_malloc(sizeof(*l));
  memset(l, 0, sizeof(*l));
  l->L = lua_newstate(skynet_lalloc, NULL);
  return l;
}
```

Snlua服务的释放
```c
//@[snlua_release]关闭lua_State并释放snlua
void snlua_release(struct snlua* l) {
  lua_close(l->L);
  skynet_free(l);
}
```

Snlua服务的signal函数
```c
//@[snlua_signal]仅仅发送一个错误消息
void snlua_signal(struct snlua* l, int signal) {
  skynet_error(l->ctx, "recv a signal %d", signal);
#ifdef lua_checksig
  // If our lua support signal (modified lua version by skynet), trigger it.
  skynet_sig_L = l->L;
#endif
}
```

Snlua服务的init函数
```c
//@[snlua_init]设置消息处理函数，并发给自己发送一条消息，使用传入的参数作为消息的内容
int snlua_init(struct snlua* l, skynet_context* ctx, const char* args) {
  int sz = strlen(args);
  char* tmp = skynet_malloc(sz);
  memcpy(tmp, args, sz);
  skynet_callback(ctx, l , _launch);                   //设置snlua服务的消息处理函数为_launch
  const char* self = skynet_command(ctx, "REG", NULL); //获取服务的handle字符串
  uint32_t handle_id = strtoul(self+1, NULL, 16);      //从字符串中获取handle
  // it must be first message                          //给自己发送一条消息，将init的参数作为消息的内容
  skynet_send(ctx, 0, handle_id, PTYPE_TAG_DONTCOPY, 0, tmp, sz);
  return 0;
}
//@[_launch]清除Snlua服务的消息处理函数并初始化对应的Lua服务
static int _launch(skynet_context* context, void* ud, type, session, source, msg, sz) {
  assert(type == 0 && session == 0);
  struct snlua *l = ud;
  skynet_callback(context, NULL, NULL);    //清除snlua服务的消息处理函数
  int err = _init(l, context, msg, sz);    //初始化使用Lua编写的skynet服务
  if (err) {                               //如果发生错误，杀掉snlua服务
    skynet_command(context, "EXIT", NULL);
  }
  return 0;
}
//@[_init]加载并执行相应的Lua服务，字符串args中包含Lua服务的名称及参数
static int _init(struct snlua* l, skynet_context* ctx, const char* args, size_t sz) {
  lua_State *L = l->L;
  l->ctx = ctx;
  lua_gc(L, LUA_GCSTOP, 0);                     //暂停垃圾收集器
  lua_pushboolean(L, 1);  /* signal for libraries to ignore env. vars. */
  lua_setfield(L,                               //设置register_table["LUA_NOENV"]=true
    LUA_REGISTRYINDEX, "LUA_NOENV");
  luaL_openlibs(L);                             //为Snlua对应的lua_State打开所有标准库
  lua_pushlightuserdata(L, ctx);
  lua_setfield(L,                               //设置register_table["skynet_context"]=ctx
    LUA_REGISTRYINDEX, "skynet_context");
  luaL_requiref(L,                              //使用codecache函数加载skynet.codecache模块
    "skynet.codecache", codecache , 0);         //加载后的模块会设置到package.loaded[modname]中，并会拷贝一份放在栈顶
  lua_pop(L, 1);                                //移除栈顶的加载的模块
  const char *path = optstring(ctx, "lua_path", //设置L全局变量LUA_PATH的值为Lua库所在路径
    "./lualib/?.lua;./lualib/?/init.lua");
  lua_pushstring(L, path);
  lua_setglobal(L, "LUA_PATH");
  const char *cpath = optstring(ctx,            //设置L全局变量LUA_CPATH的值为C服务动态库所在路径
    "lua_cpath", "./luaclib/?.so");
  lua_pushstring(L, cpath);
  lua_setglobal(L, "LUA_CPATH");
  const char *service = optstring(ctx,          //设置L全局变量LUA_SERVICE的值为Lua服务所在路径
    "luaservice", "./service/?.lua");
  lua_pushstring(L, service);
  lua_setglobal(L, "LUA_SERVICE");
  const char* preload =                         //设置L全局变量LUA_PRELOAD的值为skynet环境变量preload对应的值
    skynet_command(ctx, "GETENV", "preload");
  lua_pushstring(L, preload);
  lua_setglobal(L, "LUA_PRELOAD");
  lua_pushcfunction(L, traceback);              //将C函数traceback压入栈中
  assert(lua_gettop(L) == 1);
  const char * loader = optstring(ctx, 
    "lualoader", "./lualib/loader.lua");
  int r = luaL_loadfile(L, loader);             //将loader.lua文件中的Lua函数加载到栈中
  if (r != LUA_OK) {                            //如果加载失败报告错误并返回
    skynet_error(ctx, "Can't load %s : %s",     //文件loader.lua中定义的函数的作用：TODO
      loader, lua_tostring(L, -1));
    _report_launcher_error(ctx);
    return 1;
  }
  lua_pushlstring(L, args, sz);                 //将参数args压入栈中
  r = lua_pcall(L, 1, 0, 1);                    //调用加载后的Lua函数，参数1个，不需要返回结果，错误处理函数为traceback
  if (r != LUA_OK) {                            //如果调用失败则报告错误并返回
    skynet_error(ctx, "lua loader error : %s",
      lua_tostring(L, -1));
    _report_launcher_error(ctx);
    return 1;
  }
  lua_settop(L,0);                               //清除栈中的参数
  lua_gc(L, LUA_GCRESTART, 0);                   //重新开启垃圾回收
  return 0;
}
//@[traceback]_init过程中的错误处理函数
static int traceback(lua_State *L) {
  const char* msg = lua_tostring(L, 1);
  if (msg)
    luaL_traceback(L, L, msg, 1);
  else {
    lua_pushliteral(L, "(no error message)");
  }
  return 1;
}
```

## Skynet的启动

**主要流程**
```c
//main()@skynet-src/skynet_main.c
1. 读取配置文件，将配置信息加载到skynet环境
2. 调用skynet_start()开始启动

//skynet_start()@skynet-src/skynet_start.c
3. 创建logger服务（service-src/service_logger.c）用于处理错误消息
   - 任何服务都可以调用skynet_error发送错误消息给logger服务
4. 创建一个snlua服务（service-src/service_snlua.c）加载执行bootstrap脚本（service/bootstrap.lua）
   - 
5. 启动1个moniter线程（用于监控）、1个timer线程（用于计时）、1个socket线程（处理网络socket）、和n个worker线程
6. 至此一个skynet节点启动完毕，节点中所有skynet服务的业务逻辑都将在worker线程中执行，直到skynet节点退出为止 
```

**Skynet节点模型**

一个skynet节点是一个操作系统进程，这个进程存在1个主线程、1个moniter线程、1个timer线程、1个socket线程、和n个worker线程。
Skynet使用服务对节点中的业务逻辑进行划分，而服务之间则通过消息传递进行数据通信。
因此从逻辑上看，一个skynet节点由多个skynet服务组成，每个服务都拥有一个32位的唯一句柄、以及一个用于接收消息的消息队列。
所有消息源头（运行在worker线程中的服务发送的消息、timer线程产生的超时消息、socket线程产生的网络消息）产生的消息
都会插入到目标服务的消息队列中，而所有服务的消息队列都被串联在一个叫Q的全局队列中。

**配置文件**

```lua
--基础配置--
thread = 8                    --指定当前节点启动的工作线程个数,一般不应超过实际CPU核心个数
logger = nil                  --指定日志输出的文件名,如果为nil则输出到标准错误流
logservice = "logger"         --指定logger服务的名称(默认的"logger"服务在service_logger.c中实现),这个服务用于打印日志
bootstrap = "snlua bootstrap" --指定bootstrap服务的名称,snlua表示该服务是Lua服务,bootstrap服务用于启动skynet节点
start = "main"                --指定Skynet节点启动后运行的用户主程序,默认为main.lua,该脚本在bootstrap中最后一步执行

--路径配置--
root = "./"                     --设置基准路径,这里为当前目录
logpath = root.."service_msgs/" --运行时可将服务log功能打开,该服务接收的所有消息都会记录到这个目录下,名称为服务句柄字符串
luaservice = root.."service/?.lua;"..root.."test/?.lua;"..root.."examples/?.lua"
lualoader = "lualib/loader.lua"
cpath = root.."cservice/?.so"
snax = root.."examples/?.lua;"..root.."test/?.lua"

--节点配置--
harbor = 1                  --当前节点编号(1~255),skynet网络最大支持255个节点,0表示单节点网络(此时下列参数都无需配置)
address = "127.0.0.1:2526"  --当前节点的IP地址和端口
master = "127.0.0.1:2013"   --主节点的IP地址和端口,主节点会开启一个控制中心,用于监控所有其他节点
standalone = "0.0.0.0:2013" --指定这一项表示当前节点是主节点
```

**启动脚本**

```lua
local skynet = require "skynet"
local harbor = require "skynet.harbor"
require "skynet.manager"	-- import skynet.launch, ...
local memory = require "memory"

skynet.start(function()
	local sharestring = tonumber(skynet.getenv "sharestring")
	memory.ssexpand(sharestring or 4096)
	
	local standalone = skynet.getenv "standalone"
	
	local launcher = assert(skynet.launch("snlua","launcher"))
	skynet.name(".launcher", launcher)
	
	local harbor_id = tonumber(skynet.getenv "harbor")
	if harbor_id == 0 then
		assert(standalone ==  nil)
		standalone = true
		skynet.setenv("standalone", "true")
	
		local ok, slave = pcall(skynet.newservice, "cdummy")
		if not ok then
			skynet.abort()
		end
		skynet.name(".cslave", slave)
	
	else
		if standalone then
			if not pcall(skynet.newservice,"cmaster") then
				skynet.abort()
			end
		end
	
		local ok, slave = pcall(skynet.newservice, "cslave")
		if not ok then
			skynet.abort()
		end
		skynet.name(".cslave", slave)
	end
	
	if standalone then
		local datacenter = skynet.newservice "datacenterd"
		skynet.name("DATACENTER", datacenter)
	end
	skynet.newservice "service_mgr"
	pcall(skynet.newservice,skynet.getenv "start" or "main")
	skynet.exit()
end)
```

## 代码缓存

skynet修改了Lua的实现，加入了一个新特性可以让多个Lua VM共享相同的函数原型。
当同一个skynet进行中开启了大量的Lua VM时，这个特性可以节省不少内存，且提高
了VM的启动速度。

这个特性对用户是透明的，它改写了Lua的辅助函数luaL_loadfilex，所以直接或间接
调用这个接口的函数都会受其影响，入loadfile和require等。它以文件名为键，一旦
检索到之前加载过相同的Lua文件，则从内存中找到之前的加载的函数原型代替。例外的
是函数loadstring不受其影响，所以如果需要多次加载一个lua文件，可以使用io.open
打开文件，并使用load加载。

代码缓存采用的是只增加不删除的策略，也即一旦文件加载过，那么在进程结束前，它占据
的内存都不会释放（当然也不会被加载多次）。在大多数情况下，这不会有问题。

代码缓存有三种工作模式，"ON" "OFF" "EXIST"，其中默认模式为"ON"。"OFF"表示关闭
缓存，每次加载文件时都重新加载。"EXIST"表示加载已经加载过的文件使用缓存，但是加载
新的文件不适用缓存。这3中工作模式可以调用cache.mode(mode)进行设置。

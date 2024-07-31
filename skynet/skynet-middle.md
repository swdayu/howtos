
# 调用转换

Lua定义了一套规则完成Lua函数到C的调用，它首先将要调用的C函数放入栈中，并将C函数的参数
也依次放入栈中，然后执行C函数，C函数执行完后返回的结果也通过栈传递给Lua。也可以说Lua只
能调用满足规则的C函数，要在Lua中调到普通C函数，它们之间必须经过一次调用转换。首先在Lua
中调用满足规则的C函数，然后这些C函数再去调用普通C函数。

要在Lua中使用skynet的功能，需要先定义一个中间层完成调用转换，源文件lua-skynet.c即完成
这个功能，它定义一组满足规则的C函数，然后打包成Lua可以访问的动态库模块给Lua使用。
这些C函数专供Lua调用，并在函数内部调用底层skynet实现完成实际的功能。

# 核心函数（skynet.core）

```c
//@[luaopen_skynet_core]注册C函数给Lua使用
//传入参数：无
//返回结果：注册的函数表
int luaopen_skynet_core(lua_State* L) {
  luaL_checkversion(L); //检查创建Lua状态的Lua版本与调用该函数的Lua版本是否一致且在相同地址空间中
  luaL_Reg l[] = {
    { "send" , _send },
    { "genid", _genid },
    { "redirect", _redirect },
    { "command" , _command },
    { "intcommand", _intcommand },
    { "error", _error },
    { "tostring", _tostring },
    { "harbor", _harbor },
    { "pack", _luaseri_pack },
    { "unpack", _luaseri_unpack },
    { "packstring", lpackstring },
    { "trash" , ltrash },
    { "callback", _callback },
    { "now", lnow },
    { NULL, NULL },
  };
  luaL_newlibtable(L, l);                               //根据l的大小创建一个空table并压入栈中
  lua_getfield(L, LUA_REGISTRYINDEX, "skynet_context"); //获取registry_table["skynet_context"]并压入栈中
  struct skynet_context *ctx = lua_touserdata(L, -1);   //获取栈顶的skynet_context，确保它不为空
  if (ctx == NULL) {                                    //否则抛出异常
    return luaL_error(L, "Init skynet context first");
  }
  luaL_setfuncs(L, l, 1);                               //注册l中的函数到table中，设置共享上值skynet_context
  return 1;                                             //移除栈顶上值，保留注册后的table作为结果，返回结果个数
}

//@[_send]给指定服务发送消息
//传入参数：dest_name/hdl type session content_type (msg_string | msg_data msg_sz)
//返回结果：integer msg_session_id或无结果
static int _send(lua_State* L) {
  struct skynet_context* context = 
    lua_touserdata(L, lua_upvalueindex(1));      //TODO 获取当前服务的context
  uint32_t dest = (uint32_t)lua_tointeger(L, 1); //以整数形式获取目标服务的句柄
  const char* dest_str = NULL;
  if (dest == 0) {                               //如果目标服务的句柄获取失败
    if (lua_type(L,1) == LUA_TNUMBER) {          //且它的类型为整型，则报错并返回
      return luaL_error(L, 
        "Invalid service address 0");
    }
    dest_str = get_dest_string(L, 1);           //否则以字符串的形式获取目标服务的句柄
  }
  int type = luaL_checkinteger(L, 2);           //获取消息的类型
  int session = 0;
  if (lua_isnil(L, 3)) {                        //如果传入的session为nil
    type |= PTYPE_TAG_ALLOCSESSION;             //则设置一个标记表示自动分配session号
  } else {
    session = luaL_checkinteger(L, 3);          //否则以整数的形式获取到消息的session好
  }
  int mtype = lua_type(L, 4);                   //获取消息内容的类型
  switch (mtype) {
  case LUA_TSTRING: {                           //如果消息的内容是字符串
    size_t len = 0;
    void* msg = (void*)lua_tolstring(L,4,&len); //获取这个字符串以及长度
    if (len == 0) {                             //如果自负长长度为0，则将字符串设为空
      msg = NULL;
    }
    if (dest_str) {                             //如果目标服务句柄以字符串形式给出则调用skynet_sendname发送消息
      session = skynet_sendname(context, 0, dest_str, type, session , msg, len);
    } else {                                    //否则调用skynet_send发送这个消息
      session = skynet_send(context, 0, dest, type, session , msg, len);
    }
    break;
  }
  case LUA_TLIGHTUSERDATA: {                   //如果消息的内容为轻量用户数据
    void* msg = lua_touserdata(L, 4);          //获取这个消息的数据指针
    int size = luaL_checkinteger(L, 5);        //获取消息内容的长度
    if (dest_str) {                            //如果目标服务句柄以字符串的形式给出则调用skynet_sendname发送消息
      session = skynet_sendname(context, 0, dest_str, type | PTYPE_TAG_DONTCOPY, session, msg, size);
    } else {                                   //否则调用skynet_send发送消息
      session = skynet_send(context, 0, dest, type | PTYPE_TAG_DONTCOPY, session, msg, size);
    }
    break;
  }
  default:                                     //否则消息内容的类型错误，抛出异常
    luaL_error(L, "skynet.send invalid param %s", lua_typename(L, lua_type(L,4)));
  }
  if (session < 0) {                           //如果消息发送出错，则返回0表示该函数的没有结果返回
    // send to invalid address
    // todo: maybe throw an error would be better
    return 0;
  }
  lua_pushinteger(L, session);                 //否则将消息session号压入栈中，并返回1表示该函数返回一个结果
  return 1;
}

//@[_redirect]从源服务发送指定消息给目标服务
//传入参数：dest_name/hdl src_hdl type session content_type (msg_string | msg_data msg_sz)
//返回结果：无，另外与_send不同的是，该函数不会自动生成消息session号，需要明确指定
static int _redirect(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  uint32_t dest = (uint32_t)lua_tointeger(L, 1);
  const char* dest_string = NULL;
  if (dest == 0) {
    dest_string = get_dest_string(L, 1);
  }
  uint32_t source = (uint32_t)luaL_checkinteger(L, 2);
  int type = luaL_checkinteger(L, 3);
  int session = luaL_checkinteger(L, 4);
  int mtype = lua_type(L, 5);
  switch (mtype) {
    case LUA_TSTRING: {
      size_t len = 0;
      void* msg = (void*)lua_tolstring(L, 5, &len);
      if (len == 0) {
        msg = NULL;
      }
      if (dest_string) {
        session = skynet_sendname(context, source, dest_string, type, session , msg, len);
      } 
      else {
        session = skynet_send(context, source, dest, type, session , msg, len);
      }
      break;
    }
    case LUA_TLIGHTUSERDATA: {
      void* msg = lua_touserdata(L, 5);
      int size = luaL_checkinteger(L, 6);
      if (dest_string) {
        session = skynet_sendname(context, 
            source, dest_string, type | PTYPE_TAG_DONTCOPY, session, msg, size);
      } 
      else {
        session = skynet_send(context, source, dest, type | PTYPE_TAG_DONTCOPY, session, msg, size);
      }
      break;
    }
    default:
      luaL_error(L, "skynet.redirect invalid param %s", lua_typename(L,mtype));
  }
  return 0;
}

//@[_genid]生成一个消息session号并返回
//传入参数：无
//返回结果：integer session_id
static int _genid(lua_State* L) {
	struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
	int session = skynet_send(context, 0, 0, PTYPE_TAG_ALLOCSESSION , 0 , NULL, 0);
	lua_pushinteger(L, session); //将生成的session好压入栈中
	return 1;                    //返回1表示有一个结果返回
}

//@[_command]执行对应的skynet命令
//传入参数：lua_string cmd, lua_string cmd_parm
//返回结果：命令的字符串结果，如果发送错误则无结果
static int _command(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  const char* cmd = luaL_checkstring(L, 1);
  const char* result;          //以上获取服务的context以及传入的第一个参数
  const char* parm = NULL;
  if (lua_gettop(L) == 2) {    //如果有第二个参数则获取它，否则为NULL
    parm = luaL_checkstring(L, 2); 
  }                            //使用传入的参数调用底层函数skynet_command执行cmd
  result = skynet_command(context, cmd, parm);
  if (result) {
    lua_pushstring(L, result); //如果返回结果不为空表示执行成功，将名称入栈并返回结果个数1
    return 1;
  }
  return 0;                    //否则表示执行失败，返回结果个数0
}

//@[_intcommand]执行对应的skynet命令，与_command不同的是命令的参数是整数
//传入参数：lua_string cmd, integer cmd_parm
//返回结果：命令的整数结果，如果发送错误则无结果
static int _intcommand(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  const char* cmd = luaL_checkstring(L, 1);
  const char* result;       //以上获取服务的context以及传入的第一个参数
  const char* parm = NULL;
  char tmp[64];
  if (lua_gettop(L) == 2) { //如果有第二个参数则获取它，否则为NULL
    int32_t n = (int32_t)luaL_checkinteger(L, 2);
    sprintf(tmp, "%d", n);  //以整数的形式取得参数并格式化成字符串
    parm = tmp;
  }                         //使用传入的参数调用底层函数skynet_command执行cmd
  result = skynet_command(context, cmd, parm);
  if (result) {
    lua_Integer r = strtoll(result, NULL, 0);
    lua_pushinteger(L, r);  //如果返回结果不为空表示执行成功，将名称入栈并返回结果个数1
    return 1;
  }
  return 0;                 //否则表示执行失败，返回结果个数0
}

//@[_error]发送一条错误信息给logger服务
//传入参数：错误消息字符串
//返回结果：无
static int _error(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  skynet_error(context, "%s", luaL_checkstring(L,1));
  return 0; //以上获取错误信息字符串并调用底层函数skynet_error将信息发给logger服务
}

//@[_tostring]将给定长度的userdata转换成字符串
//传入参数：lua_userdata data, integer size
//返回结果：lua_string str
static int _tostring(lua_State* L) {
  if (lua_isnoneornil(L, 1)) {
    return 0;                       //如果参数为空则直接返回
  }
  char* msg = lua_touserdata(L, 1); //获取userdata
  int sz = luaL_checkinteger(L, 2); //获取数据长度
  lua_pushlstring(L, msg, sz);      //当成字符串压入栈中
  return 1;                         //结果个数为1
}

//@[_callback]设置服务的消息处理函数
//传入参数：lua_function lua_callback_fn, boolean forward
//返回结果：无
static int _callback(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  int forward = lua_toboolean(L, 2);           //获取第二个参数
  luaL_checktype(L, 1, LUA_TFUNCTION);         //确保第一个参数是Lua函数
  lua_settop(L, 1);                            //将栈中的参数调整为一个
  lua_rawsetp(L, LUA_REGISTRYINDEX, _cb);      //将registery_table[_cb]设置为lua_callback_fn
  lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
  lua_State* gL = lua_tothread(L, -1);         //获取主线程的指针gL
  if (forward) {                               //如果第一个参数（forward）为真
    skynet_callback(context, gL, forward_cb);  //设置服务的消息处理函数为forward_cb
  }                                            //并将主线程gL设置为函数的参数
  else {
    skynet_callback(context, gL, _cb);         //否则将服务的消息处理函数设置为_cb
  }                                            //并将主线程gL设为函数参数
  return 0;                                    //该函数不返回结果
}

//@[_harbor]获取harbor号以及是否为remote服务
//传入参数：integer handle
//返回结果：integer harbor, boolean remote
static int _harbor(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  uint32_t handle = (uint32_t)luaL_checkinteger(L, 1);
  int harbor = 0;             //获取栈中的参数handle并调用底层函数得到harbor和remote
  int remote = skynet_isremote(context, handle, &harbor);
  lua_pushinteger(L, harbor); //将harbor入栈
  lua_pushboolean(L, remote); //将remote入栈
  return 2;                   //结果个数为2
}

//@[ltrash]释放传入的对象内存
//传入参数：lua_string string 或 lua_userdata data, integer size
//返回结果：无
static int ltrash(lua_State* L) {
  int t = lua_type(L, 1);
  switch (t) {
    case LUA_TSTRING: {        //如果传入的是Lua字符串，因为Lua垃圾回收机制会自动回收
      break;                   //不需要释放直接返回
    }
    case LUA_TLIGHTUSERDATA: { //如果传入的是用户数据对象
      void* msg = lua_touserdata(L, 1);
      luaL_checkinteger(L, 2); //获取该对象指针，并检查第2个参数确保其类型是整型
      skynet_free(msg);        //释放用户数据对象
      break;
    }
    default:                   //如果传入的是其他类型，抛出错误
      luaL_error(L, "skynet.trash invalid param %s", lua_typename(L,t));
  }
  return 0;                    //该函数没有返回结果
}

//@[lnow]获取skynet启动后到现在的时间，单位为10毫秒
//传入参数：无
//返回结果：integer time
static int lnow(lua_State* L) {
  uint64_t ti = skynet_now();
  lua_pushinteger(L, ti);
  return 1;
}

//@[lpackstring]将任意个数Lua值打包成Lua字符串
//传入参数：任意个数的Lua值
//返回结果：lua_string pack_str
static int lpackstring(lua_State* L) {
  _luaseri_pack(L);              //将栈中的Lua值打包成一个userdata和长度值压入栈中
  char* str = (char*)lua_touserdata(L, -2);
  int sz = lua_tointeger(L, -1); //获取栈中的userdata和长度值
  lua_pushlstring(L, str, sz);   //将userdata转换成Lua字符串压入栈中
  skynet_free(str);              //将userdata的内存释放掉
  return 1;                      //栈中的结果个数为1
}

//@[_luaseri_pack]将栈中任意个数Lua值打包成userdata和长度值
//传入参数：任意个数Lua值
//返回结果：lua_userdata data, integer size
int _luaseri_pack(lua_State* L) {
  struct block temp;        //{block* next; char buffer[128];}
  temp.next = NULL;
  struct write_block wb;    //{block* head; block* current; int len, ptr;}
  wb_init(&wb, &temp);      //wb.head = wb.current = &temp; wb.len = wb.ptr = 0;
  pack_from(L, &wb, 0);     //将栈中的Lua值打包成block链表 TODO
  assert(wb.head == &temp);
  seri(L, &temp, wb.len);   //将block链表中的所有数据拷贝到一块内存中，并将内存指针和数据长度压入栈中
  wb_free(&wb);             //释放wb.head->next链表中的block节点
  return 2;                 //栈中的结果个数为2
}

//@[_luaseri_unpack]从Lua字符串或用户数据中解析出所有的Lua值
//传入参数：lua_string str or (lua_userdata data, integer size)
//返回结果：lua_string str or lua_userdata data, 后面为解出的所有Lua值
int _luaseri_unpack(lua_State* L) {
  if (lua_isnoneornil(L, 1)) {         //如果第一个参数为空
    return 0;                          //直接返回
  }
  void* buffer;
  int len;
  if (lua_type(L, 1) == LUA_TSTRING) { //如果第一个参数是Lua字符串
    size_t sz;
    buffer = (void*)lua_tolstring(L, 1, &sz);
    len = (int)sz;                     //获取这个字符串和它的长度
  } 
  else {                               //否则栈中的参数是userdata以及长度
    buffer = lua_touserdata(L, 1);     //获取userdata指针
    len = luaL_checkinteger(L, 2);     //和data的长度
  }
  if (len == 0) {                      //如果字符串长度或userdata长度为0
    return 0;                          //直接返回
  }
  if (buffer == NULL) {                //如果字符串指针或数据指针为空则抛出异常
    return luaL_error(L, "deserialize null pointer");
  }
  lua_settop(L, 1);                    //保留栈中的第一个参数
  struct read_block rb;                //{char* buffer; int len, ptr;}
  rball_init(&rb, buffer, len);        //rb.buffer = buffer; rb.len = len; rb.ptr = 0;
  int i;
  for (i=0; ; i++) {
    if (i%8 == 7) {                    //确保栈中有足够的空间
      luaL_checkstack(L, LUA_MINSTACK, NULL);
    }
    uint8_t type = 0;                  //读取当前数据的类型（第1个字节）
    uint8_t* t = rb_read(&rb, sizeof(type));
    if (t == NULL)
      break;
    type = *t;                         //根据类型从数据中解析一个值放入栈中
    push_value(L, &rb, type & 0x7, type>>3); 
  }
  // Need not free buffer
  return lua_gettop(L) - 1;            //返回解析出的值的个数
}
```

# 数据打包


# 性能刨析（profile）

```c
//@[luaopen_profile]注册Profile的C函数给Lua使用
//传入参数：无
//返回结果：注册的函数表
int luaopen_profile(lua_State* L) {
  luaL_checkversion(L);
  luaL_Reg l[] = {
    {"start", lstart},           //拥有3个上值：start_time_table, total_time_table, nil
    {"stop", lstop},             //拥有3个上值：start_time_table, total_time_table, nil
    {"resume", lresume},         //拥有3个上值：start_time_table, total_time_table, coroutine.resume
    {"yield", lyield},           //拥有3个上值：start_time_table, total_time_table, coroutine.yield
    {"resume_co", lresume_co},   //拥有3个上值：start_time_table, total_time_table, coroutine.resume
    {"yield_co", lyield_co},     //拥有3个上值：start_time_table, total_time_table, coroutine.yield
    {NULL, NULL},                //其中start_time_table和total_time_table的元表是一个weak_table
  };
  luaL_newlibtable(L, l);                  //根据l的大小创建一个空table（funcs_table）入栈
  lua_newtable(L);                         //创建一个新table（start_time_table）入栈
  lua_newtable(L);                         //创建一个新table（total_time_table）入栈
  lua_newtable(L);                         //创建一个新table（weak_table）入栈
  lua_pushliteral(L, "kv");                //将字符串"kv"入栈
  lua_setfield(L, -2, "__mode");           //设置weak_table的mode为kv，其键和值都是弱键和弱值，并将"kv"移除
  lua_pushvalue(L, -1);                    //将weak_table复制一份入栈
  lua_setmetatable(L, -3);                 //将weak_table设置成total_time_table的元表，并移除一个weak_table
  lua_setmetatable(L, -3);                 //将weak table设置成start_time_table的元表，移除第二个weak_table
  lua_pushnil(L);                          //将nil入栈，当前栈中元素：[funcs/start_time/total_time, nil]
  luaL_setfuncs(L, l, 3);                  //将l中的函数注册到funcs_table中，设置函数共享栈顶的3个上值
  int libtable = lua_gettop(L);            //获取当前栈元素个数，此时栈顶元素为funcs_table
  lua_getglobal(L, "coroutine");           //将全局变量coroutine入栈
  lua_getfield(L, -1, "resume");           //将coroutine.resume入栈（Lua标准resume函数）
  lua_CFunction co_resume = lua_tocfunction(L, -1);
  if (co_resume == NULL)                   //将栈顶resume函数保存到co_resume中，如果为NULL则抛出错误
    return luaL_error(L, "Can't get coroutine.resume");
  lua_pop(L, 1);                           //将栈顶resume函数移除
  lua_getfield(L, libtable, "resume");     //将funcs_table中resume域对应的值（lresume）入栈
  lua_pushcfunction(L, co_resume);         //将co_resume入栈
  lua_setupvalue(L, -2, 3);                //将lresume的第3个上值设置为co_resume，并将co_resume移除出栈
  lua_pop(L, 1);                           //将lresume出栈
  lua_getfield(L, libtable, "resume_co");  //将funcs_table中resume_co域对应的值（lresume_co）入栈
  lua_pushcfunction(L, co_resume);         //将co_resume入栈
  lua_setupvalue(L, -2, 3);                //将lresume_co的第3个上值设置为co_resume，并将co_resume移除出栈
  lua_pop(L, 1);                           //将lresume_co出栈
  lua_getfield(L, -1, "yield");            //将coroutine.yield函数入栈（Lua标准yield函数）
  lua_CFunction co_yield = lua_tocfunction(L, -1);
  if (co_yield == NULL)                    //将栈顶yield函数保存到co_yield中，如果为NULL则抛出错误
    return luaL_error(L, "Can't get coroutine.yield");
  lua_pop(L, 1);                           //将yield移除出栈
  lua_getfield(L, libtable, "yield");      //将funcs_table中的yield域对应的值（lyield）入栈
  lua_pushcfunction(L, co_yield);          //将co_yield入栈
  lua_setupvalue(L, -2, 3);                //将lyield的第3个上值设置为co_yield，并将co_yield移除出栈
  lua_pop(L, 1);                           //将lyield移除出栈
  lua_getfield(L, libtable, "yield_co");   //将funcs_table中的yield_co域对应的值（lyield_co）入栈
  lua_pushcfunction(L, co_yield);          //将co_yield入栈
  lua_setupvalue(L, -2, 3);                //将lyield_co的第3个上值设置为co_yield，并将co_yield移除出栈
  lua_pop(L,1);                            //将lyield移除出栈
  lua_settop(L, libtable);                 //调整参数个数仅剩funcs_table
  return 1;                                //返回结果个数1
}

//@[get_time]获取当前线程运行时间，单位为秒
static double get_time() {
#if !defined(__APPLE__)
  struct timespec ti;
  clock_gettime(CLOCK_THREAD_CPUTIME_ID, &ti);
  int sec = ti.tv_sec & 0xffff;
  int nsec = ti.tv_nsec;
  return (double)sec + (double)nsec / NANOSEC;	
#else
  struct task_thread_times_info aTaskInfo;
  mach_msg_type_number_t aTaskInfoCount = TASK_THREAD_TIMES_INFO_COUNT;
  if (task_info(mach_task_self(), TASK_THREAD_TIMES_INFO, 
        (task_info_t )&aTaskInfo, &aTaskInfoCount) != KERN_SUCCESS) {
    return 0;
  }
  int sec = aTaskInfo.user_time.seconds & 0xffff;
  int msec = aTaskInfo.user_time.microseconds;
  return (double)sec + (double)msec / MICROSEC;
#endif
}

//@[diff_time]获取从start时间点到现在的时间间隔
static inline double diff_time(double start) {
  double now = get_time();
  if (now < start) { //TODO
    return now + 0x10000 - start;
  }
  else {
    return now - start;
  }
}

//@[lstart]将total_time_table[L]初始化为0，将start_time_table[L]设置为当前时间
static int lstart(lua_State* L) {
  if (lua_type(L,1) == LUA_TTHREAD) {
    lua_settop(L,1);                  //如果第1个参数是协程，将参数调整为1个
  } 
  else {
    lua_pushthread(L);                //否则将协程L压入栈中
  }
  lua_rawget(L, lua_upvalueindex(2)); //将total_time_table[L]入栈，并将L移除
  if (!lua_isnil(L, -1)) {            //如果total_time不为nil表示已经开启了profiling，抛出错误
    return luaL_error(L, "Thread %p start profile more than once", lua_topointer(L, 1));
  }
  lua_pushthread(L);                  //将协程L入栈
  lua_pushnumber(L, 0);               //将0入栈
  lua_rawset(L, lua_upvalueindex(2)); //设置total_time_table[L] = 0，并将L和0移除出栈
  lua_pushthread(L);                  //将协程L入栈
  double ti = get_time();             //获取当前时间保持到ti
#ifdef DEBUG_LOG
  fprintf(stderr, "PROFILE [%p] start\n", L);
#endif
  lua_pushnumber(L, ti);              //将当前时间ti入栈
  lua_rawset(L, lua_upvalueindex(1)); //设置start_time_table[L] = ti为当前时间，并将L和ti移除出栈
  return 0;                           //该函数不返回结果
}

//@[lstop]获取时间间隔，并将start_time_table[L]和total_time_table[L]设为nil
//传入参数：无
//返回结果：total_time + lstart到lstop的时间间隔
static int lstop(lua_State* L) {
  if (lua_type(L, 1) == LUA_TTHREAD) {
    lua_settop(L, 1);                   //第1个参数如果是协程，将参数个数调整到1个
  } 
  else {
    lua_pushthread(L);                  //否则将协程L压入栈中
  }
  lua_rawget(L, lua_upvalueindex(1));   //将start_time_table[L]入栈，并将L移除出栈
  if (lua_type(L, -1) != LUA_TNUMBER) { //如果start_time不是数值类型，抛出错误
    return luaL_error(L, "Call profile.start() before profile.stop()");
  }                                     //计算start_time到现在的时间差ti
  double ti = diff_time(lua_tonumber(L, -1));
  lua_pushthread(L);                    //将协程L入栈
  lua_rawget(L, lua_upvalueindex(2));   //将total_time_table[L]入栈并保存到total_time，并将L移除出栈
  double total_time = lua_tonumber(L, -1);
  lua_pushthread(L);                    //将协程L入栈
  lua_pushnil(L);                       //将nil入栈
  lua_rawset(L, lua_upvalueindex(1));   //设置start_time_table[L] = nil，并将L和nil出栈
  lua_pushthread(L);                    //将协程L入栈
  lua_pushnil(L);                       //将nil入栈
  lua_rawset(L, lua_upvalueindex(2));   //设置total_time_table[L] = nil，并将L和nil出栈
  total_time += ti;                     //total_time加上当前的差值ti
  lua_pushnumber(L, total_time);        //将获取的total_time入栈
#ifdef DEBUG_LOG
  fprintf(stderr, "PROFILE [%p] stop (%lf / %lf)\n", L, ti, total_time);
#endif
  return 1;                             //返回1个结果
}

//@[timing_resume]除resume协程外还会记录协程的启动时间
//标准resume函数的参数：coroutine.resume(co [, val1, ...])
static int timing_resume(lua_State* L) {
#ifdef DEBUG_LOG
  lua_State* from = lua_tothread(L, -1);
#endif
  lua_rawget(L, lua_upvalueindex(2));   //将total_time_table[top_arg]入栈，并将top_arg移除
  if (lua_isnil(L, -1)) {		//如果total_time为nil
    lua_pop(L, 1);                      //将其从栈中移除，不会进行时间计算直接运行下面的resume函数
  }
  else {
    lua_pop(L, 1);                      //否则total_time不为nil，将其从栈中移除，开始计算时间
    lua_pushvalue(L, 1);                //将第1个参数拷贝一份压入栈中
    double ti = get_time();             //获取当前时间
  #ifdef DEBUG_LOG
    fprintf(stderr, "PROFILE [%p] resume\n", from);
  #endif
    lua_pushnumber(L, ti);              //将当前时间入栈，当前参数[1st_arg, ti]
    lua_rawset(L, lua_upvalueindex(1));	//start_time_table[1st_arg] = ti，会将[1st_arg, ti]移除出栈
  }                                     //获取resume函数（Lua标准resume函数）
  lua_CFunction co_resume = lua_tocfunction(L, lua_upvalueindex(3));
  return co_resume(L);                  //resume协程
}

//@[lresume]
static int lresume(lua_State* L) {
  lua_pushvalue(L, 1);     //将第1个参数拷贝一份入栈
  return timing_resume(L); //调用timing_resume
}

//@[lresume_co]
static int lresume_co(lua_State* L) {
  luaL_checktype(L, 2, LUA_TTHREAD); //确保第2个参数是协程
  lua_rotate(L, 2, -1);    //第2个参数与栈顶之间的参数向栈底方向循环移动1位（第2个参数移动到栈顶）
  return timing_resume(L); //调用timing_resume
}

//@[timing_yield]除yield协程外还会记录协程的运行时间
//标准yield函数的参数：coroutine.yield([res1, ...])
static int timing_yield(lua_State* L) {
#ifdef DEBUG_LOG
  lua_State* from = lua_tothread(L, -1);
#endif
  lua_rawget(L, lua_upvalueindex(2));       //将total_time_table[top_arg]入栈，并将top_arg移除
  if (lua_isnil(L, -1)) {                   //如果total_time为nil
    lua_pop(L,1);                           //将其移除出栈，不会进行时间计算直接运行下面的yield函数
  }
  else {                                    //否则total_time不为nil
    double ti = lua_tonumber(L, -1);        //将total_time保存到ti
    lua_pop(L, 1);                          //移total_time移除出栈，开始计算时间
    lua_pushthread(L);                      //将协程L入栈
    lua_rawget(L, lua_upvalueindex(1));     //将start_time_table[L]入栈，并将L移除出栈
    double starttime = lua_tonumber(L, -1); //将start_time保存到starttime
    lua_pop(L, 1);                          //将start_time移除出栈
    double diff = diff_time(starttime);     //获取starttime到现在的时间间隔diff
    ti += diff;                             //将时间间隔加入到ti中
#ifdef DEBUG_LOG
    fprintf(stderr, "PROFILE [%p] yield (%lf/%lf)\n", from, diff, ti);
#endif
    lua_pushthread(L);                      //将协程L入栈
    lua_pushnumber(L, ti);                  //将总体时间ti入栈
    lua_rawset(L, lua_upvalueindex(2));     //设置total_time_table[L] = ti，并将ti和L移除
  }                                         //获取yield函数（Lua标准yiel函数）
  lua_CFunction co_yield = lua_tocfunction(L, lua_upvalueindex(3));
  return co_yield(L);                       //yield协程
}

//@[lyield]
static int lyield(lua_State* L) {
  lua_pushthread(L);      //将协程L入栈
  return timing_yield(L); //调用timing_yield
}

//@[lyield_co]
static int lyield_co(lua_State* L) {
  luaL_checktype(L, 1, LUA_TTHREAD); //确保第1个参数为协程
  lua_rotate(L, 1, -1);              //将第1个参数移到栈顶
  return timing_yield(L);            //调用timing_yield
}
```

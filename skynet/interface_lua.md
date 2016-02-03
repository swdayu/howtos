
# 调用转换

Lua定义了一套规则完成Lua函数到C的调用，它首先将要调用的C函数放入栈中，并将C函数的参数
也依次放入栈中，然后执行C函数，C函数执行完后返回的结果也通过栈传递给Lua。也可以说Lua只
能调用满足规则的C函数，要在Lua中调到普通C函数，它们之间必须经过一次调用转换。首先在Lua
中调用满足规则的C函数，然后这些C函数再去调用普通C函数。

要在Lua中使用skynet的功能，需要先定义一个中间层完成调用转换，源文件lua-skynet.c即完成
这个功能，它定义一组满足规则的C函数，然后打包成Lua可以访问的动态库模块给Lua使用。
这些C函数专供Lua调用，并在函数内部调用底层普通的C函数完成实际的功能。

```c
//@[_send]给指定服务发送消息
//传入参数：dest_hdl type session content_type (msg_string | msg_data msg_sz)
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
//传入参数：src_hdl dest_hdl type session content_type (msg_string | msg_data msg_sz)
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
//返回结果：lua_string service_name或无结果
static int _command(lua_State* L) {
  struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
  const char* cmd = luaL_checkstring(L, 1);
  const char* result;          //以上获取服务的context以及传入的第一个参数
  const char* parm = NULL;
  if (lua_gettop(L) == 2) {    //如果有第二个参数则获取它，否则为NULL
    parm = luaL_checkstring(L, 2); 
  }                            //使用传入的参数调用底层函数skynet_command执行cmd
  result = skynet_command(context, cmd, parm);
  if (result) {                //函数会返回":hex_str_of_service_handle"或".service_name"形式的名称
    lua_pushstring(L, result); //如果返回结果不为空表示执行成功，将名称入栈并返回结果个数1
    return 1;
  }
  return 0;                    //否则表示执行失败，返回结果个数0
}

//@[_intcommand]执行对应的skynet命令，与_command不同的是命令的参数是整数
//传入参数：lua_string cmd, integer cmd_parm
//返回结果：integer handle或无结果
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
  if (result) {             //函数会返回":hex_str_of_service_handle"或".service_name"形式的名称
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

//@[luaopen_skynet_core] skynet.core open function
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

//@[luaopen_profile] profile open function defined in lua-profile.c
int luaopen_profile(lua_State* L) {
  luaL_checkversion(L);
  luaL_Reg l[] = {
    { "start", lstart },
    { "stop", lstop },
    { "resume", lresume },
    { "yield", lyield },
    { "resume_co", lresume_co },
    { "yield_co", lyield_co },
    { NULL, NULL },
  };
  luaL_newlibtable(L,l);
  lua_newtable(L);	// table thread->start time
  lua_newtable(L);	// table thread->total time

  lua_newtable(L);	// weak table
  lua_pushliteral(L, "kv");
  lua_setfield(L, -2, "__mode");

  lua_pushvalue(L, -1);
  lua_setmetatable(L, -3); 
  lua_setmetatable(L, -3);

  lua_pushnil(L);	// cfunction (coroutine.resume or coroutine.yield)
  luaL_setfuncs(L,l,3);

  int libtable = lua_gettop(L);

  lua_getglobal(L, "coroutine");
  lua_getfield(L, -1, "resume");

  lua_CFunction co_resume = lua_tocfunction(L, -1);
  if (co_resume == NULL)
    return luaL_error(L, "Can't get coroutine.resume");
  lua_pop(L,1);

  lua_getfield(L, libtable, "resume");
  lua_pushcfunction(L, co_resume);
  lua_setupvalue(L, -2, 3);
  lua_pop(L,1);

  lua_getfield(L, libtable, "resume_co");
  lua_pushcfunction(L, co_resume);
  lua_setupvalue(L, -2, 3);
  lua_pop(L,1);

  lua_getfield(L, -1, "yield");

  lua_CFunction co_yield = lua_tocfunction(L, -1);
  if (co_yield == NULL)
    return luaL_error(L, "Can't get coroutine.yield");
  lua_pop(L,1);

  lua_getfield(L, libtable, "yield");
  lua_pushcfunction(L, co_yield);
  lua_setupvalue(L, -2, 3);
  lua_pop(L,1);

  lua_getfield(L, libtable, "yield_co");
  lua_pushcfunction(L, co_yield);
  lua_setupvalue(L, -2, 3);
  lua_pop(L,1);

  lua_settop(L, libtable);

  return 1;
}
```

```lua
      2.6951  7420.94 20000 20000.00
15.92 2.2660  7420.94 20000 16815.85
+2.48 2.2099 20914.76 50000 46219.52 2.4026 +8.72
+4.85 2.1560 21252.10 50000 45819.52 2.3644 +9.66

local c = require "skynet.core"
local profile = require "profile"
local coroutine_resume = profile.resume
local coroutine_yield = profile.yield
local proto = {}

local skynet = {
  -- read skynet.h
  PTYPE_TEXT = 0,
  PTYPE_RESPONSE = 1,
  PTYPE_MULTICAST = 2,
  PTYPE_CLIENT = 3,
  PTYPE_SYSTEM = 4,
  PTYPE_HARBOR = 5,
  PTYPE_SOCKET = 6,
  PTYPE_ERROR = 7,
  PTYPE_QUEUE = 8,	-- used in deprecated mqueue, use skynet.queue instead
  PTYPE_DEBUG = 9,
  PTYPE_LUA = 10,
  PTYPE_SNAX = 11,
}
skynet.cache = require "skynet.codecache"

function skynet.register_protocol(class)
  local name = class.name
  local id = class.id
  assert(proto[name] == nil) --字符串名字class.name必须没有注册过，数字class.id必须在范围[0, 255]内
  assert(type(name) == "string" and type(id) == "number" and id >=0 and id <=255)
  proto[name] = class        --使用class.name可以访问到class这个对象
  proto[id] = class          --使用class.id也可以访问到class这个对象
end

--@[string_to_handle]例如将":10"转换成"0x10"再转换成16
local function string_to_handle(str)
  return tonumber("0x" .. string.sub(str, 2))
end
```


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
//栈中的参数：dest_hdl type session content_type (msg_string | msg_data msg_sz)
static int _send(lua_State *L) {
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
  if (lua_isnil(L,3)) {                         //如果传入的session为nil
    type |= PTYPE_TAG_ALLOCSESSION;             //则设置一个标记表示自动分配session号
  } else {
    session = luaL_checkinteger(L,3);           //否则以整数的形式获取到消息的session好
  }
  int mtype = lua_type(L,4);                    //获取消息内容的类型
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
    void* msg = lua_touserdata(L,4);           //获取这个消息的数据指针
    int size = luaL_checkinteger(L,5);         //获取消息内容的长度
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
  lua_pushinteger(L,session);                 //否则将消息session号压入栈中，并返回1表示该函数返回一个结果
  return 1;
}

//@[_redirect]从源服务发送指定消息给目标服务
//栈中的参数：src_hdl dest_hdl type session content_type (msg_string | msg_data msg_sz)
//另外与_send不同的是，该函数不会自动生成消息session号，需要明确指定
static int _redirect(lua_State* L) {
	struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
	uint32_t dest = (uint32_t)lua_tointeger(L,1);
	const char* dest_string = NULL;
	if (dest == 0) {
	  dest_string = get_dest_string(L, 1);
	}
	uint32_t source = (uint32_t)luaL_checkinteger(L,2);
	int type = luaL_checkinteger(L,3);
	int session = luaL_checkinteger(L,4);
	int mtype = lua_type(L,5);
	switch (mtype) {
	case LUA_TSTRING: {
	  size_t len = 0;
	  void * msg = (void *)lua_tolstring(L,5,&len);
	  if (len == 0) {
	    msg = NULL;
	  }
	  if (dest_string) {
	    session = skynet_sendname(context, source, dest_string, type, session , msg, len);
	  } else {
	    session = skynet_send(context, source, dest, type, session , msg, len);
	  }
	  break;
	}
	case LUA_TLIGHTUSERDATA: {
	  void * msg = lua_touserdata(L,5);
	  int size = luaL_checkinteger(L,6);
	  if (dest_string) {
	    session = skynet_sendname(context, source, dest_string, type | PTYPE_TAG_DONTCOPY, session, msg, size);
	  } else {
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
static int _genid(lua_State* L) {
	struct skynet_context* context = lua_touserdata(L, lua_upvalueindex(1));
	int session = skynet_send(context, 0, 0, PTYPE_TAG_ALLOCSESSION , 0 , NULL, 0);
	lua_pushinteger(L, session); //将生成的session好压入栈中
	return 1;                    //返回1表示有一个结果返回
}


```




```c
//@[luaopen_skynet_core] skynet.core open function defined in lua-skynet.c
int luaopen_skynet_core(lua_State* L) {
  luaL_checkversion(L); //检查创建Lua状态的Lua版本与调用该函数的Lua版本是否一致，且是否在相同的地址空间中
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

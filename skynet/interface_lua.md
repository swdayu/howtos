
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
static int _send(lua_State *L) {
  struct skynet_context * context = lua_touserdata(L, lua_upvalueindex(1));
  uint32_t dest = (uint32_t)lua_tointeger(L, 1);
  const char * dest_string = NULL;
  if (dest == 0) {
    if (lua_type(L,1) == LUA_TNUMBER) {
      return luaL_error(L, "Invalid service address 0");
    }
    dest_string = get_dest_string(L, 1);
  }
  int type = luaL_checkinteger(L, 2);
  int session = 0;
  if (lua_isnil(L,3)) {
    type |= PTYPE_TAG_ALLOCSESSION;
  } else {
    session = luaL_checkinteger(L,3);
  }
  int mtype = lua_type(L,4);
  switch (mtype) {
  case LUA_TSTRING: {
    size_t len = 0;
    void * msg = (void *)lua_tolstring(L,4,&len);
    if (len == 0) {
      msg = NULL;
    }
    if (dest_string) {
      session = skynet_sendname(context, 0, dest_string, type, session , msg, len);
    } else {
      session = skynet_send(context, 0, dest, type, session , msg, len);
    }
    break;
  }
  case LUA_TLIGHTUSERDATA: {
    void * msg = lua_touserdata(L,4);
    int size = luaL_checkinteger(L,5);
    if (dest_string) {
      session = skynet_sendname(context, 0, dest_string, type | PTYPE_TAG_DONTCOPY, session, msg, size);
    } else {
      session = skynet_send(context, 0, dest, type | PTYPE_TAG_DONTCOPY, session, msg, size);
    }
    break;
  }
  default:
    luaL_error(L, "skynet.send invalid param %s", lua_typename(L, lua_type(L,4)));
  }
  if (session < 0) {
    // send to invalid address
    // todo: maybe throw an error would be better
    return 0;
  }
  lua_pushinteger(L,session);
  return 1;
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

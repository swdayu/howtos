
```c
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
```

```lua
      2.6951  7420.94 20000 20000.00
15.92 2.2660  7420.94 20000 16815.85
+2.48 2.2099 20914.76 50000 46219.52 2.4026 +8.72
+4.85 2.1560 21252.10 50000 45819.52 2.3644 +9.66

local c = require "skynet.core"
```

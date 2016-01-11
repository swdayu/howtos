
```c
int luaopen_skynet_core(lua_State* L) {
  luaL_checkversion(L);
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
  struct skynet_context *ctx = lua_touserdata(L, -1);   //获取栈顶的skynet_context，用来检查skynet_context，保证它不为空
  if (ctx == NULL) {                                    //否则抛出Lua异常
    return luaL_error(L, "Init skynet context first");
  }                                                     //注册l中的函数到空table中，并设置函数共享上值skynet_context
  luaL_setfuncs(L, l, 1);                               //设置后，移除栈顶的上值，最后只剩注册好的table留在栈中作为结果
  return 1;                                             //返回结果的个数
}
```

```lua
local c = require "skynet.core"
```

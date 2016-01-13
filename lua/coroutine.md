
# 协程

```c
//@[local coroutine = require "coroutine"]
static const luaL_Reg co_funcs[] = {
  {"create", luaB_cocreate},
  {"resume", luaB_coresume},
  {"running", luaB_corunning},
  {"status", luaB_costatus},
  {"wrap", luaB_cowrap},
  {"yield", luaB_yield},
  {"isyieldable", luaB_yieldable},
  {NULL, NULL}
};
int luaopen_coroutine (lua_State* L) {
  luaL_newlib(L, co_funcs); //创建并注册函数到新table中，保留table在栈顶作为结果
  return 1;                 //返回结果个数
}

//@[local co = coroutine.create(luafn)]传入Lua函数，返回新创建的协程
static int luaB_cocreate(lua_State* L) {
  lua_State* NL;
  luaL_checktype(L, 1, LUA_TFUNCTION); //传入的参数必须是Lua函数
  NL = lua_newthread(L);               //创建线程压入L的栈中，NL共享L的全局状态但拥有自己独立的Lua栈
  lua_pushvalue(L, 1);                 //将传入的Lua函数拷贝一份压入L栈顶
  lua_xmove(L, NL, 1);                 //将L栈顶的Lua函数移除，并将它压入NL栈顶
  return 1;                            //此时L栈顶元素为新分配的NL，将它最为结果，返回结果个数1
}

//@[coroutine.resume(co [, val1, ...])]
//如果协程第一次运行，则运行协程对应的Lua函数，将val1,...传入作为Lua函数的参数
//If the coroutine runs without any errors, resume returns true plus any values passed to yield 
//(when the coroutine yields) or any values returned by the body function (when the coroutine terminates). 
//If there is any error, resume returns false plus the error message.
//如果协程处于yield状态，则恢复到原来yield的位置继续执行，传入的参数val1,...会作为yield函数的返回结果
static int luaB_coresume(lua_State* L) {
  lua_State* co = getco(L);
  int r = auxresume(L, co, lua_gettop(L) - 1);
  if (r < 0) {
    lua_pushboolean(L, 0);
    lua_insert(L, -2);
    return 2;  /* return false + error message */
  }
  else {
    lua_pushboolean(L, 1);
    lua_insert(L, -(r + 1));
    return r + 1;  /* return true + 'resume' returns */
  }
}
```

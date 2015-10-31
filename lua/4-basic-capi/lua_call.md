

```c
#define lua_call(L,n,r)		lua_callk(L, (n), (r), 0, NULL)

void lua_callk(lua_State *L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k) {
  StkId func;
  lua_lock(L);
  api_check(L, k == NULL || !isLua(L->ci), "cannot use continuations inside hooks");
  api_checknelems(L, nargs+1);
  api_check(L, L->status == LUA_OK, "cannot do calls on non-normal thread");
  checkresults(L, nargs, nresults);
  func = L->top - (nargs+1);
  if (k != NULL && L->nny == 0) {  /* need to prepare continuation? */
    L->ci->u.c.k = k;  /* save continuation */
    L->ci->u.c.ctx = ctx;  /* save context */
    luaD_call(L, func, nresults, 1);  /* do the call */
  }
  else  /* no continuation or no yieldable */
    luaD_call(L, func, nresults, 0);  /* just do the call */
  adjustresults(L, nresults);
  lua_unlock(L);
}
```


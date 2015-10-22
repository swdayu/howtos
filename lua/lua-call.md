
# Functions
```
#define lua_call(L,n,r) lua_callk(L, (n), (r), 0, NULL)
#define lua_pcall(L,n,r,f) lua_pcallk(L, (n), (r), (f), 0, NULL)
void lua_callk(lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k);
int lua_pcallk(lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k);
```


# References
- http://www.lua.org/manual/5.3/manual.html#4.8

# Functions to Run Lua Code
```
#define lua_call(L,n,r) lua_callk(L, (n), (r), 0, NULL)
void lua_callk(lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k);
#define lua_pcall(L,n,r,f) lua_pcallk(L, (n), (r), (f), 0, NULL)
int lua_pcallk(lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx, lua_KFunction k);
```

# lua_call
```
void lua_call(lua_State* L, int nargs, int nresults);
```
To call a function you must use the following protocol: 
- first, the function to be called is pushed onto the stack
- then, the arguments to the function are pushed in direct order; that is, the first argument is pushed first
- finally you call lua_call; nargs is the number of arguments that you pushed onto the stack 

All arguments and the function value are popped from the stack when the function is called. 
The function results are pushed onto the stack when the function returns. 
The number of results is adjusted to nresults, unless nresults is LUA_MULTRET. 
In this case, all results from the function are pushed.
The function results are pushed onto the stack in direct order (the first result is pushed first), 
so that after the call the last result is on the top of the stack.

Any error inside the called function is propagated upwards (with a longjmp).

Function `lua_callk` has two extra parameters `lua_KContext ctx, lua_KFunction k`, 
and allows the called function to yield.

# lua_pcall

```
int lua_pcall(lua_State* L, int nargs, int nresults, int errfunc);
```
Run code in protected mode, i.e., if there is any error, `lua_pcall` will catch it,
and pushes a single value on the stack (the error message), and returns an error code.

If `errfunc` is 0, then the error message returned on the stack is exactly the original error message.
Otherwise, `errfunc` is the stack index of a *message handler*.

The return value is one of the following constants defined in `lua.h`:
- LUA_OK (0): success
- LUA_ERRRUN: a runtime error
- LUA_ERRMEM: memory allocation error, for such errors, lua does not call the message handler
- LUA_ERRERR: error while running the message handler
- LUA_ERRGCMM: error while running a __gc metamethod, this error typically has no relation with the function being called

Function `lua_pcallk` has two extra parameters `lua_KContext ctx, lua_KFunction k`, 
and allows the called function to yield.

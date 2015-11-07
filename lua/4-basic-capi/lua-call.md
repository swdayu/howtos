
# C API

## lua_call
```c
void lua_call(lua_State* L, int nargs, int nresults);
```
To call a function you must use the following protocol: first, the function to be called is pushed onto the stack;
then, the arguments to the function are pushed in direct order; that is, the first argument is pushed first.
Finally you call `lua_call`; `nargs` is the number of arguments that you pushed onto the stack.
All arguments and the function value are popped from the stack when the function is called.
The function results are pushed onto the stack when the function returns.
The number of results is adjust to `nresults`, unless `nresults` is LUA_MULTRET.
In this case, all results from the function are pushed.
Lua takes care that the returned values to fit into the stack sapce.
The function results are pushed onto the stack in direct order (the first result is pushed first),
so that after the call the last result is on the top of the stack.

用C API调用Lua函数需要遵循如下规则：首先将要调用的函数入栈；
然后将函数的参数，从第一个到最后一个依次入栈。
最后调用`lua_call`执行函数，`nargs`表示传入的参数个数。
函数执行时，传入的参数和栈底的函数会出栈。函数返回时，会将函数的结果入栈。
结束的个数会调整到`nresults`个，除非`nresults`的值为LUA_MULTRET，此时函数所有的结果都会入栈。
Lua会管理好结果的入栈操作。函数结果的入栈顺序是第一个结果先入栈，因此调用完后最后一个结果会在栈顶。

调用Lua函数任何错误都会通过`longjmp`向上传递。
如下所示的是与Lua函数等价的C API调用。

Any error inside the called function is propagated upwards (with a `longjmp`). 
The following example shows how the host program can do the equivalent to this Lua code:
```c
a = f("how", t.x, 14);
```
Here it is in C:
```
lua_getglobal(L, "f");                  /* function to be called */
lua_pushliteral(L, "how");                       /* 1st argument */
lua_getglobal(L, "t");                    /* table to be indexed */
lua_getfield(L, -1, "x");        /* push result of t.x (2nd arg) */
lua_remove(L, -2);                  /* remove 't' from the stack */
lua_pushinteger(L, 14);                          /* 3rd argument */
lua_call(L, 3, 1);     /* call 'f' with 3 arguments and 1 result */
lua_setglobal(L, "a");                         /* set global 'a' */
```

Note that the code above is *balanced*: at its end, the stack is back to its original configuration.
This is considered good programming practice.

注意的是上面的代码是*平衡的*：即在最后，栈的状态回到与原始状态一样。
这是一种公认的好的编程方法。

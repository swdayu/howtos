
# C Functions

When a C function is created, it is possible to associate some values with it, 
thus creating a C **closure** (see `lua_pushcclosure`); 
these values are called **upvalues** and are accessible to the function whenever it is called.

C函数创建后，可以关联一些值形成C**闭包**（见`lua_pushcclosure`）。
关联的值称为**上值**，不论函数何时被调用，都能访问到这些值。

Whenever a C function is called, its **upvalues** are located at specific **pseudo-indices**. 
These **pseudo-indices** are produced by the macro `lua_upvalueindex`. 
The first **upvalue** associated with a function is at index `lua_upvalueindex(1)`, and so on. 
Any access to `lua_upvalueindex(n)`, where `n` is greater than the number of **upvalues** of the current function 
(but not greater than 256), produces an acceptable but invalid index.

C函数调用时，它的**上值**都分配在特定的**伪索引**上。
这些**伪索引**通过一个宏`lua_upvalueindex`来产生。第一个**上值**关联在索引`lua_upvalueindex(1)`上，依次类推。
任何大于当前函数**上值**个数的索引（不能大于256），都是一个**可接受索引**，但不是**有效索引**。

# Registry

Lua provides a registry, a predefined table that can be used by any C code 
to store whatever Lua values it needs to store. 
The registry table is always located at pseudo-index `LUA_REGISTRYINDEX`. 
Any C library can store data into this table, but it must take care to choose keys 
that are different from those used by other libraries, to avoid collisions. 
Typically, you should use as key a string containing your library name, 
or a light userdata with the address of a C object in your code, or any Lua object created by your code. 
As with variable names, string keys starting with an underscore followed by uppercase letters are reserved for Lua.

Lua提供了一个预定义的**注册表**，C代码可以用它存储任何需要的Lua值。
**注册表**总是分配在**伪索引**`LUA_REGISTRYINDEX`上。
任何C代码库都可以将数据存储到这个表中，但必须选择不同于其他库的名称作为键，来避免冲突。
原则上，应该使用包含代码库名称的字符串，或关联了C对象地址的**轻量用户数据**，或创建的任何Lua对象。
像变量名称一样，以下划线开始后跟大写字母的字符串键保留给了Lua使用。

The integer keys in the registry are used by the reference mechanism (see `luaL_ref`) and by some predefined values. 
Therefore, integer keys must not be used for other purposes.

**注册表**中的数值键提供给引用机制（见`luaL_ref`）和预定义值使用。因而不能将数值键用于其他目的。

When you create a new **Lua state**, its registry comes with some predefined values. 
These predefined values are indexed with integer keys defined as constants in lua.h. 
The following constants are defined:
- **LUA_RIDX_MAINTHREAD**: At this index the registry has the main thread of the state. 
  (The main thread is the one created together with the state.)
- **LUA_RIDX_GLOBALS**: At this index the registry has the global environment.

当新创建一个**Lua状态**时，它的**注册表**就关联了一些预定义值。
这些预定义的值用定义在`lua.h`头文件中数值键来访问：
`LUA_RIDX_MAINTHREAD`对应**Lua状态**的主线程（它是与**Lua状态**一起被创建的），
`LUA_RIDX_GLOBALS`对应全局环境。

----------------------------------------------------------------------------------------

## lua_upvalueindex [-0, +0, –]
```c
int lua_upvalueindex (int i);
```
Returns the pseudo-index that represents the `i`-th upvalue of the running function (see §4.4).

## lua_pushcclosure [-n, +1, e]
```c
void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n);
```
Pushes a new C closure onto the stack.
When a C function is created, it is possible to associate some values with it, 
thus creating a C closure (see §4.4); these values are then accessible to the function whenever it is called. 
To associate values with a C function, first these values must be pushed onto the stack 
(when there are multiple values, the first value is pushed first). 
Then `lua_pushcclosure` is called to create and push the C function onto the stack, 
with the argument `n` telling how many values will be associated with the function. 
`lua_pushcclosure` also pops these values from the stack.

The maximum value for `n` is 255.

When `n` is zero, this function creates a light C function, which is just a pointer to the C function. 
In that case, it never raises a memory error.

## lua_pushcfunction [-0, +1, –]
```c
void lua_pushcfunction (lua_State *L, lua_CFunction f);
```
Pushes a C function onto the stack. 
This function receives a pointer to a C function and pushes onto the stack a Lua value of type function that, 
when called, invokes the corresponding C function.

Any function to be callable by Lua must follow the correct protocol to receive its parameters 
and return its results (see `lua_CFunction`).

## lua_call [-(nargs+1),+nresults,e]
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
这被认为是一种好的编程方法。

## lua_callk [-(nargs+1),+nresults,e]
```c
void lua_callk(lua_State* L, int nargs, int nresults, lua_LContent ctx, lua_KFunction k);
```

This function behaves exactly like `lua_call`, but allows the called function to yield (see 4.7).

该函数跟`lua_call`一样，但允许被调用的Lua函数yield。


## lua_KFunction
```c
typedef int (*lua_KFunction)(lua_State* L, int status, lua_KContext ctx);
```

Type for continuation functions (4.7).

**lua_KContext**

The type for continuation-function contexts. It must be a numeric type.
This type is deinfed as `intptr_t` when `intptr_t` is available, so that it can store pointers too.
Otherwise, it is defined as `ptrdiff_t`.

Continuation函数的类型（见4.7）。类型`lua_KContent`是Continuation函数的上下文。
它是一个数值类型，如果`intptr_t`存在则这个类型被定义成`intptr_t`，因此可以存储指针值。否则它被定义成`ptrdiff_t`。

## lua_pcall [-(nargs + 1), +(nresults|1), –]
```c
int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
```

Calls a function in protected mode.
Both `nargs` and `nresults` have the same meaning as in `lua_call`. 
If there are no errors during the call, `lua_pcall` behaves exactly like `lua_call`. 
However, if there is any error, `lua_pcall` catches it, pushes a single value on the stack (the error message), 
and returns an error code. Like `lua_call`, `lua_pcall` always removes the function and its arguments from the stack.

用保护模式调用Lua函数。参数`nargs`和`nresults`的含义跟`lua_call`一样。
如果函数调用那个没有错误发生，`lua_pcall`与`lua_call`完全一样。
如果发生错误，`lua_pcall`会获取它，将错误消息入栈，并将错误代码返回。
像`lua_call`一样，`lua_pcall`将传入的参数以及栈底的函数从栈中移除。

If `msgh` is 0, then the error message returned on the stack is exactly the original error message. 
Otherwise, `msgh` is the stack index of a message handler. (This index cannot be a pseudo-index.) 
In case of runtime errors, this function will be called with the error message 
and its return value will be the message returned on the stack by `lua_pcall`.

参数`msgh`如果是0，入栈的错误消息与原始的错误消息一样。
否则，`msgh`代表栈中错误处理函数的索引值（这个索引可以是伪索引）。
当运行时错误发生时，这个错误处理函数会对应的错误消息调用，而`lua_pcall`压入到栈的值是这个处理函数返回的值。

Typically, the message handler is used to add more debug information to the error message, 
such as a stack traceback. Such information cannot be gathered after the return of `lua_pcall`, 
since by then the stack has unwound.

一般的，错误处理函数用于为错误消息添加额外的debug信息，如栈的追踪。
这些信息不能在`lua_pcall`执行完后去收集，因为此时Lua栈已经执行了展开操作回到以前的状态。

`lua_pcall`函数会返回的值如下（定义在lua.h中）。

The `lua_pcall` function returns one of the following constants (defined in lua.h):
- LUA_OK (0): success.
- LUA_ERRRUN: a runtime error.
- LUA_ERRMEM: memory allocation error. For such errors, Lua does not call the message handler.
- LUA_ERRERR: error while running the message handler.
- LUA_ERRGCMM: error while running a `__gc` metamethod. 
  (This error typically has no relation with the function being called.)

## lua_pcallk [-(nargs + 1), +(nresults|1), –]
```c
int lua_pcallk (lua_State *L, int nargs, int nresults, int msgh, lua_KContext ctx, lua_KFunction k);
```

This function behaves exactly like `lua_pcall`, but allows the called function to yield (see §4.7).

这个函数与`lua_pcall`的行为一样，除了允许被调用的函数yield。

## lua_CFunction
```c
typedef int (*lua_CFunction)(lua_State* L);
```

Type for C functions.In order to communicate properly with Lua, a C function must use the following protocol, 
which defines the way parameters and results are passed: 
a C function receives its arguments from Lua in its stack in direct order (the first argument is pushed first). 
So, when the function starts, `lua_gettop(L)` returns the number of arguments received by the function. 
The first argument (if any) is at index 1 and its last argument is at index `lua_gettop(L)`. 
To return values to Lua, a C function just pushes them onto the stack, 
in direct order (the first result is pushed first), and returns the number of results. 
Any other value in the stack below the results will be properly discarded by Lua. 
Like a Lua function, a C function called by Lua can also return many results.

能被Lua是的C函数类型。为了与Lua交互，C函数的必须满足下面的规则，这个规则定义了函数的参数和返回值怎样传递。
C函数从Lua栈中接收参数，第一个参数先入栈。因此当函数开始执行时，`lua_gettop(L)`返回传入函数的参数个数。
第一个参数（如果存在）在位置1，最后一个参数在位置`lua_gettop(L)`。
当返回结果给Lua时，C函数要按顺序将结果入栈（第一个结果先入栈），并将结果的个数当作函数返回值返回。
Lua会丢弃任何栈中结果下面的值。像Lua函数一样，C函数也能返回多个结果。

下面的例子计算多个数值的平均值以及数值之和。

As an example, the following function receives a variable number of numeric arguments 
and returns their average and their sum:
```c
static int foo (lua_State *L) {
  int n = lua_gettop(L);    /* number of arguments */
  lua_Number sum = 0.0;
  int i;
  for (i = 1; i <= n; i++) {
    if (!lua_isnumber(L, i)) {
      lua_pushliteral(L, "incorrect argument");
      lua_error(L);
    }
    sum += lua_tonumber(L, i);
  }
  lua_pushnumber(L, sum/n);   /* first result */
  lua_pushnumber(L, sum);     /* second result */
  return 2;                   /* number of results */
}
```


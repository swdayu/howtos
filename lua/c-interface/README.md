
# C程序接口

> This section describes the set of C functions available to the host program to communicate with Lua. 
All API functions and related types and constants are declared in the header file "lua.h".

> Even when we use the term "function", any facility in the API may be provided as a macro instead. 
Except where stated otherwise, all such macros use each of their arguments exactly once 
(except for the first argument, which is always a Lua state), and so do not generate any hidden side-effects.

> As in most C libraries, the Lua API functions do not check their arguments for validity or consistency. 
However, you can change this behavior by compiling Lua with the macro `LUA_USE_APICHECK` defined.

C程序接口是实现C语言与Lua交互的一组C函数。
这些函数及相关类型和常量声明在`"lua.h"`头文件中。
这些接口可能使用宏来实现，除非特别说明，宏实现中的宏参都只使用一次以避免宏隐藏的副作用。
但是第一个参数除外，第一个参数总是Lua State指针，应该单独传入指针以避免出错。宏副作用举例:
```c
lua_State* op(lua_State* s);
void op1(lua_State* s);
void op2(lua_State* s);
#define LUA_COMBINE_OP(s) (op1(s), op2(s))

// error, will expand to (op1(op(s)), op2(op(s)))
LUA_COMBINE_OP(op(s));

// correct version
lua_State* s2 = op(s);
LUA_COMBINE_OP(s2);
```

像大多数C函数库一样，Lua提供的这些C函数都不会额外检查参数的合法性。
如果要检查，需要使用宏`LUA_USE_APICHECK`重新编译Lua。

## 错误处理

> Internally, Lua uses the C `longjmp` facility to handle errors. 
(Lua will use exceptions if you compile it as C++; search for `LUAI_THROW` in the source code for details.) 
When Lua faces any error (such as a memory allocation error, type errors, syntax errors, and runtime errors) 
it raises an error; that is, it does a long jump. 
A protected environment uses `setjmp` to set a recovery point; any error jumps to the most recent active recovery point.

> If an error happens outside any protected environment, 
Lua calls a `panic` function (see `lua_atpanic`) and then calls `abort`, 
thus exiting the host application. 
Your panic function can avoid this exit by never returning 
(e.g., doing a long jump to your own recovery point outside Lua).

> The panic function runs as if it were a message handler (see §2.3); 
in particular, the error message is at the top of the stack. 
However, there is no guarantee about stack space. 
To push anything on the stack, the panic function must first check the available space (see §4.2).

> Most functions in the API can raise an error, for instance due to a memory allocation error. 
The documentation for each function indicates whether it can raise errors.
Inside a C function you can raise an error by calling `lua_error`.

在内部，Lua使用C的`longjmp`机制来进行错误处理。但如果使用C++编译，Lua会使用C++中的异常（见代码中的`LUAI_THROW`）。
为了方便，这里也将Lua中的错误称为异常，并使用C语言中的`longjmp`和`setjmp`进行描述，如果是C++则对应的是`throw`和`try catch`。

当Lua遇到任何错误（如内存分配、类型、语法、运行时）都会触发异常，即执行`longjmp`。
使用`setjmp`设置了恢复点的环境称为受保护的环境，在受保护环境中遇到任何错误都会跳转到最近一个恢复点
（相当于在`try`之内的代码是受保护的）。

如果异常发生在保护环境之外（Lua提供的一些C接口函数没有设置保护，如果这些函数中发生异常就是保护环境外的异常），
Lua会调用`panic`函数并执行`abort`终止程序（相当于`try`块之外抛出异常会终止程序一样）。
使用自己设置的`panic`函数（调用`lua_atpanic`进行设置）可以避免这种异常退出，例如可以`longjmp`到Lua外部你自己的恢复点。
这个`panic`函数是被当作错误处理函数调用的，错误消息位于栈的顶部。
但是不确保栈还有额外的空间，因此在`panic`函数内入栈任何数据之前，应先检查栈的空间。

大多数C接口函数会抛出异常，例如内存分配失败导致的异常。
每个函数的文档说明中都指明了这个函数是否会抛出异常。
另外，在C函数内可以调用`lua_error`产生一个异常。

## 函数说明

> Each function has an indicator like this: `[-o, +p, x]`. 
The first field,`o`, is how many elements the function pops from the stack. 
The second field, `p`, is how many elements the function pushes onto the stack. 
(Any function always pushes its results after popping its arguments.) 
A field in the form `n|m` means the function can push (or pop) `n` or `m` elements, depending on the situation; 
an interrogation mark `?` means that we cannot know how many elements the function pops/pushes 
by looking only at its arguments (e.g., they may depend on what is on the stack). 
The third field, `x`, tells whether the function may raise errors: 
`-` means the function never raises any error; `e` means the function may raise errors; 
`v` means the function may raise an error on purpose.

每个函数都有一个像这样的说明`[-0, +p, x]`。
其中`o`表示这个函数会从栈中移除多少个元素，`p`表示函数会将多少个元素添加到栈中。
（每个函数总是在移除所有函数参数之后才将函数结果压入到栈中）。
`n|m`表示根据情况可能添加或移除`n`或`m`个元素；
`?`表示不确定会添加或移除多少个数元素（可能与已在栈中的内容有关）。
而`x`表示函数是否抛出异常：`-`表示不抛出；`e`表示可能会抛出；`v`表示在特定条件下会抛出。


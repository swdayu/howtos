
# C程序接口

This section describes the set of C functions available to the host program to communicate with Lua. 
All API functions and related types and constants are declared in the header file "lua.h".

Even when we use the term "function", any facility in the API may be provided as a macro instead. 
Except where stated otherwise, all such macros use each of their arguments exactly once 
(except for the first argument, which is always a Lua state), and so do not generate any hidden side-effects.

As in most C libraries, the Lua API functions do not check their arguments for validity or consistency. 
However, you can change this behavior by compiling Lua with the macro `LUA_USE_APICHECK` defined.

C程序接口是实现C语言与Lua交互的一组C函数。
这些函数及相关类型和常量声明在`"lua.h"`头文件中。
这些接口可能使用宏实现，除非特别说明，宏实现中的宏参都只使用一次以避免宏隐藏的副作用。
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

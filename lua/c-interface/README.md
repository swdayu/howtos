
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
这些接口的实现可能是宏，除非特别说明，宏实现中的宏参都只使用一次以避免宏隐藏的副作用。
但是第一个参数除外，第一个参数总是Lua State指针，应该单独传入指针以避免出错。宏副作用举例:
```c
lua_State* op(lua_State* s);
#define LUA_COMBINE_OP(s) (op1(s), op2(s))
LUA_COMBINE_OP(op(s)); // has side effect
lua_State* s2 = op(s); LUA_COMBINE_OP(s2); // ok
```
像大多数C函数库一样，Lua提供的这些C函数都不会额外检查参数的合法性。
如果要检查，需要使用宏`LUA_USE_APICHECK`重新编译Lua。

## Lua虚拟栈

> Lua uses a virtual stack to pass values to and from C. 
Each element in this stack represents a Lua value (nil, number, string, etc.). 
Whenever Lua calls C, the called function gets a new stack, 
which is independent of previous stacks and of stacks of C functions that are still active. 
This stack initially contains any arguments to the C function and 
it is where the C function pushes its results to be returned to the caller (see `lua_CFunction`).

> For convenience, most query operations in the API do not follow a strict stack discipline. 
Instead, they can refer to any element in the stack by using an index: 
A positive index represents an absolute stack position (starting at 1); 
a negative index represents an offset relative to the top of the stack. 
More specifically, if the stack has n elements, then index 1 represents the first element 
(that is, the element that was pushed onto the stack first) and index n represents the last element; 
index `-1` also represents the last element (that is, the element at the top) and index `-n` represents the first element.

Lua使用虚拟栈与C交换数据。栈中的每一个元素都是一个Lua值（如`nil`、数值、字符串等等）。
当Lua调用C函数时，C函数都会获得一个新的虚拟栈，这个栈是独立的与原来的虚拟栈或其他C函数正在使用的虚拟栈都不同。
栈初始时包含了要传给C函数的所有参数，C函数也把返回结果放到栈中传递给调用者
（详见`lua_CFunction`这个函数指针类型，所有能够被Lua调用的C函数都需要使用这个类型进行定义）。

为了方便，大多数查询栈的操作都不严格遵循栈的规则，而是使用索引来直接访问栈中的元素。
正索引表示栈的一个绝对位置（从1开始），而负索引则表示从栈顶算起的一个相对偏移位置。
准确地，如果栈有n个元素，则索引1表示第一个元素（即最先入栈的元素），索引n表示最后一个元素；
索引`-1`也表示最后一个元素（即栈顶元素），而索引`-n`表示第一个元素。

## 栈的大小

> When you interact with the Lua API, you are responsible for ensuring consistency. 
In particular, you are responsible for controlling stack overflow. 
You can use the function `lua_checkstack` to ensure that the stack has enough space for pushing new elements.
Whenever Lua calls C, it ensures that the stack has space for at least `LUA_MINSTACK` extra slots. 
`LUA_MINSTACK` is defined as 20, so that usually you do not have to worry about stack space 
unless your code has loops pushing elements onto the stack.

> When you call a Lua function without a fixed number of results (see `lua_call`), 
Lua ensures that the stack has enough space for all results, but it does not ensure any extra space. 
So, before pushing anything in the stack after such a call you should use `lua_checkstack`.

当使用Lua提供的这些C接口函数时，需要自行保证程序的一致性。
最特别的一项是你需要自己负责控制虚拟栈不让其溢出。
可以调用`lua_checkstack`函数来确保栈有足够的空间用来压入新元素。
不论何时Lua调用C函数，它都会保证栈至少有`LUA_MINISTACK`个额外的空间。
这个值是20，因此一般不需要有什么担心，除非你的代码一直循环将元素压入到栈中。

当调用一个没有固定个数结果的Lua函数时（见函数`lua_call`，它可以在C函数中执行一段Lua代码），
Lua会保证有足够的空间来存储所有的返回结果，但不确保还有额外的空间可用。
因此，如果需要在调用这样的函数之后继续压入数据，首先应该调用`lua_checkstack`函数来确保空间够用。

## 有效索引和可接受索引

> Any function in the API that receives stack indices works only with **valid indices** or **acceptable indices**.
A **valid index** is an index that refers to a position that stores a modifiable Lua value. 
It comprises stack indices between 1 and the stack top (`1 ≤ abs(index) ≤ top`) plus **pseudo-indices**,
which represent some positions that are accessible to C code but that are not in the stack. 
**Pseudo-indices** are used to access the **registry** (see §4.5) and the **upvalues** of a C function (see §4.4).

> Functions that do not need a specific mutable position, 
but only a value (e.g., query functions), can be called with acceptable indices. 
An acceptable index can be any valid index, but it also can be any positive index after the stack top 
within the space allocated for the stack, that is, indices up to the stack size. 
(Note that 0 is never an acceptable index.) 
Except when noted otherwise, functions in the API work with acceptable indices.

> Acceptable indices serve to avoid extra tests against the stack top when querying the stack. 
For instance, a C function can query its third argument without the need to first check 
whether there is a third argument, that is, without the need to check whether 3 is a valid index.
For functions that can be called with acceptable indices, any non-**valid index** is treated as if 
it contains a value of a virtual type `LUA_TNONE`, which behaves like a `nil` value.

任何有栈索引参数的C接口函数都只接收**有效索引**或**可接受索引**。
**有效索引**引用的是有效的栈位置，其中存储的是可以修改的Lua值，
它的范围从1到栈顶部（即`1 ≤ abs(index) ≤ top`）以及**伪索引**。
**伪索引**可以被C代码访问但实际的位置不在栈中，它用于访问C函数的**上值**和**注册表**。

如果一个函数不需要一个可以修改的索引位置，而只需要获取对应的值（例如查询函数），则可以使用**可接受索引**进行调用。
**可接受索引**可以是任意的**有效索引**，以及栈顶之上但在栈空间内部的索引，
即索引值可以大于栈顶但不超过栈的大小（注意0不是一个**可接受索引**）。除非特别说明，C接口函数都接受**可接受索引**。

**可接受索引**的目的主要是为了避免在查询栈时相对栈顶做额外检查。
例如，C函数可以查询它的第3个参数而不需要首先检查第3个参数是否存在，即无需检查3是否是**有效索引**。
使用**可接受索引**参数的函数，会把非**有效索引**位置上的值看成是`LUA_TNONE`，它的作用跟`nil`值类似。

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

每个函数都有一个像`[-0, +p, x]`这样的说明。
其中`o`表示这个函数会从栈中移除多少个元素，`p`表示函数会将多少个元素添加到栈中
（每个函数总是在移除所有函数参数之后才将函数结果压入到栈中）。
`n|m`表示根据情况可能添加或移除`n`个或`m`个元素；
`?`表示不确定会添加或移除多少个元素（可能与栈中已有内容有关）。
而`x`则表示函数是否抛出异常：`-`表示不抛出；`e`表示可能会抛出；`v`表示在特定条件下会抛出。

## 辅助函数

> The auxiliary library provides several convenient functions to interface C with Lua. 
While the basic API provides the primitive functions for all interactions between C and Lua, 
the auxiliary library provides higher-level functions for some common tasks.
All functions and types from the auxiliary library are defined in header file "lauxlib.h" and have a prefix `luaL_`.

> All functions in the auxiliary library are built on top of the basic API, 
and so they provide nothing that cannot be done with that API. 
Nevertheless, the use of the auxiliary library ensures more consistency to your code.

> Several functions in the auxiliary library use internally some extra stack slots. 
When a function in the auxiliary library uses less than five slots, it does not check the stack size; 
it simply assumes that there are enough slots.

> Several functions in the auxiliary library are used to check C function arguments. 
Because the error message is formatted for arguments (e.g., "bad argument #1"), 
you should not use these functions for other stack values.
Functions called `luaL_check*` always raise an error if the check is not satisfied.

辅助函数提供了一些便利的功能使C与Lua的交互更为方便，
这些函数以及相关类型定义在`"lauxlib.h"`头文件中，辅助函数的名称使用`luaL_`前缀开头。
相对于提供核心功能的基本函数，辅助函数提供了一些更为高级的功能。
所有辅助函数都建立在基本函数之上，它提供的功能都可以用基本函数来实现，但使用它可以使代码变得更具简洁和一致性。

一些辅助函数在内部使用了一些额外的栈空间。
如果辅助函数要使用的栈元素个数少于5个，它不会检查栈的大小而假设栈有足够的空间可用。
一些辅助函数（例如`luaL_checknumber`）可用于检查C函数的参数。
但是如果检查失败，格式化的错误消息（例如`"bad argument #1"`）会添加到栈中，
因此不应该使用这些函数去检查栈中的其他值。
调用`luaL_check*`的函数在条件不满足的情况下会抛出异常。


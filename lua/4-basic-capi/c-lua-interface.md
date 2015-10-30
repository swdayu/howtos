
# 4. The Application Program Interface

This section describes the C API for Lua, that is, 
the set of C functions available to the host program to communicate with Lua. 
All API functions and related types and constants are declared in the header file lua.h.

Even when we use the term "function", any facility in the API may be provided as a macro instead. 
Except where stated otherwise, all such macros use each of their arguments exactly once 
(except for the first argument, which is always a Lua state), and so do not generate any hidden side-effects.

As in most C libraries, the Lua API functions do not check their arguments for validity or consistency. 
However, you can change this behavior by compiling Lua with the macro `LUA_USE_APICHECK` defined.

这部分介绍Lua的C API，即宿主语言中可以使用的与Lua交互的C函数。
所有函数和相关类型和常量都声明在`lua.h`头文件中。
虽然说的是函数，但有些API可能以宏的形式提供。
除非特别说明，否在宏都只使用参数一次（第一个参数除外，这个参数总是Lua state），因而不会参数隐藏的宏副作用。
像大多数的C函数库一样，Lua的这些不会检查传入参数的有效性和一致性。
可以使用宏`LUA_USE_APICHECK`重新编译Lua改变这个行为。

## 4.1 The Stack

Lua uses a virtual stack to pass values to and from C. 
Each element in this stack represents a Lua value (nil, number, string, etc.).

Whenever Lua calls C, the called function gets a new stack, 
which is independent of previous stacks and of stacks of C functions that are still active. 
This stack initially contains any arguments to the C function and it is where the C function pushes its results 
to be returned to the caller (see `lua_CFunction`).

Lua使用虚拟栈将参数传递给C或从C接收参数。栈的元素代表Lua值（如`nil`、数值、字符串、等等）。
当Lua调用C函数时，被调用的函数都获得一个新栈，这个栈独立于任何之前的栈以及当前活动的C函数对应的栈。
栈初始情况下包含传递给C的所有参数，它也是C函数存放结果放回给调用者的地方（见`lua_CFunction`）。

For convenience, most query operations in the API do not follow a strict stack discipline. 
Instead, they can refer to any element in the stack by using an index: 
A positive index represents an absolute stack position (starting at 1); 
a negative index represents an offset relative to the top of the stack. 
More specifically, if the stack has n elements, then index 1 represents the first element 
(that is, the element that was pushed onto the stack first) and index n represents the last element; 
index -1 also represents the last element (that is, the element at the top) and index -n represents the first element.

为了方便，大多数的查询操作都没有严格遵循栈规则。而是索引值来直接访问栈中的变量。
正索引代表一个绝对的栈位置（计数从1开始），负索引代表从栈顶算起的相对偏移。
更准确地，如果栈有n个元素，则索引1表示第一个元素（即压入栈中的第一个元素），索引n表示最后一个元素；
索引-1也表示最后一个元素（即栈顶元素），索引-n表示第一个元素。

## 4.2 Stack Size

When you interact with the Lua API, you are responsible for ensuring consistency. 
In particular, you are responsible for controlling stack overflow. 
You can use the function `lua_checkstack` to ensure that the stack has enough space for pushing new elements.

使用这个应用接口时，你必须自己负责程序的一致性。特别的，你应对栈的溢出情况负责。
可以使用`lua_checkstack`函数保证栈有做够的空间压入新元素。

Whenever Lua calls C, it ensures that the stack has space for at least `LUA_MINSTACK` extra slots. 
`LUA_MINSTACK` is defined as 20, so that usually you do not have to worry about stack space 
unless your code has loops pushing elements onto the stack.

当Lua调用C函数时会保证栈的大小最少有`LUA_MINSTACK`个额外元素的空间可以使用。
这个值定义为20，因此你通常不需要去担心栈的空间除非你的代码使用循环压入来很多元素到栈中。

When you call a Lua function without a fixed number of results (see `lua_call`), 
Lua ensures that the stack has enough space for all results, but it does not ensure any extra space. 
So, before pushing anything in the stack after such a call you should use `lua_checkstack`.

当调用一个没有固定值的Lua函数时（见`lua_call`），Lua保证有做够的空间来存储所有的参数，但是不保证还有其他额外的空间。
因此，在调用来这样的函数后，在继续压入数据之前应该先调用一次`lua_checkstack`。

## 4.3 Valid and Acceptable Indices

Any function in the API that receives stack indices works only with valid indices or acceptable indices.

A valid index is an index that refers to a position that stores a modifiable Lua value. 
It comprises stack indices between 1 and the stack top (1 ≤ abs(index) ≤ top) plus pseudo-indices,
which represent some positions that are accessible to C code but that are not in the stack. 
Pseudo-indices are used to access the registry (see §4.5) and the upvalues of a C function (see §4.4).

接收stack index的函数只有当是有效的index或可接受的index时才正常工作。
有效的index是指它引用的位置存储了可被修改的Lua值，
它的范围从1到stack顶部（即`1 ≤ abs(index) ≤ top`）再加上pseudo-indices，这是C代码可以访问但不再stack中的一些位置。
Pseudo-indices用于访问C注册表以及C函数的upvalue。

Functions that do not need a specific mutable position, 
but only a value (e.g., query functions), can be called with acceptable indices. 
An acceptable index can be any valid index, but it also can be any positive index after the stack top 
within the space allocated for the stack, that is, indices up to the stack size. 
(Note that 0 is never an acceptable index.) 
Except when noted otherwise, functions in the API work with acceptable indices.

如果函数不需要可修改的index位置，只需要读取值（如查询函数），则这些函数可以用acceptable index调用。
一个acceptable index可以时任何valid index，但它还可以是在以分配stack内部但是超过stack top的index，即小于栈实际大小的index（注意0不是acceptable index）。
除非特别说明，C API的函数都使用acceptable index。

Acceptable indices serve to avoid extra tests against the stack top when querying the stack. 
For instance, a C function can query its third argument without the need to first check 
whether there is a third argument, that is, without the need to check whether 3 is a valid index.

For functions that can be called with acceptable indices, any non-valid index is treated as if 
it contains a value of a virtual type `LUA_TNONE`, which behaves like a `nil` value.

Acceptable index用于避免在查询栈时进行额外的栈顶测试。
例如，C函数可以查询它的第3个参数而不用首先知道是否有第3个参数，即不需要去检查3是否是一个valid index。
可以用acceptable index调用的函数，任何non-valid index都被当作存储了虚拟值`LUA_TNONE`，这个值的用途跟`nil`类似。

## 4.4 C Closures

When a C function is created, it is possible to associate some values with it, 
thus creating a C closure (see `lua_pushcclosure`); 
these values are called upvalues and are accessible to the function whenever it is called.

Whenever a C function is called, its upvalues are located at specific pseudo-indices. 
These pseudo-indices are produced by the macro `lua_upvalueindex`. 
The first upvalue associated with a function is at index `lua_upvalueindex(1)`, and so on. 
Any access to `lua_upvalueindex(n)`, where `n` is greater than the number of upvalues of the current function 
(but not greater than 256), produces an acceptable but invalid index.

创建C函数后，可以将一些值关联在函数上，这样的函数称为C closure（见`lua_pushcclosure`)；
这些关联的值被称为upvalue，可以被关联的函数访问。

当C函数被调用时，它的upvalue分配在特定的pseudo-index上。这些pseudo-index通过宏`lua_upvalueindex`产生。
函数关联的第一个upvalue在`lua_upvalueindex(1)`位置上，依次类推。
任何访问的位置对应值超过当前函数upvalue的个数但是不大于256，将产生一个acceptable但invalid的index。

## 4.5 Registry

Lua provides a registry, a predefined table that can be used by any C code 
to store whatever Lua values it needs to store. 
The registry table is always located at pseudo-index `LUA_REGISTRYINDEX`. 
Any C library can store data into this table, but it must take care to choose keys 
that are different from those used by other libraries, to avoid collisions. 
Typically, you should use as key a string containing your library name, 
or a light userdata with the address of a C object in your code, or any Lua object created by your code. 
As with variable names, string keys starting with an underscore followed by uppercase letters are reserved for Lua.

Lua有一个预定义的注册表，任何C代码可以用它来存储需要的Lua值。
这个注册表总是分配在`LUA_REGISTRYINDEX`这个pseudo-index位置上。
C代码可以存储数据到这个表中，但是必须选择合适的不同的键避免冲突。
原则上应该使用如下值作为键：包含了你自己库名称的字符串，或保存了你代码中的C对象地址的轻量用户数据，
或你代码中创建的任何Lua对象。像变量名称一样，以下划线开始后跟大写字母的字符串键仅保留给Lua使用。

The integer keys in the registry are used by the reference mechanism (see `luaL_ref`) and by some predefined values. 
Therefore, integer keys must not be used for other purposes.

注册表中的数值键用于引用机制（见`luaL_ref`）和被一些预定义的值使用。
因此，数值键必须不去用于其他目的。

When you create a new Lua state, its registry comes with some predefined values. 
These predefined values are indexed with integer keys defined as constants in lua.h. 
The following constants are defined:

- **LUA_RIDX_MAINTHREAD**: At this index the registry has the main thread of the state. 
  (The main thread is the one created together with the state.)

- **LUA_RIDX_GLOBALS**: At this index the registry has the global environment.

当创建一个新的Lua状态时，它的注册表就有了一些预定义的值。
这些预定义的值通过`lua.h`头文件中定义的数值键来访问。
`LUA_RIDX_MAINTHREAD`对应位置时Lua状态的主线程（主线程是与Lua状态一起同时创建的线程）。
`LUA_RIDX_GLOBALS`对应这个位置是Lua的全局环境。

## 4.6 Error Handling in C

Internally, Lua uses the C `longjmp` facility to handle errors. 
(Lua will use exceptions if you compile it as C++; search for LUAI_THROW in the source code for details.) 
When Lua faces any error (such as a memory allocation error, type errors, syntax errors, and runtime errors) 
it raises an error; that is, it does a long jump. A protected environment uses `setjmp` to set a recovery point; 
any error jumps to the most recent active recovery point.

在内部，Lua使用C中的`longjmp`处理错误（Lua会使用一场如果当作C++编译它；参看代码中`LUAI_THROW`）。
当Lua遇到任何错误（入内存分配错误、类型错误、语法错误、运行时错误），它都会触发一次错误，也即执行`longjmp`。
受保护的环境使用`setjmp`设置恢复点，当遇到任何错误时会跳转到最近的活动恢复点。

If an error happens outside any protected environment, 
Lua calls a `panic` function (see `lua_atpanic`) and then calls `abort`, thus exiting the host application. 
Your panic function can avoid this exit by never returning 
(e.g., doing a long jump to your own recovery point outside Lua).

如果错误发生在受保护的环境外，Lua会调用`panic`函数（见`lua_atpanic`）并调用`abort`函数退出宿主程序。
你自己设置自己的`panic`函数来避免这种异常退出（使用`longjmp`跳转到Lua外面你自己的恢复点）。

The panic function runs as if it were a message handler (see §2.3); 
in particular, the error message is at the top of the stack. However, there is no guarantee about stack space. 
To push anything on the stack, the panic function must first check the available space (see §4.2).

`panic`函数当作一个错误消息处理函数来执行；特别的，这个错误消息位于栈顶部。
然而，不保证栈还有额外的空间，因此压入数据之前，`panic`函数应该先检查栈的状态。

Most functions in the API can raise an error, for instance due to a memory allocation error. 
The documentation for each function indicates whether it can raise errors.

Inside a C function you can raise an error by calling `lua_error`.

大多数C API函数会触发异常，例如由于内存分配引发的错误异常。
每个API的文档中都指明了是否会触发异常。
在C函数中，你也可以自己调用`lua_error`触发一个异常。

## 4.7 Handling Yields in C

Internally, Lua uses the C `longjmp` facility to yield a coroutine. 
Therefore, if a C function foo calls an API function and this API function yields 
(directly or indirectly by calling another function that yields), 
Lua cannot return to foo any more, because the longjmp removes its frame from the C stack.

To avoid this kind of problem, Lua raises an error whenever it tries to yield across an API call, 
except for three functions: `lua_yieldk`, `lua_callk`, and `lua_pcallk`. 
All those functions receive a continuation function (as a parameter named `k`) to continue execution after a yield.

We need to set some terminology to explain continuations. 
We have a C function called from Lua which we will call the original function. 
This original function then calls one of those three functions in the C API, 
which we will call the callee function, that then yields the current thread. 
(This can happen when the callee function is `lua_yieldk`, 
or when the callee function is either `lua_callk` or `lua_pcallk` and the function called by them yields.)

Suppose the running thread yields while executing the callee function. 
After the thread resumes, it eventually will finish running the callee function. 
However, the callee function cannot return to the original function, 
because its frame in the C stack was destroyed by the yield. 
Instead, Lua calls a continuation function, which was given as an argument to the callee function. 
As the name implies, the continuation function should continue the task of the original function.

As an illustration, consider the following function:

     int original_function (lua_State *L) {
       ...     /* code 1 */
       status = lua_pcall(L, n, m, h);  /* calls Lua */
       ...     /* code 2 */
     }
Now we want to allow the Lua code being run by lua_pcall to yield. 
First, we can rewrite our function like here:

     int k (lua_State *L, int status, lua_KContext ctx) {
       ...  /* code 2 */
     }
     
     int original_function (lua_State *L) {
       ...     /* code 1 */
       return k(L, lua_pcall(L, n, m, h), ctx);
     }
In the above code, the new function k is a continuation function (with type `lua_KFunction`), 
which should do all the work that the original function was doing after calling `lua_pcall`. 
Now, we must inform Lua that it must call `k` if the Lua code being executed by `lua_pcall` gets interrupted 
in some way (errors or yielding), so we rewrite the code as here, replacing `lua_pcall` by `lua_pcallk`:

     int original_function (lua_State *L) {
       ...     /* code 1 */
       return k(L, lua_pcallk(L, n, m, h, ctx2, k), ctx1);
     }
Note the external, explicit call to the continuation: Lua will call the continuation only if needed, 
that is, in case of errors or resuming after a yield. 
If the called function returns normally without ever yielding, 
`lua_pcallk` (and `lua_callk`) will also return normally. 
(Of course, instead of calling the continuation in that case, 
you can do the equivalent work directly inside the original function.)

Besides the Lua state, the continuation function has two other parameters: 
the final status of the call plus the context value (`ctx`) that was passed originally to `lua_pcallk`. 
(Lua does not use this context value; it only passes this value from the original function to 
the continuation function.) 
For `lua_pcallk`, the status is the same value that would be returned by `lua_pcallk`, 
except that it is `LUA_YIELD` when being executed after a yield (instead of `LUA_OK`). 
For `lua_yieldk` and `lua_callk`, the status is always `LUA_YIELD` when Lua calls the continuation. 
(For these two functions, Lua will not call the continuation in case of errors, because they do not handle errors.)
Similarly, when using `lua_callk`, you should call the continuation function with `LUA_OK` as the status. 
(For `lua_yieldk`, there is not much point in calling directly the continuation function, 
because `lua_yieldk` usually does not return.)

Lua treats the continuation function as if it were the original function. 
The continuation function receives the same Lua stack from the original function, 
in the same state it would be if the callee function had returned. 
(For instance, after a lua_callk the function and its arguments are removed from the stack and 
replaced by the results from the call.) It also has the same upvalues. 
Whatever it returns is handled by Lua as if it were the return of the original function.

## 4.8 Functions and Types

Here we list all functions and types from the C API in alphabetical order. Each function has an indicator like this: [-o, +p, x]

The first field, o, is how many elements the function pops from the stack. The second field, p, is how many elements the function pushes onto the stack. (Any function always pushes its results after popping its arguments.) A field in the form x|y means the function can push (or pop) x or y elements, depending on the situation; an interrogation mark '?' means that we cannot know how many elements the function pops/pushes by looking only at its arguments (e.g., they may depend on what is on the stack). The third field, x, tells whether the function may raise errors: '-' means the function never raises any error; 'e' means the function may raise errors; 'v' means the function may raise an error on purpose.

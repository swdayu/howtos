
# The Application Program Interface

This section describes the C API for Lua, that is, 
the set of C functions available to the host program to communicate with Lua. 
All API functions and related types and constants are declared in the header file `lua.h`.

这里介绍Lua中的C API，宿主语言可以使用这些函数与Lua交互。
所有函数及相关类型和常量都声明在`lua.h`中。

Even when we use the term "function", any facility in the API may be provided as a macro instead. 
Except where stated otherwise, all such macros use each of their arguments exactly once 
(except for the first argument, which is always a Lua state), and so do not generate any hidden side-effects.

虽然使用函数这个称呼，但是API可能用宏实现。
除非特别说明，宏的参数都只使用一次（第一个参数Lua State除外），从而避免宏隐藏的副作用。

As in most C libraries, the Lua API functions do not check their arguments for validity or consistency. 
However, you can change this behavior by compiling Lua with the macro `LUA_USE_APICHECK` defined.

像大多数C库一样，API函数不检查参数的合法性和一致性。
然而可以用宏`LUA_USE_APICHECK`重新编译改变这个行为。

## Error Handling

Internally, Lua uses the C `longjmp` facility to handle errors. 
(Lua will use exceptions if you compile it as C++; search for LUAI_THROW in the source code for details.) 
When Lua faces any error (such as a memory allocation error, type errors, syntax errors, and runtime errors) 
it raises an error; that is, it does a long jump. A protected environment uses `setjmp` to set a recovery point; 
any error jumps to the most recent active recovery point.

在内部，Lua使用C`longjmp`处理错误（如果是C++编译则会使用异常，见`LUAI_THROW`）。
当Lua遇到任何错误（如内存分配、类型、语法、运行时）都会触发异常，即执行`longjmp`。
受保护的环境使用`setjmp`设置恢复点，遇到任何错误都跳转到最近恢复点。

If an error happens outside any protected environment, 
Lua calls a `panic` function (see `lua_atpanic`) and then calls `abort`, thus exiting the host application. 
Your panic function can avoid this exit by never returning 
(e.g., doing a long jump to your own recovery point outside Lua).

如果错误发生在保护环境之外，Lua会调用`panic`函数（见`lua_atpanic`）然后执行`abort`退出程序。
使用自己设置的`panic`函数可以避免这种异常退出（例如可以`longjmp`到你自己的恢复点）。

The panic function runs as if it were a message handler (see §2.3); 
in particular, the error message is at the top of the stack. However, there is no guarantee about stack space. 
To push anything on the stack, the panic function must first check the available space (see §4.2).

`panic`当作消息处理函数执行，错误消息位于栈顶。然而，不确保栈还有额外的空间。
因此在入栈之前，`panic`函数应先检查栈空间。

Most functions in the API can raise an error, for instance due to a memory allocation error. 
The documentation for each function indicates whether it can raise errors.

Inside a C function you can raise an error by calling `lua_error`.

大多数API函数会触发异常，如内存分配异常。
API文档指明了每个函数是否会产生异常。C函数中可以调用`lua_error`产生异常。

## Functions and Types

Here we list all functions and types from the C API in alphabetical order. 
Each function has an indicator like this: [-o, +p, x]

The first field, `o`, is how many elements the function pops from the stack. 
The second field, `p`, is how many elements the function pushes onto the stack. 
(Any function always pushes its results after popping its arguments.) 
A field in the form `x|y` means the function can push (or pop) `x` or `y` elements, depending on the situation; 
an interrogation mark `?` means that we cannot know how many elements the function pops/pushes 
by looking only at its arguments (e.g., they may depend on what is on the stack). 
The third field, `x`, tells whether the function may raise errors: `-` means the function never raises any error; 
`e` means the function may raise errors; `v` means the function may raise an error on purpose.

下面会列出C API所有函数和类型。每个函数都有这样的说明`[-0, +p, x]`。
其中`o`表示多少个元素出栈，`p`表示多少个元素入栈（任何函数总在压入结果之前先将参数出栈）。
`x|y`代表根据情况可能入栈或出栈`x`或`y`个元素；`?`表示会入栈或出栈不定个数元素（可能与当前栈中元素有关）。
`x`表示是否抛出异常：`-`不抛出；`e`可能抛出；`v`特定条件下抛出。

---------------------------------------------------------------------------------

## lua_Integer

The type of integers in Lua.
By default this type is `long long`, (usually a 64-bit two-complement integer), 
but that can be changed to `long` or `int` (usually a 32-bit two-complement integer). 
(See `LUA_INT_TYPE` in `luaconf.h`.)

Lua中整数类型，默认是`long long`（通常是64位补码整数），但可以改成`long`或`int`（32位补码整数）。
（见`luaconf.h`中的`LUA_INT_TYPE`）。

Lua also defines the constants `LUA_MININTEGER` and `LUA_MAXINTEGER`, 
with the minimum and the maximum values that fit in this type.

Lua还定义了`LUA_MININTEGER`和`LUA_MAXINTEGER`表示这个类型能表示的最小最大值。

## lua_Unsigned

The unsigned version of `lua_Integer`.

`lua_Integer`的无符号版本。

## lua_Number

The type of floats in Lua.

By default this type is `double`, but that can be changed to a single `float` or a `long double`. 
(See `LUA_FLOAT_TYPE` in `luaconf.h`.)

Lua中的浮点类型，默认是`double`类型，但可以改成`float或者`long double`（见`luaconf.h`中的`LUA_FLOAT_TYPE`）。

## lua_typename [-0, +0, –]
```c
const char *lua_typename (lua_State *L, int tp);
```

Returns the name of the type encoded by the value `tp`, which must be one the values returned by `lua_type`.

返回类型`tp`的字符串表示，类型必须是`lua_type`的返回值之一。包括`LUA_TNIL`、`LUA_TNUMBER`、`LUA_TBOOLEAN`、
`LUA_TSTRING`、 `LUA_TTABLE`、 `LUA_TFUNCTION`、`LUA_TUSERDATA`、`LUA_TTHREAD`、`LUA_TLIGHTUSERDATA`。
这些常量定义在`lua.h`中。

## lua_version [-0, +0, v]
```c
const lua_Number *lua_version (lua_State *L);
```

Returns the address of the version number stored in the Lua core. 
When called with a valid `lua_State`, returns the address of the version used to create that state. 
When called with NULL, returns the address of the version running the call.

返回Lua版本值的地址。如果用有效的Lua State调用，返回创建这个State的版本地址。
如果是NULL，返回运行这个函数的Lua版本地址。

## lua_atpanic [-0, +0, –]
```c
lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf);
```

Sets a new panic function and returns the old one (see §4.6).

设置一个新的Panic函数，并返回原来的Panic函数。

## lua_error [-1, +0, v]
```c
int lua_error (lua_State *L);
```

Generates a Lua error, using the value at the top of the stack as the error object. 
This function does a long jump, and therefore never returns (see `luaL_error`).

使用栈顶的错误对象产生一个Lua异常。这个函数使用`longjmp`，因此永远不会返回（见`luaL_error`）。

## lua_Alloc
```c
typedef void* (*lua_Alloc)(void* ud, void* ptr, size_t osize, size_t nsize);
```
The type of the memory-allocation function used by Lua states. 
The allocator function must provide a functionality similar to `realloc`, but not exactly the same. 
Its arguments are `ud`, an opaque pointer passed to `lua_newstate`; 
`ptr`, a pointer to the block being allocated/reallocated/freed; 
`osize`, the original size of the block or some code about what is being allocated; 
and `nsize`, the new size of the block.

Lua State使用的内存分配函数的类型。分配函数应提供`realloc`相似的功能，但并不是完全一样。
参数`ud`是`lua_newstate`中传人的抽象指针；`ptr`指向要操作的内存块；`osize`表示旧大小；`nsize`表示新大小。

When `ptr` is not NULL, `osize` is the size of the block pointed by `ptr`, 
that is, the size given when it was allocated or reallocated.

When `ptr` is NULL, `osize` encodes the kind of object that Lua is allocating. 
`osize` is any of `LUA_TSTRING`, `LUA_TTABLE`, `LUA_TFUNCTION`, `LUA_TUSERDATA`, or `LUA_TTHREAD` 
when (and only when) Lua is creating a new object of that type. 
When `osize` is some other value, Lua is allocating memory for something else.

如果`ptr`不为空，`osize`表示`ptr`指向的内存块的大小，及这个内存块分配或重新分配时的大小。
如果`ptr`为空，`osize`表示Lua对象类型。
只有当Lua正在创建相应类型时，`osize`才会是这些值`LUA_TSTRING`、
`LUA_TTABLE`、`LUA_TFUNCTION`、`LUA_TUSERDATA`或`LUA_TTHREAD`。
如果`osize`是其他值表示Lua在分配其他内存。

Lua assumes the following behavior from the allocator function:
- When `nsize` is zero, the allocator must behave like free and return NULL.
- When `nsize` is not zero, the allocator must behave like `realloc`. 
  The allocator returns NULL if and only if it cannot fulfill the request. 
  Lua assumes that the allocator never fails when `osize >= nsize`.

Lua假设分配函数有如下行为：如果`nsize`是0分配其必须释放内存并返回NULL；
如果`nsize`不是0则必须实现与`realloc`相同；
分配函数只有在不能满足分配请求时才返回NULL，
Lua假设当`osize>=nsize`时，分配函数不会失败。

Here is a simple implementation for the allocator function. 
It is used in the auxiliary library by `luaL_newstate`.
```c
static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
  (void)ud;  (void)osize;  /* not used */
  if (nsize == 0) {
    free(ptr);
    return NULL;
  }
  else
    return realloc(ptr, nsize);
}
```

Note that Standard C ensures that `free(NULL)` has no effect 
and that `realloc(NULL,size)` is equivalent to `malloc(size)`. 
This code assumes that `realloc` does not fail when shrinking a block. 
(Although Standard C does not ensure this behavior, it seems to be a safe assumption.)

上面是分配函数的一个简单实现，它用在辅助函数`luaL_newstate`中。
注意标准C保证`free(NULL)`没有任何效果， `realloc(NULL,size)`相当于`malloc(size)`。
上面的代码假设`realloc`当缩减大小时不会失败（尽管标准C没有明确保证这个行为，但这应该是一个安全的假设）。

## lua_getallocf [-0, +0, –]
```c
lua_Alloc lua_getallocf (lua_State *L, void **ud);
```

Returns the memory-allocation function of a given state. 
If `ud` is not NULL, Lua stores in `*ud` the opaque pointer given when the memory-allocator function was set.

返回给定Lua State的分配函数。如果`ud`不为空，Lua将原来设置分配函数时指定的抽象指针保存到`*ud`中。

## lua_gc [-0, +0, e]
```c
int lua_gc (lua_State *L, int what, int data);
```

Controls the garbage collector.
This function performs several tasks, according to the value of the parameter `what`:
- LUA_GCSTOP: stops the garbage collector.
- LUA_GCRESTART: restarts the garbage collector.
- LUA_GCCOLLECT: performs a full garbage-collection cycle.
- LUA_GCCOUNT: returns the current amount of memory (in Kbytes) in use by Lua.
- LUA_GCCOUNTB: returns the remainder of dividing the current amount of bytes of memory in use by Lua by 1024.
- LUA_GCSTEP: performs an incremental step of garbage collection.
- LUA_GCSETPAUSE: sets data as the new value for the pause of the collector (see §2.5) 
  and returns the previous value of the pause.
- LUA_GCSETSTEPMUL: sets data as the new value for the step multiplier of the collector (see §2.5) 
  and returns the previous value of the step multiplier.
- LUA_GCISRUNNING: returns a boolean that tells whether the collector is running (i.e., not stopped).

For more details about these options, see `collectgarbage`.

该函数用于控制垃圾收集器。根据传人的`what`值函数可以执行不同的操作，这些值如上所示。
更多的细节请参考`collectgarbage`。

## lua_State
```c
typedef struct lua_State lua_State;
```
An opaque structure that points to a thread 
and indirectly (through the thread) to the whole state of a Lua interpreter. 
The Lua library is fully reentrant: it has no global variables. 
All information about a state is accessible through this structure.

表示线程或间接表示（通过线程）Lua解析器状态的抽象结构体。
Lua函数都是可重入的：它们没有全局变量。所以的状态信息都通过这个结构体访问。

A pointer to this structure must be passed as the first argument to every function in the library, 
except to `lua_newstate`, which creates a Lua state from scratch.

指向这个结构体的指针必须作为所以库函数的第一个参数传入，除了`lua_newstate`，它用于创建Lua State。

## lua_newstate [-0, +0, –]
```c
lua_State *lua_newstate (lua_Alloc f, void *ud);
```

Creates a new thread running in a new, independent state. 
Returns NULL if it cannot create the thread or the state (due to lack of memory). 
The argument `f` is the allocator function; Lua does all memory allocation for this state through this function.
The second argument, `ud`, is an opaque pointer that Lua passes to the allocator in every call.

创建一个在新的独立State中执行的线程。返回NULL表示不能创建这个线程或State（由于内存不足）。
参数`f`是内存分配函数；Lua用这个函数为State分配所有内存。
第二个参数`ud`是一个抽象指针，Lua每次调用分配函数时都传人这个指针。

## lua_close [-0, +0, –]
```c
void lua_close (lua_State *L);
```

Destroys all objects in the given Lua state (calling the corresponding garbage-collection metamethods, if any) 
and frees all dynamic memory used by this state. 
On several platforms, you may not need to call this function, 
because all resources are naturally released when the host program ends. 
On the other hand, long-running programs that create multiple states, such as daemons or web servers, 
will probably need to close states as soon as they are not needed.

销毁给定Lua State中的所有对象（通过调用相应垃圾回收云方法，如果存在）并且释放State使用的所有动态内存。
在一些平台上，你可能不必调用这个函数，因为宿主程序结束时会释放所有的资源。
另一方面，长时间运行的创建多个State的程序，如后台程序或服务器程序，应该尽快关掉不再使用的State。

## lua_status [-0, +0, –]
```c
int lua_status (lua_State *L);
```
Returns the status of the thread L.

The status can be 0 (`LUA_OK`) for a normal thread, 
an error code if the thread finished the execution of a `lua_resume` with an error, 
or `LUA_YIELD` if the thread is suspended.

You can only call functions in threads with status `LUA_OK`. 
You can resume threads with status `LUA_OK` (to start a new coroutine) or `LUA_YIELD` (to resume a coroutine).

返回指定线程的状态。
状态可以是0（`LUA_OK`）对于正常线程；一个错误代码对于已执行完毕的`lua_resume`线程；
或是`LUA_YIELD`对于暂停的线程。

只有状态是`LUA_OK`时才能去调用函数。
可以`lua_resume`一个线程当状态是`LUA_OK`时（开启新线程）或是`LUA_YIELD`时（重新启动线程）。

## lua_getextraspace [-0, +0, –]
```c
void* lua_getextraspace(lua_State* L);
```
Returns a pointer to a raw memory area associated with the given Lua state. 
The application can use this area for any purpose; Lua does not use it for anything.

Each new thread has this area initialized with a copy of the area of the main thread.

By default, this area has the size of a pointer to `void`, 
but you can recompile Lua with a different size for this area. (See `LUA_EXTRASPACE` in `luaconf.h`.)

返回与Lua State关联的原始内存指针。
应用可以任意使用这个过内存区域，Lua不会用它做其他事。
每个新线程都会从主线程重新拷贝一份这个区域的内容。
默认这个区域的大小是`void`指针的大小，但可以重新编译Lua改变这个值（见`luaconf.h`中的`LUA_EXTRASPACE`）。


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

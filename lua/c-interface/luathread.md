
## Lua线程

Lua中的线程表示的是协程（coroutine），多个协程可以运行在同一个真实的操作系统线程中。
由于官方文档也将协程称为线程，并且协程的类型也是用`thread`表示的，因此在这里不区分线程和协程，它们都表示同一个概念。

### lua_State
```c
typedef struct lua_State lua_State;
```
> An opaque structure that points to a thread 
and indirectly (through the thread) to the whole state of a Lua interpreter. 
The Lua library is fully reentrant: it has no global variables. 
All information about a state is accessible through this structure.

> A pointer to this structure must be passed as the first argument to every function in the library, 
except to `lua_newstate`, which creates a Lua state from scratch.

结构体lua_State表示一个线程或通过线程间接表示Lua解析器的整体状态。
Lua提供的C接口函数都是可重入的：它们没有全局变量，所有的状态信息都通过这个结构体来访问。
除了创建Lua State的函数之外，其他函数都需要传入这个结构体的指针作为它们的第一个参数。

### lua_newstate [-0, +0, –]
```c
lua_State* lua_newstate(lua_Alloc f, void* ud);
```
> Creates a new thread running in a new, independent state. 
Returns NULL if it cannot create the thread or the state (due to lack of memory). 
The argument `f` is the allocator function; Lua does all memory allocation for this state through this function.
The second argument, `ud`, is an opaque pointer that Lua passes to the allocator in every call.

创建一个新的在独立状态中运行的线程。
返回NULL表示内存不足不能创建这个新线程或Lua State。
参数`f`是内存分配函数，Lua使用这个函数分配所需要的内存。
第二个参数`ud`是用户数据指针，Lua每次调用分配函数时都会传入这个值。

### luaL_newstate [-0, +0, –]
```c
lua_State* luaL_newstate(void);
```
> Creates a new Lua state. 
It calls `lua_newstate` with an allocator based on the standard C `realloc` function 
and then sets a `panic` function (see §4.6) that 
prints an error message to the standard error output in case of fatal errors.
Returns the new state, or NULL if there is a memory allocation error.

相当于`lua_newstate(l_alloc, NULL)`，它使用默认的内存分配函数创建新的Lua State。
并设置`panic`函数，当发生错误时将错误消息打印到标准错误输出。
这个函数返回新创建的Lua State，如果内存分配失败则返回NULL。

### lua_newthread [-0, +1, e]
```c
lua_State* lua_newthread(lua_State* L);
```
> Creates a new thread, pushes it on the stack, 
and returns a pointer to a `lua_State` that represents this new thread. 
The new thread returned by this function shares with the original thread its global environment, 
but has an independent execution stack.

创建一个新的线程，把它压入到栈中，返回代表这个新线程的Lua State指针。
新线程与原线程`L`共享相同的全局环境，但拥有完全独立的Lua栈。

### lua_close [-0, +0, –]
```c
void lua_close (lua_State *L);
```
> Destroys all objects in the given Lua state (calling the corresponding garbage-collection metamethods, if any) 
and frees all dynamic memory used by this state. 
On several platforms, you may not need to call this function, 
because all resources are naturally released when the host program ends. 
On the other hand, long-running programs that create multiple states, such as daemons or web servers, 
will probably need to close states as soon as they are not needed.

通过对应的垃圾收集元方法（如果存在）销毁给定Lua State中的对象并释放所有使用过的动态内存。
在一些平台上可能不需要调用这个函数，因为宿主程序结束时会释放所有的资源。
但如果是长时间运行的创建了多个Lua State的程序（例如后台程序或服务器程序），则应该尽快释放掉不再使用的Lua State。

### lua_status [-0, +0, –]
```c
int lua_status (lua_State *L);
```
> Returns the status of the thread L.
The status can be 0 (`LUA_OK`) for a normal thread, 
an error code if the thread finished the execution of a `lua_resume` with an error, 
or `LUA_YIELD` if the thread is suspended.

> You can only call functions in threads with status `LUA_OK`. 
You can resume threads with status `LUA_OK` (to start a new coroutine) or `LUA_YIELD` (to resume a coroutine).

返回指定线程的状态。正常线程对应的状态是0（`LUA_OK`）；
如果线程`lua_resume`执行完毕后带有错误，对应的状态是这个错误代码；
挂起的线程的状态是`LUA_YIELD`。
只有在`LUA_OK`状态下的线程才能调用函数。
函数`lua_resume`只能在`LUA_OK`状态下（重新启动线程）或`LUA_YIELD`状态（恢复线程）下调用。

### lua_getextraspace [-0, +0, –]
```c
void* lua_getextraspace(lua_State* L);
```
> Returns a pointer to a raw memory area associated with the given Lua state. 
The application can use this area for any purpose; Lua does not use it for anything.
Each new thread has this area initialized with a copy of the area of the main thread.

> By default, this area has the size of a pointer to `void`, 
but you can recompile Lua with a different size for this area. (See `LUA_EXTRASPACE` in `luaconf.h`.)

返回与Lua State关联的原始内存指针。
应用程序可以自由使用这个内存区域，Lua不会用它做其他事。
每个新创建的线程都会从主线程拷贝一份这个区域的内容。
这个区域的默认大小与`void`指针相同，但是可以重新编译Lua改变这个区域的大小
（见头文件`luaconf.h`中宏`LUA_EXTRASPACE`的定义）。

### Yield处理

Internally, Lua uses the C `longjmp` facility to yield a coroutine. 
Therefore, if a C function `foo` calls an API function and this API function yields 
(directly or indirectly by calling another function that yields), 
Lua cannot return to `foo` any more, because the `longjmp` removes its frame from the C stack.

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

在内部，Lua使用C语言的`longjmp`暂停一个协程。
因此，如果C函数`foo`调用一个C API函数，并且这个C API函数会yield（直接的或间接的调用其他函数yield），
Lua就不能再回到`foo`函数中，因为`longjmp`移除了C栈这个函数的frame。

为了避免这样的问题，Lua都会抛出异常当在API调用之间yield的时候，
除这3个函数之外：`lua_yieldk`、`lua_callk`、以及`lua_pcallk`。
这3个函数接收一个继续执行的函数为参数（名为`k`的参数），当yield之后继续这个函数。

为了解释continuation function，我们需要引入一些术语。
Lua中调用的C函数我们称为原始函数。原始函数然后调用上面3个C API函数，它们称为被调函数，
然后被调函数暂定当前的线程（只要被调函数是`lua_yieldk`，
或被调函数是`lua_callk`和`lua_pcallk`并且它们调用的函数有yield）。

假设执行被调函数时当前正在运行的线程被yield，当线程resume时，被调函数最终会执行完毕。
然而，被调函数不会再返回到原始函数中，因为它在C stack中的frame已经被yield破坏掉。
取而代之的是，Lua会调用一个continuation函数，这个给定的传入被调函数中的参数。
如其名字暗示一样，continuation函数应该继续继续original函数中的工作。

As an illustration, consider the following function:

     int original_function (lua_State *L) {
       ...     /* code 1 */
       status = lua_pcall(L, n, m, h);  /* calls Lua */
       ...     /* code 2 */
     }
Now we want to allow the Lua code being run by `lua_pcall` to yield. 
First, we can rewrite our function like here:

     int k (lua_State *L, int status, lua_KContext ctx) {
       ...  /* code 2 */
     }
     
     int original_function (lua_State *L) {
       ...     /* code 1 */
       return k(L, lua_pcall(L, n, m, h), ctx);
     }
In the above code, the new function `k` is a continuation function (with type `lua_KFunction`), 
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

[[TODO？？？]]


### lua_xmove [-?, +?, –]
```c
void lua_xmove (lua_State *from, lua_State *to, int n);
```

Exchange values between different threads of the same state.
This function pops `n` values from the stack `from`, and pushes them onto the stack `to`.

lua_yield

[-?, +?, e]
int lua_yield (lua_State *L, int nresults);
This function is equivalent to lua_yieldk, but it has no continuation (see §4.7). Therefore, when the thread resumes, it continues the function that called the function calling lua_yield.

lua_yieldk

[-?, +?, e]
int lua_yieldk (lua_State *L,
                int nresults,
                lua_KContext ctx,
                lua_KFunction k);
Yields a coroutine (thread).

When a C function calls lua_yieldk, the running coroutine suspends its execution, and the call to lua_resume that started this coroutine returns. The parameter nresults is the number of values from the stack that will be passed as results to lua_resume.

When the coroutine is resumed again, Lua calls the given continuation function k to continue the execution of the C function that yielded (see §4.7). This continuation function receives the same stack from the previous function, with the n results removed and replaced by the arguments passed to lua_resume. Moreover, the continuation function receives the value ctx that was passed to lua_yieldk.

Usually, this function does not return; when the coroutine eventually resumes, it continues executing the continuation function. However, there is one special case, which is when this function is called from inside a line hook (see §4.9). In that case, lua_yieldk should be called with no continuation (probably in the form of lua_yield), and the hook should return immediately after the call. Lua will yield and, when the coroutine resumes again, it will continue the normal execution of the (Lua) function that triggered the hook.

This function can raise an error if it is called from a thread with a pending C call with no continuation function, or it is called from a thread that is not running inside a resume (e.g., the main thread).

### lua_resume [-?, +?, –]
```c
int lua_resume(lua_State* L, lua_State* from, int nargs);
```
> Starts and resumes a coroutine in the given thread L.
To start a coroutine, you push onto the thread stack the main function plus any arguments; 
then you call `lua_resume`, with `nargs` being the number of arguments. 
This call returns when the coroutine suspends or finishes its execution. 
When it returns, the stack contains all values passed to `lua_yield`, or all values returned by the body function. 
`lua_resume` returns `LUA_YIELD` if the coroutine yields, 
`LUA_OK` if the coroutine finishes its execution without errors, or an error code in case of errors (see `lua_pcall`).

In case of errors, the stack is not unwound, so you can use the debug API over it. 
The error message is on the top of the stack.
To resume a coroutine, you remove any results from the last `lua_yield`, 
put on its stack only the values to be passed as results from yield, and then call lua_resume.
The parameter from represents the coroutine that is resuming `L`. 
If there is no such coroutine, this parameter can be NULL.

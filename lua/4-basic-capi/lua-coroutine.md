
## 4.7 Handling Yields in C

Internally, Lua uses the C `longjmp` facility to yield a coroutine. 
Therefore, if a C function `foo` calls an API function and this API function yields 
(directly or indirectly by calling another function that yields), 
Lua cannot return to `foo` any more, because the `longjmp` removes its frame from the C stack.

在内部，Lua使用C语言的`longjmp`暂停一个协程。
因此，如果C函数`foo`调用一个C API函数，并且这个C API函数会yield（直接的或间接的调用其他函数yield），
Lua就不能再回到`foo`函数中，因为`longjmp`移除了C栈这个函数的frame。

To avoid this kind of problem, Lua raises an error whenever it tries to yield across an API call, 
except for three functions: `lua_yieldk`, `lua_callk`, and `lua_pcallk`. 
All those functions receive a continuation function (as a parameter named `k`) to continue execution after a yield.

为了避免这样的问题，Lua都会抛出异常当在API调用之间yield的时候，
除这3个函数之外：`lua_yieldk`、`lua_callk`、以及`lua_pcallk`。
这3个函数接收一个继续执行的函数为参数（名为`k`的参数），当yield之后继续这个函数。

We need to set some terminology to explain continuations. 
We have a C function called from Lua which we will call the original function. 
This original function then calls one of those three functions in the C API, 
which we will call the callee function, that then yields the current thread. 
(This can happen when the callee function is `lua_yieldk`, 
or when the callee function is either `lua_callk` or `lua_pcallk` and the function called by them yields.)

为了解释continuation function，我们需要引入一些术语。
Lua中调用的C函数我们称为原始函数。原始函数然后调用上面3个C API函数，它们称为被调函数，
然后被调函数暂定当前的线程（只要被调函数是`lua_yieldk`，
或被调函数是`lua_callk`和`lua_pcallk`并且它们调用的函数有yield）。

Suppose the running thread yields while executing the callee function. 
After the thread resumes, it eventually will finish running the callee function. 
However, the callee function cannot return to the original function, 
because its frame in the C stack was destroyed by the yield. 
Instead, Lua calls a continuation function, which was given as an argument to the callee function. 
As the name implies, the continuation function should continue the task of the original function.

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

[[TODO？？？]]

Lua treats the continuation function as if it were the original function. 
The continuation function receives the same Lua stack from the original function, 
in the same state it would be if the callee function had returned. 
(For instance, after a lua_callk the function and its arguments are removed from the stack and 
replaced by the results from the call.) It also has the same upvalues. 
Whatever it returns is handled by Lua as if it were the return of the original function.

[[TODO？？？]]

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


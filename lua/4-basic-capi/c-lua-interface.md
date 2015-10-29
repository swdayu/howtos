
# 4. The Application Program Interface

This section describes the C API for Lua, that is, the set of C functions available to the host program to communicate with Lua. All API functions and related types and constants are declared in the header file lua.h.

Even when we use the term "function", any facility in the API may be provided as a macro instead. Except where stated otherwise, all such macros use each of their arguments exactly once (except for the first argument, which is always a Lua state), and so do not generate any hidden side-effects.

As in most C libraries, the Lua API functions do not check their arguments for validity or consistency. However, you can change this behavior by compiling Lua with the macro LUA_USE_APICHECK defined.

## 4.1 The Stack

Lua uses a virtual stack to pass values to and from C. Each element in this stack represents a Lua value (nil, number, string, etc.).

Whenever Lua calls C, the called function gets a new stack, which is independent of previous stacks and of stacks of C functions that are still active. This stack initially contains any arguments to the C function and it is where the C function pushes its results to be returned to the caller (see lua_CFunction).

For convenience, most query operations in the API do not follow a strict stack discipline. Instead, they can refer to any element in the stack by using an index: A positive index represents an absolute stack position (starting at 1); a negative index represents an offset relative to the top of the stack. More specifically, if the stack has n elements, then index 1 represents the first element (that is, the element that was pushed onto the stack first) and index n represents the last element; index -1 also represents the last element (that is, the element at the top) and index -n represents the first element.

## 4.2 Stack Size

When you interact with the Lua API, you are responsible for ensuring consistency. In particular, you are responsible for controlling stack overflow. You can use the function lua_checkstack to ensure that the stack has enough space for pushing new elements.

Whenever Lua calls C, it ensures that the stack has space for at least LUA_MINSTACK extra slots. LUA_MINSTACK is defined as 20, so that usually you do not have to worry about stack space unless your code has loops pushing elements onto the stack.

When you call a Lua function without a fixed number of results (see lua_call), Lua ensures that the stack has enough space for all results, but it does not ensure any extra space. So, before pushing anything in the stack after such a call you should use lua_checkstack.

## 4.3 Valid and Acceptable Indices

Any function in the API that receives stack indices works only with valid indices or acceptable indices.

A valid index is an index that refers to a position that stores a modifiable Lua value. It comprises stack indices between 1 and the stack top (1 ≤ abs(index) ≤ top) plus pseudo-indices, which represent some positions that are accessible to C code but that are not in the stack. Pseudo-indices are used to access the registry (see §4.5) and the upvalues of a C function (see §4.4).

Functions that do not need a specific mutable position, but only a value (e.g., query functions), can be called with acceptable indices. An acceptable index can be any valid index, but it also can be any positive index after the stack top within the space allocated for the stack, that is, indices up to the stack size. (Note that 0 is never an acceptable index.) Except when noted otherwise, functions in the API work with acceptable indices.

Acceptable indices serve to avoid extra tests against the stack top when querying the stack. For instance, a C function can query its third argument without the need to first check whether there is a third argument, that is, without the need to check whether 3 is a valid index.

For functions that can be called with acceptable indices, any non-valid index is treated as if it contains a value of a virtual type LUA_TNONE, which behaves like a nil value.

## 4.4 C Closures

When a C function is created, it is possible to associate some values with it, thus creating a C closure (see lua_pushcclosure); these values are called upvalues and are accessible to the function whenever it is called.

Whenever a C function is called, its upvalues are located at specific pseudo-indices. These pseudo-indices are produced by the macro lua_upvalueindex. The first upvalue associated with a function is at index lua_upvalueindex(1), and so on. Any access to lua_upvalueindex(n), where n is greater than the number of upvalues of the current function (but not greater than 256), produces an acceptable but invalid index.

## 4.5 Registry

Lua provides a registry, a predefined table that can be used by any C code to store whatever Lua values it needs to store. The registry table is always located at pseudo-index LUA_REGISTRYINDEX. Any C library can store data into this table, but it must take care to choose keys that are different from those used by other libraries, to avoid collisions. Typically, you should use as key a string containing your library name, or a light userdata with the address of a C object in your code, or any Lua object created by your code. As with variable names, string keys starting with an underscore followed by uppercase letters are reserved for Lua.

The integer keys in the registry are used by the reference mechanism (see luaL_ref) and by some predefined values. Therefore, integer keys must not be used for other purposes.

When you create a new Lua state, its registry comes with some predefined values. These predefined values are indexed with integer keys defined as constants in lua.h. The following constants are defined:

LUA_RIDX_MAINTHREAD: At this index the registry has the main thread of the state. (The main thread is the one created together with the state.)
LUA_RIDX_GLOBALS: At this index the registry has the global environment.

## 4.6 Error Handling in C

Internally, Lua uses the C longjmp facility to handle errors. (Lua will use exceptions if you compile it as C++; search for LUAI_THROW in the source code for details.) When Lua faces any error (such as a memory allocation error, type errors, syntax errors, and runtime errors) it raises an error; that is, it does a long jump. A protected environment uses setjmp to set a recovery point; any error jumps to the most recent active recovery point.

If an error happens outside any protected environment, Lua calls a panic function (see lua_atpanic) and then calls abort, thus exiting the host application. Your panic function can avoid this exit by never returning (e.g., doing a long jump to your own recovery point outside Lua).

The panic function runs as if it were a message handler (see §2.3); in particular, the error message is at the top of the stack. However, there is no guarantee about stack space. To push anything on the stack, the panic function must first check the available space (see §4.2).

Most functions in the API can raise an error, for instance due to a memory allocation error. The documentation for each function indicates whether it can raise errors.

Inside a C function you can raise an error by calling lua_error.

## 4.7 Handling Yields in C

Internally, Lua uses the C longjmp facility to yield a coroutine. Therefore, if a C function foo calls an API function and this API function yields (directly or indirectly by calling another function that yields), Lua cannot return to foo any more, because the longjmp removes its frame from the C stack.

To avoid this kind of problem, Lua raises an error whenever it tries to yield across an API call, except for three functions: lua_yieldk, lua_callk, and lua_pcallk. All those functions receive a continuation function (as a parameter named k) to continue execution after a yield.

We need to set some terminology to explain continuations. We have a C function called from Lua which we will call the original function. This original function then calls one of those three functions in the C API, which we will call the callee function, that then yields the current thread. (This can happen when the callee function is lua_yieldk, or when the callee function is either lua_callk or lua_pcallk and the function called by them yields.)

Suppose the running thread yields while executing the callee function. After the thread resumes, it eventually will finish running the callee function. However, the callee function cannot return to the original function, because its frame in the C stack was destroyed by the yield. Instead, Lua calls a continuation function, which was given as an argument to the callee function. As the name implies, the continuation function should continue the task of the original function.

As an illustration, consider the following function:

     int original_function (lua_State *L) {
       ...     /* code 1 */
       status = lua_pcall(L, n, m, h);  /* calls Lua */
       ...     /* code 2 */
     }
Now we want to allow the Lua code being run by lua_pcall to yield. First, we can rewrite our function like here:

     int k (lua_State *L, int status, lua_KContext ctx) {
       ...  /* code 2 */
     }
     
     int original_function (lua_State *L) {
       ...     /* code 1 */
       return k(L, lua_pcall(L, n, m, h), ctx);
     }
In the above code, the new function k is a continuation function (with type lua_KFunction), which should do all the work that the original function was doing after calling lua_pcall. Now, we must inform Lua that it must call k if the Lua code being executed by lua_pcall gets interrupted in some way (errors or yielding), so we rewrite the code as here, replacing lua_pcall by lua_pcallk:

     int original_function (lua_State *L) {
       ...     /* code 1 */
       return k(L, lua_pcallk(L, n, m, h, ctx2, k), ctx1);
     }
Note the external, explicit call to the continuation: Lua will call the continuation only if needed, that is, in case of errors or resuming after a yield. If the called function returns normally without ever yielding, lua_pcallk (and lua_callk) will also return normally. (Of course, instead of calling the continuation in that case, you can do the equivalent work directly inside the original function.)

Besides the Lua state, the continuation function has two other parameters: the final status of the call plus the context value (ctx) that was passed originally to lua_pcallk. (Lua does not use this context value; it only passes this value from the original function to the continuation function.) For lua_pcallk, the status is the same value that would be returned by lua_pcallk, except that it is LUA_YIELD when being executed after a yield (instead of LUA_OK). For lua_yieldk and lua_callk, the status is always LUA_YIELD when Lua calls the continuation. (For these two functions, Lua will not call the continuation in case of errors, because they do not handle errors.) Similarly, when using lua_callk, you should call the continuation function with LUA_OK as the status. (For lua_yieldk, there is not much point in calling directly the continuation function, because lua_yieldk usually does not return.)

Lua treats the continuation function as if it were the original function. The continuation function receives the same Lua stack from the original function, in the same state it would be if the callee function had returned. (For instance, after a lua_callk the function and its arguments are removed from the stack and replaced by the results from the call.) It also has the same upvalues. Whatever it returns is handled by Lua as if it were the return of the original function.

## 4.8 Functions and Types

Here we list all functions and types from the C API in alphabetical order. Each function has an indicator like this: [-o, +p, x]

The first field, o, is how many elements the function pops from the stack. The second field, p, is how many elements the function pushes onto the stack. (Any function always pushes its results after popping its arguments.) A field in the form x|y means the function can push (or pop) x or y elements, depending on the situation; an interrogation mark '?' means that we cannot know how many elements the function pops/pushes by looking only at its arguments (e.g., they may depend on what is on the stack). The third field, x, tells whether the function may raise errors: '-' means the function never raises any error; 'e' means the function may raise errors; 'v' means the function may raise an error on purpose.


# 4. The Application Program Interface

This section describes the C API for Lua, that is, 
the set of C functions available to the host program to communicate with Lua. 
All API functions and related types and constants are declared in the header file `lua.h`.

这里介绍Lua的C API，宿主语言可以使用这些函数与Lua交互。
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
受保护的环境使用`setjmp`设置恢复点，遇到任何错误时跳转到最近恢复点。

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

大多API函数会触发异常，例如由内存分配错误触发。
每个API文档都指明了是否触发异常。C函数中，你可以调用`lua_error`触发异常。

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

## lua_State

typedef struct lua_State lua_State;
An opaque structure that points to a thread and indirectly (through the thread) to the whole state of a Lua interpreter. The Lua library is fully reentrant: it has no global variables. All information about a state is accessible through this structure.

A pointer to this structure must be passed as the first argument to every function in the library, except to lua_newstate, which creates a Lua state from scratch.

## lua_status [-0, +0, –]
```c
int lua_status (lua_State *L);
```
Returns the status of the thread L.

The status can be 0 (LUA_OK) for a normal thread, an error code if the thread finished the execution of a lua_resume with an error, or LUA_YIELD if the thread is suspended.

You can only call functions in threads with status LUA_OK. You can resume threads with status LUA_OK (to start a new coroutine) or LUA_YIELD (to resume a coroutine).

lua_newstate

[-0, +0, –]
lua_State *lua_newstate (lua_Alloc f, void *ud);
Creates a new thread running in a new, independent state. Returns NULL if it cannot create the thread or the state (due to lack of memory). The argument f is the allocator function; Lua does all memory allocation for this state through this function. The second argument, ud, is an opaque pointer that Lua passes to the allocator in every call.

lua_close

[-0, +0, –]
void lua_close (lua_State *L);
Destroys all objects in the given Lua state (calling the corresponding garbage-collection metamethods, if any) and frees all dynamic memory used by this state. On several platforms, you may not need to call this function, because all resources are naturally released when the host program ends. On the other hand, long-running programs that create multiple states, such as daemons or web servers, will probably need to close states as soon as they are not needed.

lua_type

[-0, +0, –]
int lua_type (lua_State *L, int index);
Returns the type of the value in the given valid index, or LUA_TNONE for a non-valid (but acceptable) index. The types returned by lua_type are coded by the following constants defined in lua.h: LUA_TNIL (0), LUA_TNUMBER, LUA_TBOOLEAN, LUA_TSTRING, LUA_TTABLE, LUA_TFUNCTION, LUA_TUSERDATA, LUA_TTHREAD, and LUA_TLIGHTUSERDATA.

lua_typename

[-0, +0, –]
const char *lua_typename (lua_State *L, int tp);
Returns the name of the type encoded by the value tp, which must be one the values returned by lua_type.

lua_Integer

typedef ... lua_Integer;
The type of integers in Lua.

By default this type is long long, (usually a 64-bit two-complement integer), but that can be changed to long or int (usually a 32-bit two-complement integer). (See LUA_INT_TYPE in luaconf.h.)

Lua also defines the constants LUA_MININTEGER and LUA_MAXINTEGER, with the minimum and the maximum values that fit in this type.

lua_Unsigned

typedef ... lua_Unsigned;
The unsigned version of lua_Integer.

lua_Number

typedef ... lua_Number;
The type of floats in Lua.

By default this type is double, but that can be changed to a single float or a long double. (See LUA_FLOAT_TYPE in luaconf.h.)

lua_version

[-0, +0, v]
const lua_Number *lua_version (lua_State *L);
Returns the address of the version number stored in the Lua core. When called with a valid lua_State, returns the address of the version used to create that state. When called with NULL, returns the address of the version running the call.

lua_Alloc

typedef void * (*lua_Alloc) (void *ud,
                             void *ptr,
                             size_t osize,
                             size_t nsize);
The type of the memory-allocation function used by Lua states. The allocator function must provide a functionality similar to realloc, but not exactly the same. Its arguments are ud, an opaque pointer passed to lua_newstate; ptr, a pointer to the block being allocated/reallocated/freed; osize, the original size of the block or some code about what is being allocated; and nsize, the new size of the block.

When ptr is not NULL, osize is the size of the block pointed by ptr, that is, the size given when it was allocated or reallocated.

When ptr is NULL, osize encodes the kind of object that Lua is allocating. osize is any of LUA_TSTRING, LUA_TTABLE, LUA_TFUNCTION, LUA_TUSERDATA, or LUA_TTHREAD when (and only when) Lua is creating a new object of that type. When osize is some other value, Lua is allocating memory for something else.

Lua assumes the following behavior from the allocator function:

When nsize is zero, the allocator must behave like free and return NULL.

When nsize is not zero, the allocator must behave like realloc. The allocator returns NULL if and only if it cannot fulfill the request. Lua assumes that the allocator never fails when osize >= nsize.

Here is a simple implementation for the allocator function. It is used in the auxiliary library by luaL_newstate.

     static void *l_alloc (void *ud, void *ptr, size_t osize,
                                                size_t nsize) {
       (void)ud;  (void)osize;  /* not used */
       if (nsize == 0) {
         free(ptr);
         return NULL;
       }
       else
         return realloc(ptr, nsize);
     }
Note that Standard C ensures that free(NULL) has no effect and that realloc(NULL,size) is equivalent to malloc(size). This code assumes that realloc does not fail when shrinking a block. (Although Standard C does not ensure this behavior, it seems to be a safe assumption.)

lua_getallocf

[-0, +0, –]
lua_Alloc lua_getallocf (lua_State *L, void **ud);
Returns the memory-allocation function of a given state. If ud is not NULL, Lua stores in *ud the opaque pointer given when the memory-allocator function was set.

lua_atpanic

[-0, +0, –]
lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf);
Sets a new panic function and returns the old one (see §4.6).

lua_error

[-1, +0, v]
int lua_error (lua_State *L);
Generates a Lua error, using the value at the top of the stack as the error object. This function does a long jump, and therefore never returns (see luaL_error).

lua_gc

[-0, +0, e]
int lua_gc (lua_State *L, int what, int data);
Controls the garbage collector.

This function performs several tasks, according to the value of the parameter what:

LUA_GCSTOP: stops the garbage collector.
LUA_GCRESTART: restarts the garbage collector.
LUA_GCCOLLECT: performs a full garbage-collection cycle.
LUA_GCCOUNT: returns the current amount of memory (in Kbytes) in use by Lua.
LUA_GCCOUNTB: returns the remainder of dividing the current amount of bytes of memory in use by Lua by 1024.
LUA_GCSTEP: performs an incremental step of garbage collection.
LUA_GCSETPAUSE: sets data as the new value for the pause of the collector (see §2.5) and returns the previous value of the pause.
LUA_GCSETSTEPMUL: sets data as the new value for the step multiplier of the collector (see §2.5) and returns the previous value of the step multiplier.
LUA_GCISRUNNING: returns a boolean that tells whether the collector is running (i.e., not stopped).
For more details about these options, see collectgarbage.

lua_getextraspace

[-0, +0, –]
void *lua_getextraspace (lua_State *L);
Returns a pointer to a raw memory area associated with the given Lua state. The application can use this area for any purpose; Lua does not use it for anything.

Each new thread has this area initialized with a copy of the area of the main thread.

By default, this area has the size of a pointer to void, but you can recompile Lua with a different size for this area. (See LUA_EXTRASPACE in luaconf.h.)

## lua_next [-1, +(2|0), e]
```c
int lua_next (lua_State *L, int index);
```

Pops a key from the stack, and pushes a key–value pair from the table at the given index 
(the "next" pair after the given key). If there are no more elements in the table, 
then `lua_next` returns 0 (and pushes nothing).

A typical traversal looks like this:
```c
/* table is in the stack at index 't' */
lua_pushnil(L);  /* first key */
while (lua_next(L, t) != 0) {
  /* uses 'key' (at index -2) and 'value' (at index -1) */
  printf("%s - %s\n",
    lua_typename(L, lua_type(L, -2)),
    lua_typename(L, lua_type(L, -1)));
  /* removes 'value'; keeps 'key' for next iteration */
  lua_pop(L, 1);
}
```
While traversing a table, do not call `lua_tolstring` directly on a key, 
unless you know that the key is actually a string. 
Recall that `lua_tolstring` may change the value at the given index; this confuses the next call to `lua_next`.

See function `next` for the caveats of modifying the table during its traversal.

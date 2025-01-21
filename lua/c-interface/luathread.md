
# Lua线程

Lua中的线程其实是协程（coroutine），它使用lua_State结构体来表示，多个协程可以运行在同一个真实的操作系统线程中。
由于官方文档也将协程称为线程，并且协程的类型也用`thread`来表示，因此这里不区分线程和协程，它们都表示同一个概念。

## lua_State
```c
typedef struct lua_State lua_State;
```
> An opaque structure that points to a thread 
and indirectly (through the thread) to the whole state of a Lua interpreter. 
The Lua library is fully reentrant: it has no global variables. 
All information about a state is accessible through this structure.

> A pointer to this structure must be passed as the first argument to every function in the library, 
except to `lua_newstate`, which creates a Lua state from scratch.

结构体lua_State表示一个线程并通过线程间接表示Lua解析器的整体状态。
Lua提供的C接口函数都是可重入的：它们没有全局变量，所有的状态信息都通过这个结构体来访问。
除了创建Lua状态的函数之外，其他函数都需要传入这个结构体的指针作为它们的第一个参数。

```c
//@[lua_State]保存每个独立Lua线程的状态
struct lua_State {
  CommonHeader;                                                           //GC对象共用头部
  unsigned short nci;  /* number of items in 'ci' list */                 //调用信息链表中的元素个数
  lu_byte status;                                                         //线程状态
  StkId top;  /* first free slot in the stack */                          //指向当前可用栈元素
  global_State* l_G;                                                      //指向所有线程共享的全局状态
  CallInfo* ci;  /* call info for current function */                     //当前函数调用信息
  const Instruction* oldpc;  /* last pc traced */
  StkId stack_last;  /* last free slot in the stack */                    //Lua保留[stack_last, stack+stacksize)
  StkId stack;  /* stack base */                                          //可用栈空间[stack, stack_last)
  UpVal* openupval;  /* list of open upvalues in this stack */
  GCObject* gclist;
  struct lua_State* twups;  /* list of threads with open upvalues */
  struct lua_longjmp* errorJmp;  /* current error recover point */
  CallInfo base_ci;  /* CallInfo for first level (C calling Lua) */
  lua_Hook hook;
  ptrdiff_t errfunc;  /* current error handling function (stack index) */ //当前错误处理函数栈索引
  int stacksize;                                                          //栈最大元素个数
  int basehookcount;
  int hookcount;
  unsigned short nny;  /* number of non-yieldable calls in stack */       //非yield调用深度
  unsigned short nCcalls;  /* number of nested C calls */                 //嵌套调用深度
  lu_byte hookmask;
  lu_byte allowhook;
};
```

## lua_newstate [-0, +0, –]
```c
lua_State* lua_newstate(lua_Alloc f, void* ud);
```
> Creates a new thread running in a new, independent state. 
Returns NULL if it cannot create the thread or the state (due to lack of memory). 
The argument `f` is the allocator function; Lua does all memory allocation for this state through this function.
The second argument, `ud`, is an opaque pointer that Lua passes to the allocator in every call.

创建一个新的在独立状态中运行的线程。
返回NULL表示内存不足不能创建这个新线程或Lua状态。
参数`f`是内存分配函数，Lua使用这个函数分配所需要的内存。
第二个参数`ud`是用户数据指针，Lua每次调用分配函数时都会传入这个值。

### 代码追踪
```c
// 1. 该函数首先使用内存分配函数`f`分配一个结构体LG，它包含全局状态g、Lua状态l.l、以及额外内存l.extra_；
// 然后对这个结构体进行初始化，最后返回这个结构体中的Lua状态的指针&l.l
#define LUA_EXTRASPACE	(sizeof(void*)) // 额外内存默认大小是一个指针
typedef struct LG {
  LX l -> lu_byte extra_[LUA_EXTRASPACE]; 
          lua_State l;
  global_State g;
} LG;

// 2. 传入函数的参数保存在全局状态frealloc和ud中；
// 新分配的结构体中的Lua状态L称为该全局状态的主线程，关联在全局状态mainthread中；
// 而C语言可以访问的Lua注册表保存在全局状态l_registery中;
// 通过Lua状态L，用L->l_G或G(L)可以访问到全局状态，用lua_getextraspace(L)可以获取到额外内存的地址，
// 用fromstate(L)可以获取到分配的结构体的首地址；
L = &l.l;
L->l_G = g;
g->frealloc = f;
g->ud = ud;
g->mainthread = L;
setnilvalue(g->l_registry);
#define G(L) L->l_G
#define lua_getextraspace(L) ((void *)((char *)(L) - LUA_EXTRASPACE))
#define fromstate(L) (cast(LX *, cast(lu_byte *, (L)) - offsetof(LX, l)))

// 3. 最后调用f_luaopen函数执行一系列的初始化工作
void f_luaopen (lua_State *L, void *ud) {
  global_State *g = G(L);
  stack_init(L, L);     // 初始化Lua状态中的Lua栈
  init_registry(L, g);  // 初始化全局状态中的注册表
  luaS_init(L); luaT_init(L); luaX_init(L); // 其他一些初始化
  // ...
}

// 4. 初始化Lua虚拟栈:
// L->stack分配Lua值TValue的一个数组，大小默认是40个（保存在L->stacksize中），每个元素都被初始化为nil
// 40个元素中，Lua保留最后5个（EXTRA_STACK）作为额外空间使用，L->stack_last指向栈中额外空间的第1个元素
// L->top表示栈中可以使用的第1个元素，因此宿主程序可以使用的栈空间范围是[L->top, L->stack_last)
void stack_init (lua_State* L, lua_State* hint) {
  int i; CallInfo *ci;
  // 分配Lua状态的虚拟栈并将所有元素都初始化成nil
  L->stack = luaM_newvector(hint, BASIC_STACK_SIZE, TValue);
  L->stacksize = BASIC_STACK_SIZE; 
  for (i = 0; i < BASIC_STACK_SIZE; i++) setnilvalue(L->stack + i); 
  // Lua保留5个额外空间，宿主程序可以使用的空间从L->top到L->stack_last
  L->top = L->stack; 
  L->stack_last = L->stack + L->stacksize - EXTRA_STACK;
  // 初始化Lua状态中第一个函数的调用信息（L->base_ci），并将当前函数的调用信息指向它（L->ci = &L->base_ci）
  ci = &L->base_ci; ci->next = ci->previous = NULL; ci->callstatus = 0; 
  ci->func = L->top; setnilvalue(L->top++);     // 第一个函数初始化为nil
  ci->top = L->top + LUA_MINSTACK; L->ci = ci;  // 当前函数可以使用的空间默认为20个元素（LUA_MINSTACK）
}

// 4.1 Lua栈中的调用信息：
// 先初始化第一个函数的调用信息（L->base_ci），并将第一个函数初始化为nil
// 此时base_ci.func表示函数在栈中的索引，初始化后L->top等于`base_ci.func + 1`
// base_ci.top表示该函数可以访问的Lua栈的顶部，最后将当前函数调用信息指向第一个函数的调用信息（L->ci = &L->base_ci）
// 因此初始化后当前函数可以使用的栈空间的范围是[ci->func+1, ci->top)，默认为20个元素
struct lua_State {
  CallInfo* ci;     // 当前函数的调用信息
  CallInfo base_ci; // 第一个函数的调用信息
};
typedef struct CallInfo {
  StkId func;                       // 当前函数在栈中的索引
  StkId	top;                        // 当前函数可以使用的栈的顶部
  struct CallInfo *previous, *next; // 动态调用链
  union {
    struct { StkId base; const Instruction *savedpc; 
    } l; // Lua函数的信息
    struct { lua_KFunction k; ptrdiff_t old_errfunc; lua_KContext ctx; 
    } c; // C函数的信息，k是Yield时的Continuation函数，ctx是Yield时的上下文信息
  } u;
  ptrdiff_t extra;
  short nresults;     // 当前函数期望返回的结果个数
  lu_byte callstatus; // 当前函数调用状态
} CallInfo;

// 5. 初始化Lua注册表
// Lua注册表保存在全局状态g->l_registry变量中，它有两个预定义值：主线程、全局环境
void init_registry (lua_State *L, global_State *g) {
  TValue temp;
  // 新分配一个注册表关联到全局状态g->l_registry，并将表数组部分的大小设置为2个（LUA_RIDX_LAST）
  Table *registry = luaH_new(L); sethvalue(L, &g->l_registry, registry);
  luaH_resize(L, registry, LUA_RIDX_LAST, 0);
  // 设置第1个预定义值-主线程L：g->registry[LUA_RIDX_MAINTHREAD] = L
  setthvalue(L, &temp, L);
  luaH_setint(L, registry, LUA_RIDX_MAINTHREAD, &temp);
  // 设置第2个预定义值-新分配的全局环境：g->registry[LUA_RIDX_GLOBALS]，全局环境是用于保存Lua全局变量的表
  sethvalue(L, &temp, luaH_new(L));
  luaH_setint(L, registry, LUA_RIDX_GLOBALS, &temp);
}

// 6. 初始化全局状态中的字符串哈希表和字符串缓存
// 设置字符串哈希表的大小，填充有效的字符串到字符串缓存中
typedef struct global_State {
  stringtable strt;         // 字符串哈希表
  TString* memerrmsg;       // 内存错误消息
  Tstring* strcache[53][2]; // 字符串缓存
  // ...
} global_State;
void luaS_init (lua_State *L) {
  // 设置字符串哈希表的大小为128（MINSTRTABSIZE）
  global_State *g = G(L); int i, j;
  luaS_resize(L, MINSTRTABSIZE);
  // 预定义内存错误字符串为"not enough memory"，并设置不让垃圾收集器收集
  g->memerrmsg = luaS_newliteral(L, MEMERRMSG);
  luaC_fix(L, obj2gco(g->memerrmsg));
  // 填充有效的字符串（预定义的内存错误字符串）到字符串缓存中
  for (i = 0; i < STRCACHE_N; i++)
    for (j = 0; j < STRCACHE_M; j++)
      g->strcache[i][j] = g->memerrmsg;
}

// 7. 设置全局状态中的tag-method名称
// luaT_eventname: "__index" "__newindex" "__gc" "__mode" "__len" "__eq" "__add" 
// "__sub" "__mul" "__mod" "__pow" "__div" "__idiv" "__band" "__bor" "__bxor" 
// "__shl" "__shr" "__unm" "__bnot" "__lt" "__le" "__concat" "__call"
typedef struct global_State {
  TString* tmname[TM_N]; // tag-method名称字符串数组
  // ...
} global_State;
void luaT_init (lua_State *L) {
  int i;
  for (i=0; i<TM_N; i++) {
    // 初始化tag-method名称字符串数组，并将这个些字符串设置成不让垃圾收集器进行收集
    G(L)->tmname[i] = luaS_new(L, luaT_eventname[i]);
    luaC_fix(L, obj2gco(G(L)->tmname[i]));
  }
}

// 8. 创建字符串"_ENV"以及Lua保留字符串，并将它们设置成不进行垃圾收集
// 可以进行垃圾收集的对象都保存在全局状态g->allgc列表中
// 不进行垃圾收集的对象保存在全局状态g->fixedgc列表中
// luaX_tokens: "and" "break" "do" "else" "elseif" "end" "false" "for" "function" "goto" "if"
// "in" "local" "nil" "not" "or" "repeat" "return" "then" "true" "until" "while"
// "//" ".." "..." "==" ">=" "<=" "~=" "<<" ">>" "::" "<eof>" "<number>" "<integer>" "<name>" "<string>"
void luaX_init (lua_State *L) {
  int i;
  // 新创建环境字符串"_ENV"，并设置成不让垃圾收集器进行收集
  TString *e = luaS_newliteral(L, LUA_ENV);  // LUA_ENV: "_ENV"
  luaC_fix(L, obj2gco(e));
  // 新创建Lua保留字符串，并将这些字符串设置成不让垃圾收集器收集
  for (i=0; i<NUM_RESERVED; i++) {
    TString *ts = luaS_new(L, luaX_tokens[i]);
    luaC_fix(L, obj2gco(ts));  /* reserved words are never collected */
    ts->extra = cast_byte(i+1);  /* reserved word */
  }
}
```

## luaL_newstate [-0, +0, –]
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

## lua_newthread [-0, +1, e]
```c
lua_State* lua_newthread(lua_State* L);
```
> Creates a new thread, pushes it on the stack, 
and returns a pointer to a `lua_State` that represents this new thread. 
The new thread returned by this function shares with the original thread its global environment, 
but has an independent execution stack.

创建一个新的线程，把它压入到栈中，返回代表这个新线程的Lua State指针。
新线程与原线程`L`共享相同的全局环境，但拥有完全独立的Lua栈。

### 代码追踪
```c
// 1. 新分配一个LX结构体，并对这个结构体进行初始化，最后返回这个结构体中的Lua状态指针&l
typedef struct LX {
  lu_byte extra_[LUA_EXTRASPACE];
  lua_State l;
} LX;
lua_State* lua_newthread(lua_State* parent) {
  global_State *g = G(parent);
  // 将新创建的Lua状态L添加到父状态的栈中
  setthvalue(parent, parent->top, L);
  api_incr_top(parent);
  // 根据父状态对新状态L进行初始化
  preinit_thread(L, g); // Lua状态中关联的全局状态L->l_G会指向parent->l_G
  L->hookmask = parent->hookmask;
  L->basehookcount = parent->basehookcount;
  L->hook = parent->hook;
  resethookcount(L);
  // ...
}

// 2. 将主线程中的额外内存内容拷贝到新Lua状态中，然后分配Lua状态的虚拟栈
// L->stack栈首地址，L->stacksize栈的总大小，宿主程序可以使用的栈空间[L->top, L->stack_last)
// L->ci->func当前函数在栈中的索引，当前函数可以使用的栈空间[L->ci->func+1, L->ci->top)
memcpy(lua_getextraspace(L), lua_getextraspace(g->mainthread), LUA_EXTRASPACE);
stack_init(L, parent);
```

## lua_close [-0, +0, –]
```c
void lua_close(lua_State* L);
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

## lua_status [-0, +0, –]
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

## Yield处理

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

在内部，Lua使用C语言的`longjmp`Yield一个协程。
因此，如果C函数`foo`调用了一个会执行Yield的C接口函数（直接Yield或间接调用其他函数执行Yield），
代码将永远不会再回到`foo`函数中，因为调用`longjmp`的函数永远不会返回，调用这个函数的函数也一样。

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

## lua_xmove [-?, +?, –]
```c
void lua_xmove(lua_State* from, lua_State* to, int n);
```
> Exchange values between different threads of the same state.
This function pops `n` values from the stack `from`, and pushes them onto the stack `to`.

### 代码追踪
```c
// 将from栈中的n个元素拷贝到to栈中
void lua_xmove (lua_State *from, lua_State *to, int n) {
  // 1. 如果两个栈相同，直接返回
  if (from == to) return;
  // 2. 移除from栈的n个元素
  from->top -= n;
  // 3. 将这n个元素拷贝到to栈中
  for (i = 0; i < n; i++) {
    setobj2s(to, to->top, from->top + i);
    to->top++;
  }
}
```

## lua_yield [-?, +?, e]
```c
int lua_yield(lua_State* L, int nresults);
#define lua_yield(L,n) lua_yieldk(L, (n), 0, NULL)
```
> This function is equivalent to `lua_yieldk`, but it has no continuation (see §4.7). 
Therefore, when the thread resumes, it continues the function that called the function calling `lua_yield`.

## lua_yieldk [-?, +?, e]
```c
int lua_yieldk (lua_State *L, int nresults, lua_KContext ctx, lua_KFunction k);
```
> Yields a coroutine (thread).
When a C function calls `lua_yieldk`, the running coroutine suspends its execution, 
and the call to `lua_resume` that started this coroutine returns. 
The parameter `nresults` is the number of values from the stack that will be passed as results to `lua_resume`.

> When the coroutine is resumed again, Lua calls the given continuation function `k` to 
continue the execution of the C function that yielded (see §4.7). 
This continuation function receives the same stack from the previous function, 
with the `n` results removed and replaced by the arguments passed to `lua_resume`. 
Moreover, the continuation function receives the value `ctx` that was passed to `lua_yieldk`.

> Usually, this function does not return; when the coroutine eventually resumes, 
it continues executing the continuation function. 
However, there is one special case, which is when this function is called from inside a line hook (see §4.9). 
In that case, `lua_yieldk` should be called with no continuation (probably in the form of `lua_yield`), 
and the hook should return immediately after the call. 
Lua will yield and, when the coroutine resumes again, 
it will continue the normal execution of the (Lua) function that triggered the hook.

> This function can raise an error if it is called from a thread with a pending C call with no continuation function, 
or it is called from a thread that is not running inside a resume (e.g., the main thread).

## lua_resume [-?, +?, –]
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

> In case of errors, the stack is not unwound, so you can use the debug API over it. 
The error message is on the top of the stack.
To resume a coroutine, you remove any results from the last `lua_yield`, 
put on its stack only the values to be passed as results from yield, and then call `lua_resume`.
The parameter `from` represents the coroutine that is resuming `L`. 
If there is no such coroutine, this parameter can be NULL.

在给定线程L中启动或恢复一个Coroutine。
启动一个Coroutine，首先压入主函数以及所需的参数，然后调用这个函数，指定传入的参数个数。
这个调用当Coroutine挂起或执行完毕时返回。
当这个函数返回时，栈会保存传给lua_yield的所有值，回主函数返回的所有值。
当因为挂起返回时，该函数返回LUA_YIELD，当执行完毕返回时，该函数返回LUA_OK或某种错误代码。

当发生错误时，栈没有展开，可以使用debug API。错误信息对象回放在栈顶部。
Resume一个Coroutine，要移除上一次lua_yield返回的所有结果，...。
参数from表示resume线程L的线程，NULL表示resume线程L的是它自己。

### 代码追踪

```c
//@(lua_resume)
//初始条件：主函数已压入栈中，所需参数也已压入栈中
//调用结果：栈中保存了传入lua_yield的值或主函数返回的结果
int lua_resume(lua_State* L, lua_State* from, int nargs) {
  int status;
  unsigned short oldnny = L->nny;                     //保存旧的nny
  lua_lock(L);                                        //进入Lua核心
  luai_userstateresume(L, nargs);                     //可以为LUAI_EXTRASPACE自定义resume的行为
  L->nCcalls = (from) ? from->nCcalls + 1 : 1;        //嵌套调用深度初始化
  L->nny = 0;  /* allow yields */                     //非yield调用深度设为0，允许被调函数yield
  api_checknelems(L, (L->status == LUA_OK) ? nargs + 1 : nargs); //TODO
  status = luaD_rawrunprotected(L, resume, &nargs);   //保护调用函数resume(L, &nargs) @[luaD_rawrunprotected]
  if (status == -1)                                   //如果错误状态为-1
    status = LUA_ERRRUN;                              //则LUA_ERRRUN
  else {  /* continue running after recoverable errors */
    while (errorstatus(status) && recover(L, status)) {
      /* unroll continuation */
      status = luaD_rawrunprotected(L, unroll, &status);
    }
    if (errorstatus(status)) {  /* unrecoverable error? */
      L->status = cast_byte(status);  /* mark thread as 'dead' */
      seterrorobj(L, status, L->top);  /* push error message */
      L->ci->top = L->top;
    }
    else lua_assert(status == L->status);  /* normal end or yield */
  }
  L->nny = oldnny;  /* restore 'nny' */               //恢复旧的nny
  L->nCcalls--;                                       //调用深度减1
  lua_assert(L->nCcalls == ((from) ? from->nCcalls : 0));
  lua_unlock(L);                                      //退出Lua核心
  return status;
}

/*
** Do the work for 'lua_resume' in protected mode. Most of the work
** depends on the status of the coroutine: initial state, suspended
** inside a hook, or regularly suspended (optionally with a continuation
** function), plus erroneous cases: non-suspended coroutine or dead
** coroutine.
*/
static void resume (lua_State* L, void* ud) {
  int nCcalls = L->nCcalls;
  int n = *(cast(int*, ud));  /* number of arguments */
  StkId firstArg = L->top - n;  /* first argument */
  CallInfo *ci = L->ci;
  if (nCcalls >= LUAI_MAXCCALLS)
    resume_error(L, "C stack overflow", firstArg);
  if (L->status == LUA_OK) {                          //重新启动Coroutine
    if (ci != &L->base_ci)  /* not in base level? */  //当前调用信息必须是调用链第一个调用信息
      resume_error(L, "cannot resume non-suspended coroutine", firstArg);
    /* coroutine is in base level; start running it */
    //执行函数调用：firstArg-1表示被调函数，LUA_MULTRET表示返回函数所有结果
    if (!luaD_precall(L, firstArg - 1, LUA_MULTRET))  //执行C函数或准备Lua函数的调用
      luaV_execute(L);                                //如果是Lua函数，执行这个函数
  }
  else if (L->status != LUA_YIELD)                    //不是从挂起状态恢复Coroutine则报错
    resume_error(L, "cannot resume dead coroutine", firstArg);
  else {  /* resuming from previous yield */          //否则恢复挂起的Coroutine
    L->status = LUA_OK;
    ci->func = restorestack(L, ci->extra);            //使用被调函数的栈索引（ci->extra），获取在当前栈中栈元素指针
    if (isLua(ci))  /* yielded inside a hook? */      //如果在执行Lua函数
      luaV_execute(L);                                //则继续执行Lua函数代码
    else {  /* 'common' yield */                      //如果在执行C函数
      if (ci->u.c.k != NULL) {                        //如果提供了k函数
        lua_unlock(L);
        n = (*ci->u.c.k)(L, LUA_YIELD, ci->u.c.ctx);  //调用k函数
        lua_lock(L);
        api_checknelems(L, n);
        firstArg = L->top - n;  /* yield results come from continuation */
      }
      luaD_poscall(L, ci, firstArg, n);  /* finish 'luaD_precall' */
    }
    unroll(L, NULL);  /* run continuation */
  }
  lua_assert(nCcalls == L->nCcalls);
}

int lua_yieldk(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k) {
  CallInfo *ci = L->ci;
  luai_userstateyield(L, nresults);
  lua_lock(L);
  api_checknelems(L, nresults);
  if (L->nny > 0) {
    if (L != G(L)->mainthread)
      luaG_runerror(L, "attempt to yield across a C-call boundary");
    else
      luaG_runerror(L, "attempt to yield from outside a coroutine");
  }
  L->status = LUA_YIELD;
  ci->extra = savestack(L, ci->func);  /* save current 'func' */
  if (isLua(ci)) {  /* inside a hook? */
    api_check(L, k == NULL, "hooks cannot continue after yielding");
  }
  else {
    if ((ci->u.c.k = k) != NULL)  /* is there a continuation? */
      ci->u.c.ctx = ctx;  /* save context */
    ci->func = L->top - nresults - 1;  /* protect stack below results */
    luaD_throw(L, LUA_YIELD);
  }
  lua_assert(ci->callstatus & CIST_HOOKED);  /* must be inside a hook */
  lua_unlock(L);
  return 0;  /* return to 'luaD_hook' */
}
```

## lua_isyieldable [-0, +0, –]
```c
int lua_isyieldable(lua_State* L);
```
Returns 1 if the given coroutine can yield, and 0 otherwise.

## lua_KContext
```c
typedef ... lua_KContext;
```
The type for continuation-function contexts. It must be a numeric type. 
This type is defined as `intptr_t` when `intptr_t` is available, so that it can store pointers too. 
Otherwise, it is defined as `ptrdiff_t`.

## lua_KFunction
```c
typedef int (*lua_KFunction)(lua_State* L, int status, lua_KContext ctx);
```
Type for continuation functions (see §4.7).



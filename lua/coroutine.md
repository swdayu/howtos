
# 协程

Lua支持协程（也称为协作多线程，collaborative multithreading），每个协程像系统线程一样能独立运行。
不同于系统线程的自动调度，Lua协程要手动调用yield和resume来挂起和恢复。

可以使用coroutine.create创建一个新协程，传入协程的主函数作为参数。
这个函数仅仅创建和返回协程对象，并不启动协程。要启动协程，必须手动调用coroutine.resume。
协程启动后，协程的主函数会被执行，主函数的参数通过resume传入。
协程启动后会一直执行，直到主函数执行完毕、或主函数进入挂起状态、或发生错误。
主函数进入挂起状态后，再次调用resume会使主函数恢复到原来挂起的位置继续执行。
另外coroutine.wrap也用于创建新协程，不同的是它返回一个函数，通过调用这个函数来resume协程。
更详细的信息参考下面的代码分析。

## 创建协程
**coroutine = require "coroutine"**  
**co = coroutine.create(luafn)**
```c
//@[local coroutine = require "coroutine"]
static const luaL_Reg co_funcs[] = {
  {"create", luaB_cocreate},
  {"resume", luaB_coresume},
  {"running", luaB_corunning},
  {"status", luaB_costatus},
  {"wrap", luaB_cowrap},
  {"yield", luaB_yield},
  {"isyieldable", luaB_yieldable},
  {NULL, NULL}
};
int luaopen_coroutine (lua_State* L) {
  luaL_newlib(L, co_funcs); //创建并注册函数到新table中，保留table在栈顶作为结果
  return 1;                 //返回结果个数
}

//@[local co = coroutine.create(luafn)]传入Lua函数作为主函数，返回新创建的协程（其类型为"thread"）
static int luaB_cocreate(lua_State* L) {
  lua_State* NL;
  luaL_checktype(L, 1, LUA_TFUNCTION); //传入的参数必须是Lua函数
  NL = lua_newthread(L);               //创建新协程压入L栈顶，NL共享L的全局状态但拥有自己独立的Lua栈
  lua_pushvalue(L, 1);                 //将主函数拷贝一份压入L栈顶
  lua_xmove(L, NL, 1);                 //将L栈顶的主函数移除，并将它压入NL栈顶
  return 1;                            //此时L栈顶元素为新分配的NL，将它作为结果，返回结果个数1
}
```

## 启动协程
**success, res1, ... = coroutine.resume(co [, val1, ...])**
```c
//@[coroutine.resume(co [, val1, ...])]
//如果协程第一次或重新从头开始执行，会调用协程的主函数，并传入val1,...作为主函数的参数
//--如果执行过程中没有发生错误，主函数要么执行完要么进入yield状态
//  如果成功执行完，函数resume会返回true以及主函数的所有返回值
//  如果进入yield状态，函数resume会返回true以及yield时传入yield函数的参数
//--如果执行过程中发生错误，函数resume会返回false以及一个错误消息
//如果协程处于yield状态，主函数会恢复到原来挂起的代码位置，
//该处的yield函数会返回，并将resume中传入的参数val1,...作为它的返回结果，然后主函数继续执行
//--直到主函数执行完毕、再次进入yield状态、或运行错误返回
static int luaB_coresume(lua_State* L) {
  lua_State* co = getco(L);                    //获取第一个参数[co, va1, ...]
  int r = auxresume(L, co, lua_gettop(L) - 1); //执行resume操作，`lua_gettop(L)-1`表示val1,...参数个数
  if (r < 0) {                                 //执行失败此时L中的元素[co, error_msg]
    lua_pushboolean(L, 0);                     //将false压入栈顶[co, error_msg, false]
    lua_insert(L, -2);                         //将栈顶元素插入到倒数第2个元素位置[co, false, error_msg]
    return 2;                                  //返回结果个数2
  }
  else {                                       //执行成功，此时L中的元素[co, res1, ...]
    lua_pushboolean(L, 1);                     //将true压入栈顶[co, res1, ..., true]
    lua_insert(L, -(r + 1));                   //将栈顶元素插入到倒数第(r+1)个元素位置[co, true, res1, ...]
    return r + 1;                              //返回结果个数r+1
  }
}
static int auxresume(lua_State* L, lua_State* co, int narg) {
  int status;
  if (!lua_checkstack(co, narg)) {                       //确保co有大于narg个空间
    lua_pushliteral(L, "too many arguments to resume");  //如果空间分配失败，压入错误消息到L中
    return -1;  /* error flag */                         //并返回-1表示失败
  }
  if (lua_status(co) == LUA_OK && lua_gettop(co) == 0) { //当协程需要重新执行时，栈顶元素必须是其对应的Lua函数
    lua_pushliteral(L, "cannot resume dead coroutine");  //否则压入错误消息到L中
    return -1;  /* error flag */                         //并返回-1表示失败
  }
  lua_xmove(L, co, narg);                                //将L中的narg个参数移除并添加到co中
  status = lua_resume(co, L, narg);                      //真正执行resume操作，此时Lua函数在co的栈底，其上为narg个参数
  if (status == LUA_OK || status == LUA_YIELD) {         //如果Lua函数执行完毕，或者被yield
    int nres = lua_gettop(co);                           //得到Lua函数返回的参数个数，或yield传递的参数个数
    if (!lua_checkstack(L, nres + 1)) {                  //保证L有大于nres+1个空间（+1是因为luaB_coresume会添加1个布尔值）
      lua_pop(co, nres);  /* remove results anyway */    //如果空间分配失败，将co中返回的结果移除
      lua_pushliteral(L, "too many results to resume");  //将错误消息压入L的栈中
      return -1;  /* error flag */                       //返回-1表示失败
    }
    lua_xmove(co, L, nres);  /* move yielded values */   //将co中的nres个结果移除并添加到L中
    return nres;                                         //返回L中的结果个数
  }
  else {                                                 //如果Lua函数运行出错，会将一个错误消息压入co
    lua_xmove(co, L, 1);  /* move error message */       //将co的错误消息移除并添加到L中
    return -1;  /* error flag */                         //然后返回-1表示失败
  }
}
int lua_resume(lua_State* co, lua_State* from, int nargs) {
  int status;
  unsigned short oldnny = co->nny;
  lua_lock(co);
  luai_userstateresume(co, nargs);                         //可以为LUAI_EXTRASPACE数据自定义resume行为
  co->nCcalls = (from) ? from->nCcalls + 1 : 1;            //根据from线程初始化co的当前函数嵌套深度（深度加1）
  co->nny = 0;  /* allow yields */                         //初始化co当前non-yieldable call嵌套深度，设为0允许函数yield
  api_checknelems(co,(co->status==LUA_OK)?nargs+1:nargs);  //TODO: (L->top - L->ci->func) > (n) ???
  status = luaD_rawrunprotected(co, resume, &nargs);       //保护调用函数resume(co, &nargs) 
    {//@[luaD_rawrunprotected]                             //int luaD_rawrunprotected(lua_State* co, Pfunc f, void *ud)
    unsigned short oldnCcalls = co->nCcalls;               //保存co当前的函数嵌套深度
    struct lua_longjmp lj;
    lj.status = LUA_OK;
    lj.previous = co->errorJmp;                            //保存co原有的longjmp结构体指针
    co->errorJmp = &lj;                                    //更新co的longjmp结构体，然后执行resume保护调用
    LUAI_TRY(co, &lj,                                      //相当于: if (setjmp((&lj)->b) == 0) { resume(co, &nargs); }
      (*f)(co, ud);                                        //如果co对应的函数执行完或被yield之后，都会继续执行下面的代码
    );
    co->errorJmp = lj.previous;                            //恢复co原有的longjmp结构体指针
    co->nCcalls = oldnCcalls;                              //恢复co的函数嵌套深度
    return lj.status;                                      //返回resume执行后的状态
    }
  if (status == -1)                                        //如果错误状态为-1
    status = LUA_ERRRUN;                                   //则LUA_ERRRUN
  else {  /* continue running after recoverable errors */
    while (errorstatus(status) && recover(co, status)) {   //如果是错误状态，并且有恢复点
      /* unroll continuation */
      status = luaD_rawrunprotected(co, unroll, &status);  //保护调用unroll(co, &status)执行展开操作
    }
    if (errorstatus(status)) {  /* unrecoverable error? */ //如果还有错误，表示错误不能恢复
      co->status = cast_byte(status);  /* mark 'dead' */   //将错误状态保存到co的status中
      seterrorobj(co, status, co->top);                    //设置错误消息
      co->ci->top = co->top;                               //TODO
    }
    else lua_assert(status == co->status);                 //否则视为正常返回或yield，返回状态必须与co->status一样
  }
  co->nny = oldnny;  /* restore 'nny' */                   //恢复co原来的non-yieldable call嵌套深度
  co->nCcalls--;                                           //当前调用执行完毕，函数嵌套深度减1
  lua_assert(co->nCcalls == ((from) ? from->nCcalls : 0)); //当前co的函数嵌套深度必须与from相同或为0
  lua_unlock(co);
  return status;
}
```

## 挂起协程
**val1, ... = coroutine.yield([res1, ...])**
```c
//@[coroutine.yield([res1, ...])]
//挂起当前执行的协程，传入的参数都返回给resume函数
static int luaB_yield(lua_State* L) {
  return lua_yield(L, lua_gettop(L));
}
#define lua_yield(L,n) lua_yieldk(L, (n), 0, NULL)
int lua_yieldk(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k) {
  CallInfo* ci = L->ci;
  luai_userstateyield(L, nresults);       //可以为LUAI_EXTRASPACE数据自定义resume行为
  lua_lock(L);
  api_checknelems(L, nresults);           //TODO
  if (L->nny > 0) {                       //不能在non-yieldable调用链中进行yield，值L->nny必须为0
    if (L != G(L)->mainthread)            //否则报运行时错误
      luaG_runerror(L, "attempt to " 
      "yield across a C-call boundary");
    else
      luaG_runerror(L, "attempt to " 
      "yield from outside a coroutine");
  }
  L->status = LUA_YIELD;                  //Lua线程标记成进入yield状态
  ci->extra = savestack(L, ci->func);     //保存当前函数在栈中的绝对索引值
  if (isLua(ci)) {  /* inside a hook? */  //如果当前调用的是Lua函数，用于C使用的k函数必须为NULL
    api_check(L, k == NULL, "hooks "      //TODO: 在Lua函数中yield不需要longjmp???
    "cannot continue after yielding");
  }
  else {                                  //如果调用的是C函数
    if ((ci->u.c.k = k) != NULL)          //如果提供了k函数
      ci->u.c.ctx = ctx;                  //将k函数和ctx值保存当前调用信息中
    /* protect stack below results */
    ci->func = L->top - nresults - 1;     //TODO ???
    luaD_throw(L, LUA_YIELD);             //挂起当前线程并跳转返回到resume函数中
  }                                       //函数luaD_throw会在resume返回后继续resume才会返回执行下面的代码
  lua_assert(ci->callstatus&CIST_HOOKED); //TODO: must be inside a hook
  lua_unlock(L);
  return 0;  /* return to 'luaD_hook' */
}
l_noret luaD_throw (lua_State *L, int errcode) {
  if (L->errorJmp) {  /* thread has an error handler? */
    L->errorJmp->status = errcode;  /* set status */
    LUAI_THROW(L, L->errorJmp);  /* jump to it */
  }
  else {  /* thread has no error handler */
    global_State *g = G(L);
    L->status = cast_byte(errcode);  /* mark it as dead */
    if (g->mainthread->errorJmp) {  /* main thread has a handler? */
      setobjs2s(L, g->mainthread->top++, L->top - 1);  /* copy error obj. */
      luaD_throw(g->mainthread, errcode);  /* re-throw in main thread */
    }
    else {  /* no handler at all; abort */
      if (g->panic) {  /* panic function? */
        seterrorobj(L, errcode, L->top);  /* assume EXTRA_STACK */
        if (L->ci->top < L->top)
          L->ci->top = L->top;  /* pushing msg. can break this invariant */
        lua_unlock(L);
        g->panic(L);  /* call panic function (last chance to jump out) */
      }
      abort();
    }
  }
}
```

## 创建协程二
**resumef = coroutine.wrap(luafn)**  
**res1, ... = resumef([val1, ...])**
```c
//@[coresume = coroutine.wrap(luafn), coresume([val1, ...])]
//返回一个函数，用于resume在wrap中创建的协程
static int luaB_cowrap(lua_State* L) {
  luaB_cocreate(L);                     //创建新协程并压入L栈顶
  lua_pushcclosure(L, luaB_auxwrap, 1); //移除栈顶协程并将它设置作为luaB_auxwrap的上值，将最终的C函数入栈
  return 1;                             //返回结果个数1
}
static int luaB_auxwrap(lua_State* L) {    //注意这种方式遇到错误会抛出异常，而不像resume那样返回错误对象
  lua_State* co = lua_tothread(L, lua_upvalueindex(1)); //获取保存在上值中的协程
  int r = auxresume(L, co, lua_gettop(L)); //执行resume操作，`lua_gettop(L)`表示传入的参数个数（val1,...）
  if (r < 0) {                             //执行失败此时L中的元素为[error_msg]
    if (lua_isstring(L, -1)) {             //如果栈顶的错误消息为字符串类型
      luaL_where(L, 1);                    //产生额外信息字符串"chunkname:currentline:"并压入栈顶
      lua_insert(L, -2);                   //将额外的字符串信息插入到倒数第2个元素位置
      lua_concat(L, 2);                    //此时L中的元素为[extra_str, error_msg], 
    }                                      //将这两个字符串连接变成一个元素[extra_str+error_msg]
    return lua_error(L);                   //将执行失败产生的异常或加入了额外错误信息的异常抛出
  }
  return r;                                //否则执行成功，返回结果个数r
}
void luaL_where(lua_State* L, int level) { //获取Lua状态调用链ci中Level 1层次上的函数的额外信息
  lua_Debug ar;                            //层次Level 0表示当前运行函数（ci），Level 1表示调用当前函数的函数（ci->previous）
  if (lua_getstack(L, level, &ar)) {  /* check function at level */
    lua_getinfo(L, "Sl", &ar);  /* get info about it */
    if (ar.currentline > 0) {  /* is there info? */
      lua_pushfstring(L, "%s:%d: ", ar.short_src, ar.currentline);
      return;
    }
  }
  lua_pushliteral(L, "");  /* else, no information available... */
}
```

## 获取当前运行协程
**co, ismain = coroutine.running()**
```c
//@[coroutine.running()]返回当前运行的协程和一个布尔值表示当前运行的协程是否是主线程
//> Returns the running coroutine plus a boolean, true when the running coroutine is the main one.
static int luaB_corunning(lua_State* L) {
  int ismain = lua_pushthread(L); //将当前L状态对应的线程压入栈顶，并返回一个整数表示这个线程是否是主线程
  lua_pushboolean(L, ismain);     //将表示是否时主线程的整数当做布尔值压入栈顶
  return 2;                       //返回结果个数2
}
```

## 获取协程状态
**yieldable = coroutine.isyieldable()**  
**status_str = coroutine.status(co)**
```c
//@[coroutine.isyieldable()]判断当前运行协程是否能yield
//只要当前运行协程不是主线程，而且没有运行在non-yieldable调用链中，就能够yield
//> A running coroutine is yieldable if it is not the main thread 
//> and it is not inside a non-yieldable C function.
static int luaB_yieldable(lua_State* L) {
  lua_pushboolean(L, lua_isyieldable(L));
  return 1;
}
int lua_isyieldable(lua_State* L) {
  return (L->nny == 0);
}

//@[coroutine.status(co)]以字符串方式返回协程co当前的状态
//"running", if the coroutine is running, the coroutine that called this status function
//"suspended", if the coroutine is suspended in a call to yield, or if it has not started running yet
//"normal", if the coroutine is active but not running (that is, it has resumed another coroutine)
//"dead", if the coroutine has finished its body function, or if it has stopped with an error
static int luaB_costatus(lua_State* L) {
  lua_State* co = getco(L);
  if (L == co) lua_pushliteral(L, "running");
  else {
    switch (lua_status(co)) {
    case LUA_YIELD:
      lua_pushliteral(L, "suspended");
      break;
    case LUA_OK: {
      lua_Debug ar;
      if (lua_getstack(co, 0, &ar) > 0)  /* does it have frames? */
        lua_pushliteral(L, "normal");  /* it is running */
      else if (lua_gettop(co) == 0)
        lua_pushliteral(L, "dead");
      else
        lua_pushliteral(L, "suspended");  /* initial state */
      break;
    }
    default:  /* some error occurred */
      lua_pushliteral(L, "dead");
      break;
    }
  }
  return 1;
}
```

## 协程示例
```lua
function foo(a)
  print("foo", a)
  return coroutine.yield(2*a)
end

co = coroutine.create(function(a, b)
  print("co-body", a, b)
  local r = foo(a+1)
  print("co-body", r)
  local r, s = coroutine.yield(a+b, a-b)
  print("co-body", r, s)
  return b, "end"
end)

print("main", coroutine.resume(co, 1, 10))
print("main", coroutine.resume(co, "r"))
print("main", coroutine.resume(co, "x", "y"))
print("main", coroutine.resume(co, "x", "y"))
```
它的执行流程为：
```
RESUME(1, 10)
print("co-body", 1, 10)         ==> co-body  1      10
local r = foo(1 + 1)
  print("foo", 2)               ==> foo      2
  return YIELD(4)

print("main", true, 4)          ==> main     true   4 

  RESUME("r")
  return "r"
r = "r"
print("co-body", r)             ==> co-body  r
local r, s = YIELD(11, -9)

print("main", true, 11, -9)     ==> main     true   11     -9

RESUME("x", "y")
r, s = "x", "y"
print("co-body", r, s)          ==> co-body  x      y
return 10, "end"

print("main", true, 10, "end")  ==> main     true   10     end

print("main", RESUME("x", "y")) ==> main     false  cannot resume dead coroutine
```

## 通过C API使用协程

```c
lua_newthread
lua_resume
lua_yield
```

## 协程结构体详解



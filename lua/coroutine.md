
# 协程

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

//@[local co = coroutine.create(luafn)]传入Lua函数，返回新创建的协程（其类型为"thread"）
static int luaB_cocreate(lua_State* L) {
  lua_State* NL;
  luaL_checktype(L, 1, LUA_TFUNCTION); //传入的参数必须是Lua函数
  NL = lua_newthread(L);               //创建线程压入L的栈中，NL共享L的全局状态但拥有自己独立的Lua栈
  lua_pushvalue(L, 1);                 //将传入的Lua函数拷贝一份压入L栈顶
  lua_xmove(L, NL, 1);                 //将L栈顶的Lua函数移除，并将它压入NL栈顶
  return 1;                            //此时L栈顶元素为新分配的NL，将它最为结果，返回结果个数1
}

//@[coroutine.resume(co [, val1, ...])]
//如果协程第一次或重新从头开始运行，协程对应的Lua函数会被调用，并将val1,...传入作为Lua函数的参数
//--如果执行过程中没有发生错误，Lua函数要么执行完要么被yield
//  如果Lua函数成功执行完，函数resume返回true以及Lua函数返回的所有返回值
//  如果Lua函数执行过程中被yield，函数resume返回true以及所有传入yield的参数
//--如果执行过程中发生错误，函数resume返回false以及一个错误消息
//如果协程处于yield状态，Lua函数会回到原来yield的代码位置，
//该处的yield函数会返回，并将参数val1,...作为它的返回结果，然后Lua函数继续执行
//--如果执行过程中没有发生错误，Lua函数要么执行完要么被yield，流程与上面一样
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

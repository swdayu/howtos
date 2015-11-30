
# C模块

在一定规则下，Lua与C可以相互调用以及传递数据。
通过Lua提供的C接口函数，在C语言中可以以字符串、文件或内存块的形式执行一段Lua代码。
而在Lua中，可以通过动态链接库的形式调用符合规则的C模块中的C函数。

## 函数上值

> When a C function is created, it is possible to associate some values with it, 
thus creating a C **closure** (see `lua_pushcclosure`); 
these values are called **upvalues** and are accessible to the function whenever it is called.

> Whenever a C function is called, its **upvalues** are located at specific **pseudo-indices**. 
These **pseudo-indices** are produced by the macro `lua_upvalueindex`. 
The first **upvalue** associated with a function is at index `lua_upvalueindex(1)`, and so on. 
Any access to `lua_upvalueindex(n)`, where `n` is greater than the number of **upvalues** of the current function 
(but not greater than 256), produces an acceptable but invalid index.

C函数可以关联一些值形成C**闭包**（见`lua_pushcclosure`）。
这些关联的值称为**上值**，在C函数内部可以自由访问这些值。
当C函数被调用时，它的**上值**都分配在一些特定的**伪索引**上。
这些**伪索引**通过一个宏`lua_upvalueindex`来产生。
例如第一个**上值**关联在索引`lua_upvalueindex(1)`位置上，依此类推。
任何大于当前函数**上值**个数的索引（不能大于256），都是一个**可接受索引**，但不是**有效索引**。

## 注册表

> Lua provides a **registry**, a predefined table that can be used by any C code 
to store whatever Lua values it needs to store. 
The registry table is always located at **pseudo-index** `LUA_REGISTRYINDEX`. 
Any C library can store data into this table, but it must take care to choose keys 
that are different from those used by other libraries, to avoid collisions. 
Typically, you should use as key a string containing your library name, 
or a **light userdata** with the address of a C object in your code, or any Lua object created by your code. 
As with variable names, string keys starting with an underscore followed by uppercase letters are reserved for Lua.

> The integer keys in the registry are used by the reference mechanism (see `luaL_ref`) and by some predefined values. 
Therefore, integer keys must not be used for other purposes.
When you create a new **Lua state**, its registry comes with some predefined values. 
These predefined values are indexed with integer keys defined as constants in lua.h. 
The following constants are defined:
- `LUA_RIDX_MAINTHREAD`: At this index the registry has the main thread of the state. 
  (The main thread is the one created together with the state.)
- `LUA_RIDX_GLOBALS`: At this index the registry has the global environment.

Lua提供了一个预定义的**注册表**，C可以用它来存储需要的Lua值。
**注册表**总是分配在**伪索引**`LUA_REGISTRYINDEX`位置上。
任何C模块都可以将数据存储到这个表中，但必须选择不同于其他模块的名称作为键，来避免冲突。
原则上，应该使用包含模块名称的字符串，或者关联了C对象地址的**轻量用户数据**，或者创建的Lua对象。
像变量名一样，以下划线开始后面跟大写字母的字符串键是Lua的保留值。

**注册表**中的整数键不能用于其他目的，仅供引用机制（见`luaL_ref`）和一些预定义值使用。
当创建一个新的**Lua状态**时，它的**注册表**就关联了一些预定义值。
这些值用定义在`"lua.h"`中的整数键进行访问：
`LUA_RIDX_MAINTHREAD`对应**Lua状态**的主线程（它是与**Lua状态**一起创建的），
`LUA_RIDX_GLOBALS`对应全局环境。

### lua_CFunction
```c
typedef int (*lua_CFunction)(lua_State* L);
```

> Type for C functions.In order to communicate properly with Lua, a C function must use the following protocol, 
which defines the way parameters and results are passed: 
a C function receives its arguments from Lua in its stack in direct order (the first argument is pushed first). 
So, when the function starts, `lua_gettop(L)` returns the number of arguments received by the function. 
The first argument (if any) is at index 1 and its last argument is at index `lua_gettop(L)`. 
To return values to Lua, a C function just pushes them onto the stack, 
in direct order (the first result is pushed first), and returns the number of results. 
Any other value in the stack below the results will be properly discarded by Lua. 
Like a Lua function, a C function called by Lua can also return many results.

`lua_CFunction`是能被Lua调用的C函数类型。
为了与Lua交互，C函数必须满足以下规则，这些规则定义了C函数的参数和返回值怎样传递。
C函数从Lua栈中依次接收函数的参数（第一个参数最先入栈）；
当函数开始执行时，`lua_gettop(L)`可以获取传入函数的参数个数；
第一个参数（如果存在）在位置1上，最后一个参数在位置`lua_gettop(L)`上；
当将结果返回给Lua时，C函数要按顺序将结果依次入栈（第一个结果先入栈），并将结果个数当作函数返回值返回；
Lua会丢弃任何在函数结果下面的值；像Lua函数一样，C函数也能返回多个结果。
例如下面的一个例子，它计算多个数值的平均值及和：
```c
static int foo (lua_State *L) {
  int n = lua_gettop(L);    /* number of arguments */
  lua_Number sum = 0.0;
  int i;
  for (i = 1; i <= n; i++) {
    if (!lua_isnumber(L, i)) {
      lua_pushliteral(L, "incorrect argument");
      lua_error(L);
    }
    sum += lua_tonumber(L, i);
  }
  lua_pushnumber(L, sum/n);   /* first result */
  lua_pushnumber(L, sum);     /* second result */
  return 2;                   /* number of results */
}
```

### lua_upvalueindex [-0, +0, –]
```c
int lua_upvalueindex(int i);
```
> Returns the pseudo-index that represents the `i`-th upvalue of the running function (see §4.4).

返回当前函数的第`i`个**上值**的**伪索引**。

### lua_pushcclosure [-n, +1, e]
```c
void lua_pushcclosure(lua_State* L, lua_CFunction fn, int n);
```
> Pushes a new C closure onto the stack. 
To associate values with a C function, first these values must be pushed onto the stack 
(when there are multiple values, the first value is pushed first). 
Then `lua_pushcclosure` is called to create and push the C function onto the stack, 
with the argument `n` telling how many values will be associated with the function. 
`lua_pushcclosure` also pops these values from the stack.

> The maximum value for `n` is 255.
When `n` is zero, this function creates a light C function, which is just a pointer to the C function. 
In that case, it never raises a memory error.

这个函数创建一个新的由C函数`fn`以及`n`个上值组成的C闭包，并将它压入到栈中。
要将值关联到C函数，首先需要将这些值压入到栈中（如果有多个，第一个应该先压入）；
然后再调用`lua_pushcclosure`来创建和压入这个闭包，在压入之前`lua_pushcclosure`会将关联值从栈中移除。

最大的上值个数是255。如果`n`是0，这个函数仅仅创建一个C函数，即一个指向C函数的指针。
在这种情况下，这个函数不会抛出内存异常。

### lua_pushcfunction [-0, +1, –]
```c
void lua_pushcfunction(lua_State* L, lua_CFunction f);
```
> Pushes a C function onto the stack. 
This function receives a pointer to a C function and pushes onto the stack a Lua value of type function that, 
when called, invokes the corresponding C function.
Any function to be callable by Lua must follow the correct protocol to receive its parameters 
and return its results (see `lua_CFunction`).

将一个C函数压入到栈中，任何可以被Lua调用的C函数都必须遵循有关函数参数和结果传递的规则（见`lua_CFunction`）。

### luaL_ref [-1, +0, e] 
```c
int luaL_ref(lua_State* L, int t); 
```
> Creates and returns a reference, in the table at index `t`, 
for the object at the top of the stack (and pops the object).
A reference is a unique integer key. 
As long as you do not manually add integer keys into table `t`, 
`luaL_ref` ensures the uniqueness of the key it returns. 
You can retrieve an object referred by reference `r` by calling `lua_rawgeti(L, t, r)`. 
Function `luaL_unref` frees a reference and its associated object.

> If the object at the top of the stack is `nil`, `luaL_ref` returns the constant `LUA_REFNIL`. 
The constant `LUA_NOREF` is guaranteed to be different from any reference returned by `luaL_ref`.

创建和返回栈顶元素的引用，这个引用和栈顶元素会保存到在索引`t`位置的表中，最后移除栈顶元素。
引用是具有唯一性的整数键，只要表中没有手动添加过整数键，`luaL_ref`就会保证键的唯一性。
调用函数`lua_rawgeti(L, t, r)`可以获取到对应引用关联的值。
而函数`luaL_unref`则用于释放对应的引用。

如果栈顶元素是`nil`，`luaL_ref`会返回一个`LUA_REFNIL`常量。
而常量`LUA_NOREF`是一个与任何`luaL_ref`返回值都不同的值。

### luaL_unref [-0, +0, –] 
```c
void luaL_unref(lua_State* L, int t, int ref); 
```
> Releases reference `ref` from the table at index `t` (see `luaL_ref`). 
The entry is removed from the table, so that the referred object can be collected. 
The reference `ref` is also freed to be used again.
If `ref` is `LUA_NOREF` or `LUA_REFNIL`, `luaL_unref` does nothing.

释放表中的引用和关联的值。释放之后，这个引用可以被重新使用，而关联的值可以被回收。
如果指定的引用是`LUA_NOREF`或者`LUA_REFNIL`，则这个函数不会做任何事情。

### luaL_Reg
```c
typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;
```
> Type for arrays of functions to be registered by `luaL_setfuncs`. 
`name` is the function name and `func` is a pointer to the function. 
Any array of `luaL_Reg` must end with a sentinel entry in which both name and func are `NULL`.

这个类型包含C函数的名称和指针，这个类型的数组用于注册C模块的一组C函数（通过调用函数`luaL_setfuncs`）。
数组必须使用一个空元素结束，其中C函数名称和指针都为`NULL`。

### luaL_newlib [-0, +1, e]
```c
void luaL_newlib(lua_State* L, const luaL_Reg l[]);
```
> Creates a new table and registers there the functions in list `l`.
It is implemented as the following macro: `(luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))`.
The array `l` must be the actual array, not a pointer to it.

创建一个注册了C函数的新表，它是通过函数`luaL_newlibtable`和`luaL_setfuncs`来实现的。
它是一个宏，指定的数组`l`必须是一个实际的数组，而不能是一个指向它的指针。

### luaL_newlibtable [-0, +1, e]
```c
void luaL_newlibtable(lua_State* L, const luaL_Reg l[]);
```
> Creates a new table with a size optimized to store all entries in the array `l` (but does not actually store them). 
It is intended to be used in conjunction with `luaL_setfuncs` (see `luaL_newlib`).
It is implemented as a macro. The array `l` must be the actual array, not a pointer to it.

创建一个对应大小的新表，并将它压入到栈中，它通常与函数`luaL_setfuncs`一起使用。
它是一个宏，指定的数组`l`必须是一个实际的数组，而不能是一个指向它的指针。

### luaL_setfuncs [-nup, +0, e]
```c
void luaL_setfuncs(lua_State* L, const luaL_Reg* l, int nup);
```
> Registers all functions in the array `l` (see `luaL_Reg`) into the table on the top of the stack 
(below optional upvalues, see next).

> When `nup` is not zero, all functions are created sharing `nup` upvalues, 
which must be previously pushed on the stack on top of the library table. 
These values are popped from the stack after the registration.

将`l`中的所有函数都注册到栈顶的表中（如果要共享上值，这个表位于压入的所有上值之下）。
如果`nup`不是0，则表示这些函数共享`nup`个上值，调用这个函数之前必须将所有上值都压入到栈中。
最后这些上值会从栈中移除。

### luaL_openlibs [-0, +0, e]
```c
void luaL_openlibs(lua_State* L);
```
> Opens all standard Lua libraries into the given state.

打开所有Lua标准的C模块，并将它们关联到指定的Lua状态中。

### luaL_requiref [-0, +1, e]
```c
void luaL_requiref(lua_State* L, const char* modname, lua_CFunction openf, int glb);
```
> If `modname` is not already present in `package.loaded`, 
calls function `openf` with string `modname` as an argument and sets the call result in `package.loaded[modname]`, 
as if that function has been called through `require`.

> If `glb` is true, also stores the module into global `modname`.
Leaves a copy of the module on the stack.

如果模块名称不在已加载的列表`package.loaded`中，则用模块名称调用函数`openf`并将结果设置到`package.loaded[modname]`。
如果参数`glb`为真，会将加载的模块保证到名为`modname`的全局变量中。最后，将加载的模块压入栈中。

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

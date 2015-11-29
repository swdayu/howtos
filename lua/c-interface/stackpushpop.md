

### lua_pop [-n, +0, –]
```c
void lua_pop (lua_State *L, int n);
```
Pops `n` elements from the stack.

将`n`个栈顶元素移除。

```c
// lua_pushboolean [-0, +1, –]
// Pushes a boolean value with value `b` onto the stack.
void lua_pushboolean (lua_State *L, int b);

// lua_pushinteger [-0, +1, –] 
// Pushes an integer with value `n` onto the stack.
void lua_pushinteger (lua_State *L, lua_Integer n); 

// lua_pushliteral [-0, +1, e]
// This macro is equivalent to `lua_pushstring`, 
// but should be used only when `s` is a literal string.
const char *lua_pushliteral (lua_State *L, const char *s);

// lua_pushnil [-0, +1, –]
// Pushes a nil value onto the stack.
void lua_pushnil(lua_State *L);

// lua_pushnumber [-0, +1, –]
// Pushes a float with value n onto the stack.
void lua_pushnumber(lua_State *L, lua_Number n);

// lua_pushvalue [-0, +1, –]
// Pushes a copy of the element at the given `index` onto the stack.
void lua_pushvalue (lua_State *L, int index);

// lua_pushglobaltable [-0, +1, –]
// Pushes the global environment onto the stack.
void lua_pushglobaltable (lua_State *L);

// lua_pushthread [-0, +1, –]
// Pushes the thread represented by `L` onto the stack. 
// Returns 1 if this thread is the main thread of its state.
int lua_pushthread (lua_State *L);

// lua_pushlightuserdata [-0, +1, –]
// Pushes a light userdata onto the stack.
void lua_pushlightuserdata (lua_State *L, void *p);
```

Userdata represent C values in Lua. A light userdata represents a pointer, a `void*`. 
It is a value (like a number): you do not create it, it has no individual metatable, 
and it is not collected (as it was never created). 
A light userdata is equal to "any" light userdata with the same C address.

用户数据在Lua中用于表示C语言值。
轻量用户数据是一个`void*`型指针，它仅仅是一个值（像数值型值那样）：
不是创建出来的Lua对象，也没有元表，并且不会被垃圾回收器回收。
轻量用户数据与任何有相同地址的轻量用户数据相等。

### lua_pushfstring [-0, +1, e]

```c
const char* lua_pushfstring (lua_State *L, const char *fmt, ...);
```

Pushes onto the stack a formatted string and returns a pointer to this string. 
It is similar to the ISO C function `sprintf`, but has some important differences:

You do not have to allocate space for the result: 
the result is a Lua string and Lua takes care of memory allocation (and deallocation, through garbage collection).
The conversion specifiers are quite restricted. There are no flags, widths, or precisions. 
The conversion specifiers can only be `%%` (inserts the character `%`), 
`%s` (inserts a zero-terminated string, with no size restrictions), 
`%f` (inserts a `lua_Number`), `%I` (inserts a `lua_Integer`), 
`%p` (inserts a pointer as a hexadecimal numeral), `%d` (inserts an `int`), 
`%c` (inserts an `int` as a one-byte character), and `%U` (inserts a `long int` as a UTF-8 byte sequence).

将格式化字符串压入栈中，并返回指向这个字符串的指针。
它类似于标准C函数`sprintf`，但有下面一些重要不同：
- 不需要为字符串结果分配空间，因为它是Lua字符串，Lua会负责内存的分配（和释放，通过垃圾回收）；
- 能使用的格式很少，没有控制标志、不能调整宽度和精度；
- 可用的格式只有：`%%`（字符`%`），`%s`（以0结尾字符串），`%f`（`lua_Number`），`%I`（`lua_Integer`），
  `%p`（用16进制打印指针值），`%d`（`int`），`%c`（保存在`int`中的单字节字符），
  `%U`（保存在`long int`中的UTF-8字符）；

### lua_pushlstring [-0, +1, e]

```c
const char *lua_pushlstring (lua_State *L, const char *s, size_t len);
```

Pushes the string pointed to by `s` with size `len` onto the stack. 
Lua makes (or reuses) an internal copy of the given string, 
so the memory at `s` can be freed or reused immediately after the function returns. 
The string can contain any binary data, including embedded zeros.

Returns a pointer to the internal copy of the string.

将`s`指向的长度为`len`的字符串压入栈中。
Lua会将字符串复制一份（或重用已有的），因此`s`指向的内存可在函数返回后释放或重用。
字符串可以包含任何二进制值，包括0。函数返回指向内部字符串的指针。

### lua_pushstring [-0, +1, e]
```c
const char *lua_pushstring (lua_State *L, const char *s);
```

Pushes the zero-terminated string pointed to by `s` onto the stack. 
Lua makes (or reuses) an internal copy of the given string, 
so the memory at s can be freed or reused immediately after the function returns.

Returns a pointer to the internal copy of the string. If `s` is NULL, pushes `nil` and returns NULL.

将`s`指向的以0结束的字符串压入栈中。
Lua会将字符串复制一份（或重用已有的），因此`s`指向的内存可在函数返回后释放或重用。

函数返回指向内部字符串的指针。如果`s`是`NULL`，会将`nil`压入栈中，并返回`NULL`。

### lua_pushvfstring [-0, +1, e]
```c
const char *lua_pushvfstring (lua_State *L, const char *fmt, va_list argp);
```

Equivalent to `lua_pushfstring`, except that it receives a `va_list` instead of a variable number of arguments.

与`lua_pushfstring`一样，只不过接收`va_list`而不是不定个数参数。

### lua_createtable [-0, +1, e]
```c
void lua_createtable (lua_State *L, int narr, int nrec);
```
Creates a new empty table and pushes it onto the stack. 
Parameter `narr` is a hint for how many elements the table will have as a sequence; 
parameter `nrec` is a hint for how many other elements the table will have. 
Lua may use these hints to preallocate memory for the new table. 
This pre-allocation is useful for performance when you know in advance how many elements the table will have. 
Otherwise you can use the function `lua_newtable`.

创建一个空表并压入栈。参数`narr`提示表有多少**序列**元素，`nrec`提示有多少其他元素。
Lua可能使用这些提示为新表预先分配空间。
空间预先分配对性能有帮助，如果你事先知道表会有多少元素。否则你可以使用函数`lua_newtable`

### lua_newtable [-0, +1, e]
```c
void lua_newtable (lua_State *L);
```
Creates a new empty table and pushes it onto the stack. 
It is equivalent to `lua_createtable(L, 0, 0)`.

创建一个空表并压入栈，相当于`lua_createtable(L, 0, 0)`。

### lua_newuserdata [-0, +1, e]
```c
void *lua_newuserdata (lua_State *L, size_t size);
```
This function allocates a new block of memory with the given size, 
pushes onto the stack a new **full userdata** with the block address, and returns this address. 
The host program can freely use this memory.

该函数分配指定大小的内存块，并将一个新的与内存地址关联的**完全用户数据**压入栈中，然后返回地址值。
宿主程序可以自由使用这块内存。

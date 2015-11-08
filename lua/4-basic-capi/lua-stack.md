
# Lua Stack

Lua uses a virtual stack to pass values to and from C. 
Each element in this stack represents a Lua value (nil, number, string, etc.).
Whenever Lua calls C, the called function gets a new stack, 
which is independent of previous stacks and of stacks of C functions that are still active. 
This stack initially contains any arguments to the C function and it is where the C function pushes its results 
to be returned to the caller (see `lua_CFunction`).

Lua使用虚拟栈与C语言交换数据。栈中的每个元素都是Lua值（如`nil`、数值、字符串、等等）。
每当Lua调用C时，被调函数都获得一个新栈，这个栈与原先的栈以及当前活跃的栈都不同。
初始情况下栈会包含任何要传递给C函数的参数，C函数也把结果存放在栈中返回给调用者（见`lua_CFunction`）。

For convenience, most query operations in the API do not follow a strict stack discipline. 
Instead, they can refer to any element in the stack by using an index: 
A positive index represents an absolute stack position (starting at 1); 
a negative index represents an offset relative to the top of the stack. 
More specifically, if the stack has n elements, then index 1 represents the first element 
(that is, the element that was pushed onto the stack first) and index n represents the last element; 
index -1 also represents the last element (that is, the element at the top) and index -n represents the first element.

为便利，大多数操作都不严格遵循栈的规则。相反，都使用索引来直接访问栈中的元素。
正索引代表栈的一个绝对位置（从1开始），负索引代表从栈顶算起的相对偏移。
更准确地，如果栈有n个元素，则索引1代表第一个元素（即最先入栈元素），索引n表示最后一个元素；
索引`-1`也表示最后一个元素（即栈顶元素），而索引`-n`表示第一个元素。

## Stack Size

When you interact with the Lua API, you are responsible for ensuring consistency. 
In particular, you are responsible for controlling stack overflow. 
You can use the function `lua_checkstack` to ensure that the stack has enough space for pushing new elements.

当与Lua API交互时，程序的一致性需要你自己保证。特别地，你有责任负责控制栈溢出。
可以使用`lua_checkstack`函数保证栈有足够的空间压入新元素。

Whenever Lua calls C, it ensures that the stack has space for at least `LUA_MINSTACK` extra slots. 
`LUA_MINSTACK` is defined as 20, so that usually you do not have to worry about stack space 
unless your code has loops pushing elements onto the stack.

不论何时Lua调用C，都会保证栈有至少`Lua_MINISTACK`个额外空间。
这个值是20，因此你通常不必担心栈的空间，除非代码中有循环将元素压入栈中。

When you call a Lua function without a fixed number of results (see `lua_call`), 
Lua ensures that the stack has enough space for all results, but it does not ensure any extra space. 
So, before pushing anything in the stack after such a call you should use `lua_checkstack`.

当调用没有固定个数结果的Lua函数时（见`lua_call`），Lua保证有足够的空间存储所有结果，但不保证还有额外空间可用。
因此，在调用这样的函数后再继续压入数据，都应先调用`lua_checkstack`。

## Valid and Acceptable Indices

Any function in the API that receives stack indices works only with **valid indices** or **acceptable indices**.
A **valid index** is an index that refers to a position that stores a modifiable Lua value. 
It comprises stack indices between 1 and the stack top (`1 ≤ abs(index) ≤ top`) plus **pseudo-indices**,
which represent some positions that are accessible to C code but that are not in the stack. 
**Pseudo-indices** are used to access the **registry** (see §4.5) and the **upvalues** of a C function (see §4.4).

任何接受栈索引的函数都只能在**有效索引**或**可接受索引**下正常工作。
**有效索引**引用的位置存储的Lua值是可修改的，它的范围从1到栈顶部（即`1 ≤ abs(index) ≤ top`）再加上**伪索引**。
**伪索引**引用的地方可以被C代码访问但这些索引位置不在栈中，它用于访问C函数的**上值**和**注册表**。

Functions that do not need a specific mutable position, 
but only a value (e.g., query functions), can be called with acceptable indices. 
An acceptable index can be any valid index, but it also can be any positive index after the stack top 
within the space allocated for the stack, that is, indices up to the stack size. 
(Note that 0 is never an acceptable index.) 
Except when noted otherwise, functions in the API work with acceptable indices.

不需要可修改索引位置只需得到值的函数（如查询函数），可以用**可接受索引**调用。
**可接受索引**可以是任何**有效索引**，还可以是栈顶之上但在栈空间之内的正索引，
即索引值可以大于栈顶但不超过栈的大小（注意0永远不是一个**可接受索引**）。
除非特别说明，API函数都接受**可接受索引**。

Acceptable indices serve to avoid extra tests against the stack top when querying the stack. 
For instance, a C function can query its third argument without the need to first check 
whether there is a third argument, that is, without the need to check whether 3 is a valid index.

For functions that can be called with acceptable indices, any non-valid index is treated as if 
it contains a value of a virtual type `LUA_TNONE`, which behaves like a `nil` value.

**可接受索引**主要为了避免在查询栈时相对栈顶做额外检查。
例如，C函数可以查询它的第3个参数而不需要知道第3个参数是否存在，即无需检查3是否是**有效索引**。
能够用**可接受索引**调用的函数，任何非**有效索引**都会被当作`LUA_TNONE`类型值，它的作用跟`nil`值类似。

## Basic Operations

### lua_absindex[-0, +0, –]
```c
int lua_absindex (lua_State *L, int idx);
```
Converts the acceptable index `idx` into an equivalent absolute index
(that is, one that does not depend on the stack top).

### lua_checkstack [-0, +0, –]
```c
int lua_checkstack (lua_State *L, int n);
```

Ensures that the stack has space for at least `n` extra slots. 
It returns false if it cannot fulfill the request, 
either because it would cause the stack to be larger than a fixed maximum size 
(typically at least several thousand elements) or because it cannot allocate memory for the extra space. 
This function never shrinks the stack; if the stack is already larger than the new size, it is left unchanged.

调用这个函数确保Lua栈有额外`n`个空间。如果请求不能满足会返回`false`，
可以因为总大小超过`LUAI_MAXSTACK`或内存分配失败。
函数永远不会缩减栈的大小；另外如果栈大小已经比请求的空间要大会什么也不做直接返回。

### lua_gettop [-0, +0, –]
```c
int lua_gettop (lua_State *L);
```
Returns the index of the top element in the stack. 
Because indices start at 1, this result is equal to the number of elements in the stack; 
in particular, 0 means an empty stack.

函数返回栈顶元素的索引值。
因此栈索引值从1开始，因此这个值即栈中元素的个数；特别的，0表示栈中没有元素。

### lua_settop [-?, +?, –]
```c
void lua_settop (lua_State *L, int index);
```
Accepts any index, or 0, and sets the stack top to this index. 
If the new top is larger than the old one, then the new elements are filled with `nil`. 
If index is 0, then all stack elements are removed.

### lua_pop [-n, +0, –]
```c
void lua_pop (lua_State *L, int n);
```
Pops `n` elements from the stack.

将`n`个栈顶元素从栈中移除。

### lua_copy [-0, +0, –]
```c
void lua_copy (lua_State *L, int fromidx, int toidx);
```
Copies the element at index `fromidx` into the valid index `toidx`, replacing the value at that position. 
Values at other positions are not affected.

将栈中`fromidx`中的元素拷贝到`toidx`指定的元素中，目的元素的值会被覆盖。
其他位置的值保持不变。

### lua_insert [-1, +1, –]
```c
void lua_insert (lua_State *L, int index);
```
Moves the top element into the given valid `index`, shifting up the elements above this index to open space. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

将栈顶元素插入到`index`对应的位置上，插入位置之上的元素都将往上移动。
不能用伪索引调用这个函数，因为伪索引不是一个真正的栈位置。

### lua_remove [-1, +0, –]
```c
void lua_remove (lua_State *L, int index);
```

Removes the element at the given valid `index`, shifting down the elements above this index to fill the gap. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

将`index`位置上的元素移除，移除位置之上的元素都将往下移填补空位。
不能用伪索引调用这个函数，因为伪索引不是一个真正的栈位置。

### lua_replace [-1, +0, –]
```c
void lua_replace (lua_State *L, int index);
```

Moves the top element into the given valid `index` without shifting any element 
(therefore replacing the value at that given index), and then pops the top element.

使用栈顶元素将位置`index`上的元素替换掉，然后将栈顶元素出栈。

### lua_rotate [-0, +0, –]
```c
void lua_rotate (lua_State *L, int idx, int n);
```

Rotates the stack elements between the valid index `idx` and the top of the stack. 
The elements are rotated `n` positions in the direction of the top, for a positive `n`, 
or `-n` positions in the direction of the bottom, for a negative `n`. 
The absolute value of `n` must not be greater than the size of the slice being rotated. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

在`idx`对应的位置和栈顶位置之间循环移动`n`个位置。如果`n`是正数则往栈顶方向移，否则往栈底方向移。
移动次数`n`的绝对值必须不能比移动的元素个数还要大。
不能用伪索引调用这个函数，因为伪索引不是一个真正的栈位置。

## Push Stack

```c
// lua_pushboolean [-0, +1, –]
// Pushes a boolean value with value `b` onto the stack.
void lua_pushboolean (lua_State *L, int b);

// lua_pushinteger [-0, +1, –] 
// Pushes an integer with value `n` onto the stack.
void lua_pushinteger (lua_State *L, lua_Integer n); 

// lua_pushliteral [-0, +1, e]
// This macro is equivalent to lua_pushstring, but should be used only when `s` is a literal string.
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

### lua_pushfstring [-0, +1, e]

```c
const char *lua_pushfstring (lua_State *L, const char *fmt, ...);
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
`%c` (inserts an int as a one-byte character), and `%U` (inserts a `long int` as a UTF-8 byte sequence).

### lua_pushlstring [-0, +1, e]

```c
const char *lua_pushlstring (lua_State *L, const char *s, size_t len);
```

Pushes the string pointed to by `s` with size `len` onto the stack. 
Lua makes (or reuses) an internal copy of the given string, 
so the memory at `s` can be freed or reused immediately after the function returns. 
The string can contain any binary data, including embedded zeros.

Returns a pointer to the internal copy of the string.

### lua_pushstring [-0, +1, e]
```c
const char *lua_pushstring (lua_State *L, const char *s);
```

Pushes the zero-terminated string pointed to by `s` onto the stack. 
Lua makes (or reuses) an internal copy of the given string, 
so the memory at s can be freed or reused immediately after the function returns.

Returns a pointer to the internal copy of the string.

If `s` is NULL, pushes `nil` and returns NULL.

### lua_pushvfstring [-0, +1, e]

```c
const char *lua_pushvfstring (lua_State *L, const char *fmt, va_list argp);
```

Equivalent to `lua_pushfstring`, except that it receives a `va_list` instead of a variable number of arguments.

## Create New Object

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

### lua_newtable [-0, +1, e]
```c
void lua_newtable (lua_State *L);
```
Creates a new empty table and pushes it onto the stack. 
It is equivalent to `lua_createtable(L, 0, 0)`.

### lua_newuserdata [-0, +1, e]
```c
void *lua_newuserdata (lua_State *L, size_t size);
```
This function allocates a new block of memory with the given size, 
pushes onto the stack a new full userdata with the block address, and returns this address. 
The host program can freely use this memory.

## Get & Set Operation

### lua_getglobal [-0, +1, e]
```c
int lua_getglobal (lua_State *L, const char *name);
```
Pushes onto the stack the value of the global name. Returns the type of that value.

### lua_setglobal [-1, +0, e]
```c
void lua_setglobal (lua_State *L, const char *name);
```
Pops a value from the stack and sets it as the new value of global name.

### lua_getfield [-0, +1, e]
```c
int lua_getfield (lua_State *L, int index, const char *k);
```
Pushes onto the stack the value `t[k]`, where `t` is the value at the given index. 
As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).
Returns the type of the pushed value.

### lua_setfield [-1, +0, e]
```c
void lua_setfield (lua_State *L, int index, const char *k);
```
Does the equivalent to `t[k] = v`, 
where `t` is the value at the given index and `v` is the value at the top of the stack.
This function pops the value from the stack. 
As in Lua, this function may trigger a metamethod for the "newindex" event (see §2.4).

### lua_geti [-0, +1, e]
```c
int lua_geti (lua_State *L, int index, lua_Integer i);
```
Pushes onto the stack the value `t[i]`, where `t` is the value at the given `index`. 
As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).

Returns the type of the pushed value.

### lua_rawgeti [-0, +1, –]
```c
int lua_rawgeti (lua_State *L, int index, lua_Integer n);
```
Pushes onto the stack the value `t[n]`, where `t` is the table at the given `index`. 
The access is raw; that is, it does not invoke metamethods.

Returns the type of the pushed value.

### lua_seti [-1, +0, e]
```c
void lua_seti (lua_State *L, int index, lua_Integer n);
```
Does the equivalent to `t[n] = v`, 
where `t` is the value at the given `index` and `v` is the value at the top of the stack.

This function pops the value from the stack. 
As in Lua, this function may trigger a metamethod for the "newindex" event (see §2.4).

### lua_rawseti [-1, +0, e]
```c
void lua_rawseti (lua_State *L, int index, lua_Integer i);
```
Does the equivalent of `t[i] = v`, where `t` is the table at the given index 
and `v` is the value at the top of the stack.

This function pops the value from the stack. The assignment is raw; that is, it does not invoke metamethods.

### lua_getmetatable [-0, +(0|1), –]
```c
int lua_getmetatable (lua_State *L, int index);
```
If the value at the given `index` has a metatable, 
the function pushes that metatable onto the stack and returns 1. 
Otherwise, the function returns 0 and pushes nothing on the stack.

### lua_setmetatable [-1, +0, –]
```c
void lua_setmetatable (lua_State *L, int index);
```
Pops a table from the stack and sets it as the new metatable for the value at the given index.

### lua_gettable [-1, +1, e]
```c
int lua_gettable (lua_State *L, int index);
```
Pushes onto the stack the value `t[k]`, 
where `t` is the value at the given `index` and `k` is the value at the top of the stack.

This function pops the key from the stack, pushing the resulting value in its place. 
As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).

Returns the type of the pushed value.

### lua_settable [-2, +0, e]
```c
void lua_settable (lua_State *L, int index);
```
Does the equivalent to `t[k] = v`, where `t` is the value at the given index, 
`v` is the value at the top of the stack, and `k` is the value just below the top.

This function pops both the key and the value from the stack. 
As in Lua, this function may trigger a metamethod for the "newindex" event (see §2.4).

### lua_rawset [-2, +0, e]
```c
void lua_rawset (lua_State *L, int index);
```
Similar to `lua_settable`, but does a raw assignment (i.e., without metamethods).

### lua_getuservalue [-0, +1, –]
```c
int lua_getuservalue (lua_State *L, int index);
```
Pushes onto the stack the Lua value associated with the userdata at the given `index`.

Returns the type of the pushed value.

### lua_setuservalue [-1, +0, –]
```c
void lua_setuservalue (lua_State *L, int index);
```
Pops a value from the stack and sets it as the new value associated to the userdata at the given index.

### lua_rawgetp [-0, +1, –]
```c
int lua_rawgetp (lua_State *L, int index, const void *p);
```
Pushes onto the stack the value `t[k]`, 
where `t` is the table at the given `index` and `k` is the pointer `p` represented as a light userdata. 
The access is raw; that is, it does not invoke metamethods.

Returns the type of the pushed value.

### lua_rawsetp [-1, +0, e]
```c
void lua_rawsetp (lua_State *L, int index, const void *p);
```
Does the equivalent of `t[p] = v`, where `t` is the table at the given index, 
`p` is encoded as a light userdata, and `v` is the value at the top of the stack.

This function pops the value from the stack. The assignment is raw; that is, it does not invoke metamethods.


## Compare and Calculate

```c
// lua_isboolean [-0, +0, –]
// Returns 1 if the value at the given index is a boolean, and 0 otherwise.
int lua_isboolean (lua_State *L, int index);

// lua_iscfunction [-0, +0, –]
// Returns 1 if the value at the given index is a C function, and 0 otherwise.
int lua_iscfunction (lua_State *L, int index);

// lua_isfunction [-0, +0, –]
// Returns 1 if the value at the given index is a function (either C or Lua), and 0 otherwise.
int lua_isfunction (lua_State *L, int index);

// lua_isinteger [-0, +0, –]
// Returns 1 if the value at the given index is an integer 
// (that is, the value is a number and is represented as an integer), and 0 otherwise.
int lua_isinteger (lua_State *L, int index);
```

### lua_arith [-(2|1), +1, e]
```c
void lua_arith (lua_State *L, int op);
```
Performs an arithmetic or bitwise operation over the two values 
(or one, in the case of negations) at the top of the stack, with the value at the top being the second operand, 
pops these values, and pushes the result of the operation. 
The function follows the semantics of the corresponding Lua operator (that is, it may call metamethods).

The value of `op` must be one of the following constants:
- LUA_OPADD: performs addition (+)
- LUA_OPSUB: performs subtraction (-)
- LUA_OPMUL: performs multiplication (*)
- LUA_OPDIV: performs float division (/)
- LUA_OPIDIV: performs floor division (//)
- LUA_OPMOD: performs modulo (%)
- LUA_OPPOW: performs exponentiation (^)
- LUA_OPUNM: performs mathematical negation (unary -)
- LUA_OPBNOT: performs bitwise negation (~)
- LUA_OPBAND: performs bitwise and (&)
- LUA_OPBOR: performs bitwise or (|)
- LUA_OPBXOR: performs bitwise exclusive or (~)
- LUA_OPSHL: performs left shift (<<)
- LUA_OPSHR: performs right shift (>>)

### lua_compare [-0, +0, e]
```c
int lua_compare (lua_State *L, int index1, int index2, int op);
```
Compares two Lua values. 
Returns 1 if the value at index `index1` satisfies `op` when compared with the value at index `index2`, 
following the semantics of the corresponding Lua operator (that is, it may call metamethods). 
Otherwise returns 0. Also returns 0 if any of the indices is not valid.

The value of op must be one of the following constants:
- LUA_OPEQ: compares for equality (==)
- LUA_OPLT: compares for less than (<)
- LUA_OPLE: compares for less or equal (<=)

### lua_rawequal [-0, +0, –]
```c
int lua_rawequal (lua_State *L, int index1, int index2);
```
Returns 1 if the two values in indices `index1` and `index2` are primitively equal 
(that is, without calling metamethods). 
Otherwise returns 0. Also returns 0 if any of the indices are not valid.

### lua_concat [-n, +1, e]
```c
void lua_concat (lua_State *L, int n);
```
Concatenates the `n` values at the top of the stack, pops them, and leaves the result at the top. 
If `n` is 1, the result is the single value on the stack (that is, the function does nothing); 
if `n` is 0, the result is the empty string. 
Concatenation is performed following the usual semantics of Lua (see §3.4.6).

### lua_len [-0, +1, e]
```c
void lua_len (lua_State *L, int index);
```
Returns the length of the value at the given index. 
It is equivalent to the `#` operator in Lua (see §3.4.7) and 
may trigger a metamethod for the "length" event (see §2.4). 
The result is pushed on the stack.

## Convertion

### lua_toboolean [-0, +0, –]
```c
int lua_toboolean (lua_State *L, int index);
```
Converts the Lua value at the given index to a C boolean value (0 or 1). 
Like all tests in Lua, `lua_toboolean` returns true for any Lua value different from `false` and `nil`; 
otherwise it returns `false`. 
(If you want to accept only actual boolean values, use lua_isboolean to test the value's type.)

### lua_tocfunction [-0, +0, –]
```c
lua_CFunction lua_tocfunction (lua_State *L, int index);
```
Converts a value at the given index to a C function. 
That value must be a C function; otherwise, returns NULL.

### lua_tointegerx [-0, +0, –]
```c
lua_Integer lua_tointegerx (lua_State *L, int index, int *isnum);
```
Converts the Lua value at the given index to the signed integral type `lua_Integer`. 
The Lua value must be an integer, or a number or string convertible to an integer (see §3.4.3); 
otherwise, `lua_tointegerx` returns 0.

If `isnum` is not NULL, its referent is assigned a boolean value that indicates whether the operation succeeded.

### lua_tointeger [-0, +0, –]
```c
lua_Integer lua_tointeger (lua_State *L, int index);
```
Equivalent to `lua_tointegerx` with isnum equal to NULL.

### lua_tolstring [-0, +0, e]
```c
const char *lua_tolstring (lua_State *L, int index, size_t *len);
```
Converts the Lua value at the given index to a C string. 
If len is not NULL, it also sets `*len` with the string length. 
The Lua value must be a string or a number; otherwise, the function returns NULL. 
If the value is a number, then `lua_tolstring` also changes the actual value in the stack to a string. 
(This change confuses `lua_next` when `lua_tolstring` is applied to keys during a table traversal.)

`lua_tolstring` returns a fully aligned pointer to a string inside the Lua state. 
This string always has a zero ('\0') after its last character (as in C), but can contain other zeros in its body.

Because Lua has garbage collection, there is no guarantee that the pointer returned by `lua_tolstring` 
will be valid after the corresponding Lua value is removed from the stack.

### lua_tostring [-0, +0, e]
```c
const char *lua_tostring (lua_State *L, int index);
```
Equivalent to `lua_tolstring` with `len` equal to NULL.

### lua_tonumberx [-0, +0, –]
```c
lua_Number lua_tonumberx (lua_State *L, int index, int *isnum);
```
Converts the Lua value at the given index to the C type `lua_Number` (see `lua_Number`). 
The Lua value must be a number or a string convertible to a number (see §3.4.3); 
otherwise, `lua_tonumberx` returns 0.

If `isnum` is not NULL, its referent is assigned a boolean value that indicates whether the operation succeeded.

### lua_tonumber [-0, +0, –]
```c
lua_Number lua_tonumber (lua_State *L, int index);
```
Equivalent to `lua_tonumberx` with isnum equal to NULL.

### lua_stringtonumber [-0, +1, –]
```c
size_t lua_stringtonumber (lua_State *L, const char *s);
```
Converts the zero-terminated string `s` to a number, pushes that number into the stack, 
and returns the total size of the string, that is, its length plus one. 
The conversion can result in an integer or a float, according to the lexical conventions of Lua (see §3.1). 
The string may have leading and trailing spaces and a sign. 
If the string is not a valid numeral, returns 0 and pushes nothing. 
(Note that the result can be used as a boolean, true if the conversion succeeds.)

### lua_topointer [-0, +0, –]
```c
const void *lua_topointer (lua_State *L, int index);
```
Converts the value at the given index to a generic C pointer (`void*`). 
The value can be a userdata, a table, a thread, or a function; otherwise, `lua_topointer` returns NULL. 
Different objects will give different pointers. There is no way to convert the pointer back to its original value.

Typically this function is used only for hashing and debug information.

### lua_tothread [-0, +0, –]
```c
lua_State *lua_tothread (lua_State *L, int index);
```
Converts the value at the given index to a Lua thread (represented as `lua_State*`). 
This value must be a thread; otherwise, the function returns NULL.

### lua_touserdata [-0, +0, –]
```c
void *lua_touserdata (lua_State *L, int index);
```
If the value at the given index is a full userdata, returns its block address. 
If the value is a light userdata, returns its pointer. Otherwise, returns NULL.


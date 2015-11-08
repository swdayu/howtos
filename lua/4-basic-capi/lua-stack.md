
# lua stack


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




## Basic Operations

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

### lua_xmove [-?, +?, –]
```c
void lua_xmove (lua_State *from, lua_State *to, int n);
```

Exchange values between different threads of the same state.
This function pops `n` values from the stack `from`, and pushes them onto the stack `to`.


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

Pushes onto the stack a formatted string and returns a pointer to this string. It is similar to the ISO C function sprintf, but has some important differences:

You do not have to allocate space for the result: the result is a Lua string and Lua takes care of memory allocation (and deallocation, through garbage collection).
The conversion specifiers are quite restricted. There are no flags, widths, or precisions. The conversion specifiers can only be '%%' (inserts the character '%'), '%s' (inserts a zero-terminated string, with no size restrictions), '%f' (inserts a lua_Number), '%I' (inserts a lua_Integer), '%p' (inserts a pointer as a hexadecimal numeral), '%d' (inserts an int), '%c' (inserts an int as a one-byte character), and '%U' (inserts a long int as a UTF-8 byte sequence).

### lua_pushlstring [-0, +1, e]

```c
const char *lua_pushlstring (lua_State *L, const char *s, size_t len);
```

Pushes the string pointed to by s with size len onto the stack. Lua makes (or reuses) an internal copy of the given string, so the memory at s can be freed or reused immediately after the function returns. The string can contain any binary data, including embedded zeros.

Returns a pointer to the internal copy of the string.

### lua_pushstring [-0, +1, e]
```c
const char *lua_pushstring (lua_State *L, const char *s);
```

Pushes the zero-terminated string pointed to by s onto the stack. Lua makes (or reuses) an internal copy of the given string, so the memory at s can be freed or reused immediately after the function returns.

Returns a pointer to the internal copy of the string.

If s is NULL, pushes nil and returns NULL.

### lua_pushvfstring [-0, +1, e]

```c
const char *lua_pushvfstring (lua_State *L, const char *fmt, va_list argp);
```

Equivalent to lua_pushfstring, except that it receives a va_list instead of a variable number of arguments.






## Get & Set Stack


### lua_getglobal [-0, +1, e] lua_setglobal [-1, +0, e]
```c
int lua_getglobal (lua_State *L, const char *name);
void lua_setglobal (lua_State *L, const char *name);
```

Pushes onto the stack the value of the global name. Returns the type of that value.
Pops a value from the stack and sets it as the new value of global name.


### lua_getfield [-0, +1, e] lua_setfield [-1, +0, e]
```c
int lua_getfield (lua_State *L, int index, const char *k);
void lua_setfield (lua_State *L, int index, const char *k);
```
Pushes onto the stack the value `t[k]`, where `t` is the value at the given index. 
As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).
Returns the type of the pushed value.

Does the equivalent to `t[k] = v`, 
where `t` is the value at the given index and `v` is the value at the top of the stack.
This function pops the value from the stack. 
As in Lua, this function may trigger a metamethod for the "newindex" event (see §2.4).

## Compare and Calculate

lua_arith

[-(2|1), +1, e]
void lua_arith (lua_State *L, int op);
Performs an arithmetic or bitwise operation over the two values (or one, in the case of negations) at the top of the stack, with the value at the top being the second operand, pops these values, and pushes the result of the operation. The function follows the semantics of the corresponding Lua operator (that is, it may call metamethods).

The value of op must be one of the following constants:

LUA_OPADD: performs addition (+)
LUA_OPSUB: performs subtraction (-)
LUA_OPMUL: performs multiplication (*)
LUA_OPDIV: performs float division (/)
LUA_OPIDIV: performs floor division (//)
LUA_OPMOD: performs modulo (%)
LUA_OPPOW: performs exponentiation (^)
LUA_OPUNM: performs mathematical negation (unary -)
LUA_OPBNOT: performs bitwise negation (~)
LUA_OPBAND: performs bitwise and (&)
LUA_OPBOR: performs bitwise or (|)
LUA_OPBXOR: performs bitwise exclusive or (~)
LUA_OPSHL: performs left shift (<<)
LUA_OPSHR: performs right shift (>>)

lua_compare

[-0, +0, e]
int lua_compare (lua_State *L, int index1, int index2, int op);
Compares two Lua values. Returns 1 if the value at index index1 satisfies op when compared with the value at index index2, following the semantics of the corresponding Lua operator (that is, it may call metamethods). Otherwise returns 0. Also returns 0 if any of the indices is not valid.

The value of op must be one of the following constants:

LUA_OPEQ: compares for equality (==)
LUA_OPLT: compares for less than (<)
LUA_OPLE: compares for less or equal (<=)
lua_concat

[-n, +1, e]
void lua_concat (lua_State *L, int n);
Concatenates the n values at the top of the stack, pops them, and leaves the result at the top. If n is 1, the result is the single value on the stack (that is, the function does nothing); if n is 0, the result is the empty string. Concatenation is performed following the usual semantics of Lua (see §3.4.6).

lua_isboolean

[-0, +0, –]
int lua_isboolean (lua_State *L, int index);
Returns 1 if the value at the given index is a boolean, and 0 otherwise.

lua_iscfunction

[-0, +0, –]
int lua_iscfunction (lua_State *L, int index);
Returns 1 if the value at the given index is a C function, and 0 otherwise.

lua_isfunction

[-0, +0, –]
int lua_isfunction (lua_State *L, int index);
Returns 1 if the value at the given index is a function (either C or Lua), and 0 otherwise.

lua_isinteger

[-0, +0, –]
int lua_isinteger (lua_State *L, int index);
Returns 1 if the value at the given index is an integer (that is, the value is a number and is represented as an integer), and 0 otherwise.




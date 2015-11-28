
## Basic

### lua_absindex[-0, +0, –]
```c
int lua_absindex (lua_State *L, int idx);
```
Converts the acceptable index `idx` into an equivalent absolute index
(that is, one that does not depend on the stack top).

将**可接受索引**转换成绝对索引（即从1开始的不依赖于栈顶的索引）。

### lua_checkstack [-0, +0, –]
```c
int lua_checkstack (lua_State *L, int n);
```

Ensures that the stack has space for at least `n` extra slots. 
It returns false if it cannot fulfill the request, 
either because it would cause the stack to be larger than a fixed maximum size 
(typically at least several thousand elements) or because it cannot allocate memory for the extra space. 
This function never shrinks the stack; if the stack is already larger than the new size, it is left unchanged.

该函数确保Lua栈至少有额外`n`个空间。
如果请求失败它会返回`false`，原因可能是总大小超过`LUAI_MAXSTACK`或内存分配失败。
函数永远不会缩减栈的大小；如果栈已经超过请求空间的大小，会什么也不做。

### lua_copy [-0, +0, –]
```c
void lua_copy (lua_State *L, int fromidx, int toidx);
```
Copies the element at index `fromidx` into the valid index `toidx`, replacing the value at that position. 
Values at other positions are not affected.

将栈中`fromidx`中的元素拷贝到`toidx`指定的元素中，目的元素值会被覆盖。
其他位置的值保持不变。

### lua_insert [-1, +1, –]
```c
void lua_insert (lua_State *L, int index);
```
Moves the top element into the given valid `index`, shifting up the elements above this index to open space. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

将栈顶元素插入到`index`对应的位置上，插入位置之上的元素都往上移。
不能用伪索引调用这个函数，因为伪索引不是真正的栈位置。

### lua_remove [-1, +0, –]
```c
void lua_remove (lua_State *L, int index);
```

Removes the element at the given valid `index`, shifting down the elements above this index to fill the gap. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

将`index`位置上的元素移除，移除位置之上的元素都往下移填补空位。
不能用伪索引调用这个函数，因为伪索引不是真正的栈位置。

### lua_replace [-1, +0, –]
```c
void lua_replace (lua_State *L, int index);
```

Moves the top element into the given valid `index` without shifting any element 
(therefore replacing the value at that given index), and then pops the top element.

用栈顶元素将位置`index`上的元素替换掉，然后将栈顶元素出栈。

### lua_rotate [-0, +0, –]
```c
void lua_rotate (lua_State *L, int idx, int n);
```

Rotates the stack elements between the valid index `idx` and the top of the stack. 
The elements are rotated `n` positions in the direction of the top, for a positive `n`, 
or `-n` positions in the direction of the bottom, for a negative `n`. 
The absolute value of `n` must not be greater than the size of the slice being rotated. 
This function cannot be called with a pseudo-index, because a pseudo-index is not an actual stack position.

该函数用于将`idx`位置与栈顶位置之间的元素整体循环移动`n`次。
如果`n`是正数则往栈顶方向移，否则往栈底方向移。
移动次数`n`的绝对值不能比移动元素的个数还要大。
不能用伪索引调用这个函数，因为伪索引不是真正的栈位置。

### lua_next [-1, +(2|0), e]
```c
int lua_next (lua_State *L, int index);
```

Pops a key from the stack, and pushes a key–value pair from the table at the given index 
(the "next" pair after the given key). 
If there are no more elements in the table, then `lua_next` returns 0 (and pushes nothing).

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

### lua_type [-0, +0, –]
```c
int lua_type (lua_State *L, int index);
```

Returns the type of the value in the given valid index, 
or `LUA_TNONE` for a non-valid (but acceptable) index. 
The types returned by `lua_type` are coded by the following constants defined in `lua.h`: 
`LUA_TNIL` (0), `LUA_TNUMBER`, `LUA_TBOOLEAN`, `LUA_TSTRING`, `LUA_TTABLE`, 
`LUA_TFUNCTION`, `LUA_TUSERDATA`, `LUA_TTHREAD`, and `LUA_TLIGHTUSERDATA`.

返回**有效索引**处的值的类型，是**可接受索引**但不是**有效索引**时会返回`LUA_TNONE`。
这个函数返回的值是定义在`lua.h`中的常量，如上。

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


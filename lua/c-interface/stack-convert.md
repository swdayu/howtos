
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


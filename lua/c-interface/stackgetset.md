
### lua_gettop [-0, +0, –]
```c
int lua_gettop (lua_State *L);
```
Returns the index of the top element in the stack. 
Because indices start at 1, this result is equal to the number of elements in the stack; 
in particular, 0 means an empty stack.

函数返回栈顶元素的索引值。栈索引值从1开始，因此这个值等于栈中元素个数；特别地，0表示栈中没有元素。

### lua_settop [-?, +?, –]
```c
void lua_settop (lua_State *L, int index);
```
Accepts any index, or 0, and sets the stack top to this index. 
If the new top is larger than the old one, then the new elements are filled with `nil`. 
If `index` is 0, then all stack elements are removed.

该函数将栈顶设置到`index`对应的位置。
如果新顶部比原位置大，新元素会用`nil`填充。
如果`index`是0，栈中所有元素都会被移除。


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

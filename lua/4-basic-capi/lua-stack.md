
# lua stack


## lua_getglobal [-0, +1, e] lua_setglobal [-1, +0, e]
```c
int lua_getglobal (lua_State *L, const char *name);
void lua_setglobal (lua_State *L, const char *name);
```

Pushes onto the stack the value of the global name. Returns the type of that value.
Pops a value from the stack and sets it as the new value of global name.


## lua_getfield [-0, +1, e] lua_setfield [-1, +0, e]
```c
int lua_getfield (lua_State *L, int index, const char *k);
void lua_setfield (lua_State *L, int index, const char *k);
```
Pushes onto the stack the value `t[k]`, where t is the value at the given index. 
As in Lua, this function may trigger a metamethod for the "index" event (see §2.4).
Returns the type of the pushed value.

Does the equivalent to `t[k] = v`, 
where `t` is the value at the given index and `v` is the value at the top of the stack.
This function pops the value from the stack. 
As in Lua, this function may trigger a metamethod for the "newindex" event (see §2.4).

## lua_next [-1, +(2|0), e]
```c
int lua_next (lua_State *L, int index);
```

Pops a key from the stack, and pushes a key–value pair from the table at the given index 
(the "next" pair after the given key). If there are no more elements in the table, 
then lua_next returns 0 (and pushes nothing).

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

See function next for the caveats of modifying the table during its traversal.


# lua_absindex

```c
int lua_absindex(lua_State* L, int idx) {
  // #define ispseudo(i) ((i) <= LUA_REGISTRYINDEX) 
  // LUA_REGISTRYINDEX => LUAI_FIRSTPSEUDOIDX => (-LUAI_MAXSTACK - 1000)
  return (idx > 0 || ispseudo(idx)) ? idx : cast_int(L->top - L->ci->func + idx);
}
```

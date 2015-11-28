
luaL_callmeta

[-0, +(0|1), e]
int luaL_callmeta (lua_State *L, int obj, const char *e);
Calls a metamethod.

If the object at index obj has a metatable and this metatable has a field e, this function calls this field passing the object as its only argument. In this case this function returns true and pushes onto the stack the value returned by the call. If there is no metatable or no metamethod, this function returns false (without pushing any value on the stack).

luaL_dofile

[-0, +?, e]
int luaL_dofile (lua_State *L, const char *filename);
Loads and runs the given file. It is defined as the following macro:

     (luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET, 0))
It returns false if there are no errors or true in case of errors.

luaL_dostring

[-0, +?, –]
int luaL_dostring (lua_State *L, const char *str);
Loads and runs the given string. It is defined as the following macro:

     (luaL_loadstring(L, str) || lua_pcall(L, 0, LUA_MULTRET, 0))
It returns false if there are no errors or true in case of errors.


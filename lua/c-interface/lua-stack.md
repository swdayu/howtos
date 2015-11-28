
luaL_checkstack

[-0, +0, v]
void luaL_checkstack (lua_State *L, int sz, const char *msg);
Grows the stack size to top + sz elements, raising an error if the stack cannot grow to that size. msg is an additional text to go into the error message (or NULL for no additional text).


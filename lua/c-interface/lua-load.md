
luaL_loadbuffer

[-0, +1, –]
int luaL_loadbuffer (lua_State *L,
                     const char *buff,
                     size_t sz,
                     const char *name);
Equivalent to luaL_loadbufferx with mode equal to NULL.

luaL_loadbufferx

[-0, +1, –]
int luaL_loadbufferx (lua_State *L,
                      const char *buff,
                      size_t sz,
                      const char *name,
                      const char *mode);
Loads a buffer as a Lua chunk. This function uses lua_load to load the chunk in the buffer pointed to by buff with size sz.

This function returns the same results as lua_load. name is the chunk name, used for debug information and error messages. The string mode works as in function lua_load.

luaL_loadfile

[-0, +1, e]
int luaL_loadfile (lua_State *L, const char *filename);
Equivalent to luaL_loadfilex with mode equal to NULL.

luaL_loadfilex

[-0, +1, e]
int luaL_loadfilex (lua_State *L, const char *filename,
                                            const char *mode);
Loads a file as a Lua chunk. This function uses lua_load to load the chunk in the file named filename. If filename is NULL, then it loads from the standard input. The first line in the file is ignored if it starts with a #.

The string mode works as in function lua_load.

This function returns the same results as lua_load, but it has an extra error code LUA_ERRFILE if it cannot open/read the file or the file has a wrong mode.

As lua_load, this function only loads the chunk; it does not run it.

luaL_loadstring

[-0, +1, –]
int luaL_loadstring (lua_State *L, const char *s);
Loads a string as a Lua chunk. This function uses lua_load to load the chunk in the zero-terminated string s.

This function returns the same results as lua_load.

Also as lua_load, this function only loads the chunk; it does not run it.



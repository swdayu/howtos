
luaL_Reg

typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;
Type for arrays of functions to be registered by luaL_setfuncs. name is the function name and func is a pointer to the function. Any array of luaL_Reg must end with a sentinel entry in which both name and func are NULL.

luaL_newlib

[-0, +1, e]
void luaL_newlib (lua_State *L, const luaL_Reg l[]);
Creates a new table and registers there the functions in list l.

It is implemented as the following macro:

     (luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))
The array l must be the actual array, not a pointer to it.

luaL_newlibtable

[-0, +1, e]
void luaL_newlibtable (lua_State *L, const luaL_Reg l[]);
Creates a new table with a size optimized to store all entries in the array l (but does not actually store them). It is intended to be used in conjunction with luaL_setfuncs (see luaL_newlib).

It is implemented as a macro. The array l must be the actual array, not a pointer to it.

luaL_requiref

[-0, +1, e]
void luaL_requiref (lua_State *L, const char *modname,
                    lua_CFunction openf, int glb);
If modname is not already present in package.loaded, calls function openf with string modname as an argument and sets the call result in package.loaded[modname], as if that function has been called through require.

If glb is true, also stores the module into global modname.

Leaves a copy of the module on the stack.

luaL_setfuncs

[-nup, +0, e]
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);
Registers all functions in the array l (see luaL_Reg) into the table on the top of the stack (below optional upvalues, see next).

When nup is not zero, all functions are created sharing nup upvalues, which must be previously pushed on the stack on top of the library table. These values are popped from the stack after the registration.

luaL_openlibs

[-0, +0, e]
void luaL_openlibs (lua_State *L);
Opens all standard Lua libraries into the given state.


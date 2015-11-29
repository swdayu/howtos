

### luaL_argcheck [-0, +0, v]
```lua
void luaL_argcheck(lua_State* L, int cond, int arg, const char* extramsg);
```
> Checks whether `cond` is true. 
If it is not, raises an error with a standard message (see `luaL_argerror`).

### luaL_argerror [-0, +0, v]
```lua
int luaL_argerror(lua_State* L, int arg, const char* extramsg);
```
> Raises an error reporting a problem with argument `arg` of the C function that called it, 
using a standard message that includes extramsg as a comment: `bad argument #arg to 'funcname' (extramsg)`.
This function never returns.

### luaL_checkany [-0, +0, v]
```lua
void luaL_checkany(lua_State* L, int arg);
-- @arg: the argument position in stack
```
> Checks whether the function has an argument of any type (including `nil`) at position `arg`.

函数在栈`arg`位置上必须有一个参数，不管它的类型是什么（包括`nil`）。

### luaL_checkinteger [-0, +0, v]
```lua
lua_Integer luaL_checkinteger(lua_State* L, int arg);
```
> Checks whether the function argument arg is an integer (or can be converted to an integer) 
and returns this integer cast to a `lua_Integer`.

### luaL_checklstring [-0, +0, v]
```lua
const char* luaL_checklstring (lua_State* L, int arg, size_t* l);
```
> Checks whether the function argument `arg` is a string and returns this string; 
if `l` is not NULL fills `*l` with the string's length.
This function uses `lua_tolstring` to get its result, so all conversions and caveats of that function apply here.

### luaL_checknumber [-0, +0, v]
```lua
lua_Number luaL_checknumber(lua_State* L, int arg);
```
> Checks whether the function argument `arg` is a number and returns this number.

### luaL_checkoption [-0, +0, v]
```lua
int luaL_checkoption(lua_State* L, int arg, const char* def, const char* const lst[]);
```
> Checks whether the function argument `arg` is a string and 
searches for this string in the array `lst` (which must be NULL-terminated). 
Returns the index in the array where the string was found. 
Raises an error if the argument is not a string or if the string cannot be found.

> If def is not NULL, the function uses `def` as a default value 
when there is no argument `arg` or when this argument is `nil`.
This is a useful function for mapping strings to C enums. 
(The usual convention in Lua libraries is to use strings instead of numbers to select options.)

### luaL_checkstring [-0, +0, v]
```lua
const char* luaL_checkstring(lua_State* L, int arg);
```
> Checks whether the function argument `arg` is a string and returns this string.
This function uses `lua_tolstring` to get its result, so all conversions and caveats of that function apply here.

### luaL_checktype [-0, +0, v]
```lua
void luaL_checktype(lua_State* L, int arg, int t);
```
> Checks whether the function argument `arg` has type `t`. 
See `lua_type` for the encoding of types for `t`.

### luaL_checkudata [-0, +0, v]
```lua
void* luaL_checkudata(lua_State* L, int arg, const char* tname);
```
> Checks whether the function argument `arg` is a userdata of the type tname (see `luaL_newmetatable`) 
and returns the userdata address (see `lua_touserdata`).

luaL_testudata

[-0, +0, e]
void *luaL_testudata (lua_State *L, int arg, const char *tname);
This function works like luaL_checkudata, except that, when the test fails, it returns NULL instead of raising an error.

----------------------------------------------------------

luaL_optinteger

[-0, +0, v]
lua_Integer luaL_optinteger (lua_State *L,
                             int arg,
                             lua_Integer d);
If the function argument arg is an integer (or convertible to an integer), returns this integer. If this argument is absent or is nil, returns d. Otherwise, raises an error.

luaL_optlstring

[-0, +0, v]
const char *luaL_optlstring (lua_State *L,
                             int arg,
                             const char *d,
                             size_t *l);
If the function argument arg is a string, returns this string. If this argument is absent or is nil, returns d. Otherwise, raises an error.

If l is not NULL, fills the position *l with the result's length.

luaL_optnumber

[-0, +0, v]
lua_Number luaL_optnumber (lua_State *L, int arg, lua_Number d);
If the function argument arg is a number, returns this number. If this argument is absent or is nil, returns d. Otherwise, raises an error.

luaL_optstring

[-0, +0, v]
const char *luaL_optstring (lua_State *L,
                            int arg,
                            const char *d);
If the function argument arg is a string, returns this string. If this argument is absent or is nil, returns d. Otherwise, raises an error.

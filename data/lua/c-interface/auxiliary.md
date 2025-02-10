
## 辅助函数


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

luaL_Buffer

typedef struct luaL_Buffer luaL_Buffer;
Type for a string buffer.

A string buffer allows C code to build Lua strings piecemeal. Its pattern of use is as follows:

First declare a variable b of type luaL_Buffer.
Then initialize it with a call luaL_buffinit(L, &b).
Then add string pieces to the buffer calling any of the luaL_add* functions.
Finish by calling luaL_pushresult(&b). This call leaves the final string on the top of the stack.
If you know beforehand the total size of the resulting string, you can use the buffer like this:

First declare a variable b of type luaL_Buffer.
Then initialize it and preallocate a space of size sz with a call luaL_buffinitsize(L, &b, sz).
Then copy the string into that space.
Finish by calling luaL_pushresultsize(&b, sz), where sz is the total size of the resulting string copied into that space.
During its normal operation, a string buffer uses a variable number of stack slots. So, while using a buffer, you cannot assume that you know where the top of the stack is. You can use the stack between successive calls to buffer operations as long as that use is balanced; that is, when you call a buffer operation, the stack is at the same level it was immediately after the previous buffer operation. (The only exception to this rule is luaL_addvalue.) After calling luaL_pushresult the stack is back to its level when the buffer was initialized, plus the final string on its top.

luaL_addchar

[-?, +?, e]
void luaL_addchar (luaL_Buffer *B, char c);
Adds the byte c to the buffer B (see luaL_Buffer).

luaL_addlstring

[-?, +?, e]
void luaL_addlstring (luaL_Buffer *B, const char *s, size_t l);
Adds the string pointed to by s with length l to the buffer B (see luaL_Buffer). The string can contain embedded zeros.

luaL_addsize

[-?, +?, e]
void luaL_addsize (luaL_Buffer *B, size_t n);
Adds to the buffer B (see luaL_Buffer) a string of length n previously copied to the buffer area (see luaL_prepbuffer).

luaL_addstring

[-?, +?, e]
void luaL_addstring (luaL_Buffer *B, const char *s);
Adds the zero-terminated string pointed to by s to the buffer B (see luaL_Buffer).

luaL_addvalue

[-1, +?, e]
void luaL_addvalue (luaL_Buffer *B);
Adds the value at the top of the stack to the buffer B (see luaL_Buffer). Pops the value.

This is the only function on string buffers that can (and must) be called with an extra element on the stack, which is the value to be added to the buffer.

luaL_buffinit

[-0, +0, –]
void luaL_buffinit (lua_State *L, luaL_Buffer *B);
Initializes a buffer B. This function does not allocate any space; the buffer must be declared as a variable (see luaL_Buffer).

luaL_buffinitsize

[-?, +?, e]
char *luaL_buffinitsize (lua_State *L, luaL_Buffer *B, size_t sz);
Equivalent to the sequence luaL_buffinit, luaL_prepbuffsize.

luaL_prepbuffer

[-?, +?, e]
char *luaL_prepbuffer (luaL_Buffer *B);
Equivalent to luaL_prepbuffsize with the predefined size LUAL_BUFFERSIZE.

luaL_prepbuffsize

[-?, +?, e]
char *luaL_prepbuffsize (luaL_Buffer *B, size_t sz);
Returns an address to a space of size sz where you can copy a string to be added to buffer B (see luaL_Buffer). After copying the string into this space you must call luaL_addsize with the size of the string to actually add it to the buffer.

luaL_pushresult

[-?, +1, e]
void luaL_pushresult (luaL_Buffer *B);
Finishes the use of buffer B leaving the final string on the top of the stack.

luaL_pushresultsize

[-?, +1, e]
void luaL_pushresultsize (luaL_Buffer *B, size_t sz);
Equivalent to the sequence luaL_addsize, luaL_pushresult.


luaL_checkversion

[-0, +0, –]
void luaL_checkversion (lua_State *L);
Checks whether the core running the call, the core that created the Lua state, and the code making the call are all using the same version of Lua. Also checks whether the core running the call and the core that created the Lua state are using the same address space.

luaL_error

[-0, +0, v]
int luaL_error (lua_State *L, const char *fmt, ...);
Raises an error. The error message format is given by fmt plus any extra arguments, following the same rules of lua_pushfstring. It also adds at the beginning of the message the file name and the line number where the error occurred, if this information is available.

This function never returns, but it is an idiom to use it in C functions as return luaL_error(args).

luaL_setmetatable

[-0, +0, –]
void luaL_setmetatable (lua_State *L, const char *tname);
Sets the metatable of the object at the top of the stack as the metatable associated with name tname in the registry (see luaL_newmetatable).

luaL_newmetatable

[-0, +1, e]
int luaL_newmetatable (lua_State *L, const char *tname);
If the registry already has the key tname, returns 0. Otherwise, creates a new table to be used as a metatable for userdata, adds to this new table the pair __name = tname, adds to the registry the pair [tname] = new table, and returns 1. (The entry __name is used by some error-reporting functions.)

In both cases pushes onto the stack the final value associated with tname in the registry.


-------------------------------------------------------
luaL_Stream

typedef struct luaL_Stream {
  FILE *f;
  lua_CFunction closef;
} luaL_Stream;
The standard representation for file handles, which is used by the standard I/O library.

A file handle is implemented as a full userdata, with a metatable called LUA_FILEHANDLE (where LUA_FILEHANDLE is a macro with the actual metatable's name). The metatable is created by the I/O library (see luaL_newmetatable).

This userdata must start with the structure luaL_Stream; it can contain other data after this initial structure. Field f points to the corresponding C stream (or it can be NULL to indicate an incompletely created handle). Field closef points to a Lua function that will be called to close the stream when the handle is closed or collected; this function receives the file handle as its sole argument and must return either true (in case of success) or nil plus an error message (in case of error). Once Lua calls this field, the field value is changed to NULL to signal that the handle is closed.

luaL_execresult

[-0, +3, e]
int luaL_execresult (lua_State *L, int stat);
This function produces the return values for process-related functions in the standard library (os.execute and io.close).

luaL_fileresult

[-0, +(1|3), e]
int luaL_fileresult (lua_State *L, int stat, const char *fname);
This function produces the return values for file-related functions in the standard library (io.open, os.rename, file:seek, etc.).


luaL_getmetafield

[-0, +(0|1), e]
int luaL_getmetafield (lua_State *L, int obj, const char *e);
Pushes onto the stack the field e from the metatable of the object at index obj and returns the type of pushed value. If the object does not have a metatable, or if the metatable does not have this field, pushes nothing and returns LUA_TNIL.

luaL_getmetatable

[-0, +1, –]
int luaL_getmetatable (lua_State *L, const char *tname);
Pushes onto the stack the metatable associated with name tname in the registry (see luaL_newmetatable) (nil if there is no metatable associated with that name). Returns the type of the pushed value.

luaL_getsubtable

[-0, +1, e]
int luaL_getsubtable (lua_State *L, int idx, const char *fname);
Ensures that the value t[fname], where t is the value at index idx, is a table, and pushes that table onto the stack. Returns true if it finds a previous table there and false if it creates a new table.

luaL_gsub

[-0, +1, e]
const char *luaL_gsub (lua_State *L,
                       const char *s,
                       const char *p,
                       const char *r);
Creates a copy of string s by replacing any occurrence of the string p with the string r. Pushes the resulting string on the stack and returns it.

luaL_len

[-0, +0, e]
lua_Integer luaL_len (lua_State *L, int index);
Returns the "length" of the value at the given index as a number; it is equivalent to the '#' operator in Lua (see §3.4.7). Raises an error if the result of the operation is not an integer. (This case only can happen through metamethods.)

luaL_tolstring

[-0, +1, e]
const char *luaL_tolstring (lua_State *L, int idx, size_t *len);
Converts any Lua value at the given index to a C string in a reasonable format. The resulting string is pushed onto the stack and also returned by the function. If len is not NULL, the function also sets *len with the string length.

If the value has a metatable with a "__tostring" field, then luaL_tolstring calls the corresponding metamethod with the value as argument, and uses the result of the call as its result.

luaL_traceback

[-0, +1, e]
void luaL_traceback (lua_State *L, lua_State *L1, const char *msg,
                     int level);
Creates and pushes a traceback of the stack L1. If msg is not NULL it is appended at the beginning of the traceback. The level parameter tells at which level to start the traceback.

luaL_typename

[-0, +0, –]
const char *luaL_typename (lua_State *L, int index);
Returns the name of the type of the value at the given index.

luaL_where

[-0, +1, e]
void luaL_where (lua_State *L, int lvl);
Pushes onto the stack a string identifying the current position of the control at level lvl in the call stack. Typically this string has the following format:

     chunkname:currentline:
Level 0 is the running function, level 1 is the function that called the running function, etc.

This function is used to build a prefix for error messages.


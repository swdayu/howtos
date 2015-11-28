
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


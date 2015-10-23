
# load(chunk[,chunkname[,mode[,env]]])
Loads a chunk. If chunk is a string, the chunk is this string.
If chunk is a function, load calls it repeatedly to get the chunk pieces until empty string, nil, or no value.
If there are no syntactic errros, returns the compiled chunk as function; otherwise, return nil plus the error message.

If the resulting function has upvalues, the first upvalue is set to the value of `env`,
if that parameter is given, or to the value of the global environment.
Other upvalues are initialized with nil. All upvalues are fresh, that is, they are not shared with any function.

The chunkname is used as the name of the chunk for error messages and debug information.
When absent, it defaults to chunk, if chunk is a string, or to "=(load)" otherwise.

The string `mode` controls whether the chunk can be text or binary (that is, a precompiled chunk).
It may be the string "b" (only binary chunks), "t" (only text chunks), or "bt" (both binary and text).
The default is "bt". Lua does not check the consistency of binary chunks.
Maliciously crafted binary chunks can crash the interpreter.


## Basic Functions

The basic library provides core functions to Lua. 
If you do not include this library in your application, 
you should check carefully whether you need to provide implementations for some of its facilities.

基本库定义了Lua核心函数。如果不包含这个库，应该考虑是否实现其中的一些功能。


_G
A global variable (not a function) that holds the global environment (see §2.2). 
Lua itself does not use this variable; changing its value does not affect any environment, nor vice versa.

_VERSION
A global variable (not a function) that holds a string containing the current interpreter version. 
The current value of this variable is "Lua 5.3".

assert 
```lua
assert(v [, message])
```

Calls error if the value of its argument `v` is false (i.e., `nil` or `false`); 
otherwise, returns all its arguments. 
In case of error, `message` is the error object; when absent, it defaults to `"assertion failed!"`.

error 
```lua
error(message [, level])
```

Terminates the last protected function called and returns `message` as the error object. 
Function `error` never returns.

Usually, error adds some information about the error position at the beginning of the `message`, 
if the `message` is a string. The `level` argument specifies how to get the error position. 
With level 1 (the default), the error position is where the error function was called. 
Level 2 points the error to where the function that called error was called; and so on. 
Passing a level 0 avoids the addition of error position information to the message.


print (···)
Receives any number of arguments and prints their values to stdout, 
using the `tostring` function to convert each argument to a string. 
`print` is not intended for formatted output, but only as a quick way to show a value, 
for instance for debugging. 
For complete control over the output, use `string.format` and `io.write`.

type (v)
Returns the type of its only argument, coded as a string. 
The possible results of this function are `"nil"` (a string, not the value `nil`), 
`"number"`, `"string"`, `"boolean"`, `"table"`, `"function"`, `"thread"`, and `"userdata"`.


collectgarbage ([opt [, arg]])

This function is a generic interface to the garbage collector. 
It performs different functions according to its first argument, `opt`:
- **"collect"**: performs a full garbage-collection cycle. This is the default option.
- **"stop"**: stops automatic execution of the garbage collector. 
    The collector will run only when explicitly invoked, until a call to restart it.
- **"restart"**: restarts automatic execution of the garbage collector.
- **"count"**: returns the total memory in use by Lua in Kbytes. 
    The value has a fractional part, so that it multiplied by 1024 
    gives the exact number of bytes in use by Lua (except for overflows).
- **"step"**: performs a garbage-collection step. 
    The step "size" is controlled by `arg`. 
    With a zero value, the collector will perform one basic (indivisible) step. 
    For non-zero values, the collector will perform as if that amount of memory (in KBytes) 
    had been allocated by Lua. 
    Returns true if the step finished a collection cycle.
- **"setpause"**: sets `arg` as the new value for the pause of the collector (see §2.5). 
    Returns the previous value for pause.
- **"setstepmul"**: sets `arg` as the new value for the step multiplier of the collector (see §2.5). 
    Returns the previous value for step.
- **"isrunning"**: returns a boolean that tells whether the collector is running (i.e., not stopped).


getmetatable (object)

If object does not have a metatable, returns `nil`. 
Otherwise, if the object's metatable has a "__metatable" field, returns the associated value. 
Otherwise, returns the metatable of the given object.


setmetatable (table, metatable)

Sets the metatable for the given table. (You cannot change the metatable of other types from Lua, only from C.) 
If metatable is `nil`, removes the metatable of the given table. 
If the original metatable has a "__metatable" field, raises an error.

This function returns table.


select (index, ···)

If `index` is a number, returns all arguments after argument number index; 
a negative number indexes from the end (-1 is the last argument). 
Otherwise, index must be the string "#", and select returns the total number of extra arguments it received.


pairs (t)

If `t` has a metamethod `__pairs`, calls it with `t` as argument and 
returns the first three results from the call.
Otherwise, returns three values: the next function, the table `t`, and `nil`, so that the construction
```lua
for k,v in pairs(t) do body end
```
will iterate over all key–value pairs of table `t`.

See function next for the caveats of modifying the table during its traversal.

ipairs (t)

Returns three values (an iterator function, the table `t`, and 0) so that the construction
```lua
for i,v in ipairs(t) do body end
```
will iterate over the key–value pairs (1,t[1]), (2,t[2]), ..., up to the first `nil` value.


rawequal (v1, v2)
Checks whether `v1` is equal to `v2`, without invoking any metamethod. Returns a `boolean`.

rawget (table, index)
Gets the real value of table[index], without invoking any metamethod. 
`table` must be a table; index may be any value.

rawlen (v)
Returns the length of the object `v`, which must be a table or a string, 
without invoking any metamethod. Returns an integer.

rawset (table, index, value)
Sets the real value of table[index] to value, without invoking any metamethod. 
`table` must be a table, index any value different from `nil` and `NaN`, and value any Lua value.
This function returns table.


tonumber (e [, base])

When called with no base, `tonumber` tries to convert its argument to a number. 
If the argument is already a number or a string convertible to a number, 
then tonumber returns this number; otherwise, it returns `nil`.

The conversion of strings can result in integers or floats, 
according to the lexical conventions of Lua (see §3.1). 
(The string may have leading and trailing spaces and a sign.)

When called with base, then `e` must be a string to be interpreted as an integer numeral in that base. 
The base may be any integer between 2 and 36, inclusive. 
In bases above 10, the letter `'A'` (in either upper or lower case) represents 10, 
`'B'` represents 11, and so forth, with `'Z'` representing 35. 
If the string e is not a valid numeral in the given base, the function returns nil.

tostring (v)
Receives a value of any type and converts it to a string in a human-readable format. 
(For complete control of how numbers are converted, use `string.format`.)

If the metatable of `v` has a "__tostring" field, 
then `tostring` calls the corresponding value with `v` as argument, 
and uses the result of the call as its result.

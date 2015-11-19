
## Basic Functions

The basic library provides core functions to Lua. 
If you do not include this library in your application, 
you should check carefully whether you need to provide implementations for some of its facilities.

基本库定义了Lua核心函数。如果不包含这个库，应该考虑是否实现其中的一些功能。


### _G
A global variable (not a function) that holds the global environment (see §2.2). 
Lua itself does not use this variable; changing its value does not affect any environment, nor vice versa.

保存全局环境的全局变量。Lua自己不会使用这个变量，改变它的值不会影响任何环境，反之亦然。

### _VERSION
A global variable (not a function) that holds a string containing the current interpreter version. 
The current value of this variable is "Lua 5.3".

保存当前Lua解释器版本字符串的全局变量。
这个变量当前的值是`"Lua 5.3"`。

### assert 
```lua
assert(v [, message])
-- call `error` if `v` is false
-- or return all its arguments
```

Calls `error` if the value of its argument `v` is false (i.e., `nil` or `false`); 
otherwise, returns all its arguments. 
In case of error, `message` is the error object; when absent, it defaults to `"assertion failed!"`.

如果参数`v`的值是`false`则调用`error`抛出异常，否则返回它的所有参数。
`message`是错误对象，它的默认值是`"assertion failed!"`。

### error 
```lua
error(message [, level])
-- terminate and deliver the error object of `message` to the last protected function
-- this function ever returns
```

Terminates the last protected function called and returns `message` as the error object. 
Function `error` never returns.

结束最近受保护的函数，让其将`message`作为错误对象返回。
而函数`error`永远不会返回。

Usually, `error` adds some information about the error position at the beginning of the `message`, 
if the `message` is a string. The `level` argument specifies how to get the error position. 
With level 1 (the default), the error position is where the `error` function was called. 
Level 2 points the error to where the function that called `error` was called; and so on. 
Passing a level 0 avoids the addition of error position information to the message.

如果`message`是字符串，`error`会在`message`开头添加一些错误位置信息。
参数`level`指定了怎么去获得这个错误位置。Level 1（默认值）错误位置是调用`error`函数的地方。
Level 2？？？。
如果`level`传入0则表示不添加额外的信息到`message`中。

### print 
```lua
print(···)
-- print all arguments to stdout
```

Receives any number of arguments and prints their values to stdout, 
using the `tostring` function to convert each argument to a string. 
`print` is not intended for formatted output, but only as a quick way to show a value, 
for instance for debugging. 
For complete control over the output, use `string.format` and `io.write`.

接收任意个数参数，调用`tostring`将每个参数都转换成字符串，再打印到标准输出。
`print`不用于格式化输出，仅提供一种方式快捷查看输出结果。
要对输出进行完全控制，使用`string.format`和`io.write`。

### type 
```lua
type(v)
-- return the type string of `v`
```

Returns the type of its only argument, coded as a string. 
The possible results of this function are `"nil"` (a string, not the value `nil`), 
`"number"`, `"string"`, `"boolean"`, `"table"`, `"function"`, `"thread"`, and `"userdata"`.

返回变量的类型字符串，可以的结果如上。

### collectgarbage 
```lua
collectgarbage([opt [, arg]])
```

这个函数是垃圾收集的通用接口，默认参数是`"collect"`，执行一次完整的垃圾收集。
更多的选项和值如下。

This function is a generic interface to the garbage collector. 
It performs different functions according to its first argument, `opt`:
- **"collect"**: performs a full garbage-collection cycle. This is the **default** option.
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

### getmetatable 
```lua
getmetatable(object)
```

If object does not have a metatable, returns `nil`. 
Otherwise, if the object's metatable has a "__metatable" field, returns the associated value. 
Otherwise, returns the metatable of the given object.

如果对象没有元表则返回`nil`，如果对象的元表有一个`__metatable`域则返回其关联的值，
否则返回给定对象的元表。

### setmetatable 
```lua
setmetatable(table, metatable)
-- set metatable for the `table` and return `table`
```

Sets the metatable for the given table. (You cannot change the metatable of other types from Lua, only from C.) 
If metatable is `nil`, removes the metatable of the given table. 
If the original metatable has a "__metatable" field, raises an error.
This function returns `table`.

设置给定表的元表（不能通过Lua改变其他类型对象的元表，只能通过C）。
如果`metatable`是`nil`，则将给定表中的元表移除。
如果原本的元表有一个`__metatable`域，则会抛出异常。
该函数返回`table`。

### select 
```lua
select(index, ···)
-- return all arugments after and including `index`
-- or if `index` is `"#"` return the number of all extra arguments

select(2, 123, 234, 345)   --> 234 345
select(-1, 123, 234, 345)  --> 345
select(-2, 123, 234, 345)  --> 234 345
select("#", 123, 234, 345) --> 3
```

If `index` is a number, returns all arguments after argument number `index`; 
a negative number indexes from the end (-1 is the last argument). 
Otherwise, index must be the string "#", 
and `select` returns the total number of extra arguments it received.

返回额外参数中`index`之后（包括`index`）的所有参数。
如果`index`是`"#"`，则返回额外参数的个数。

### next 
```lua
next(table [, index])
-- return next index of the table and its associated value

next({a = 123, b = 234, c = 345})      --> a   123
next({a = 123, b = 234, c = 345}, "a") --> b   234
next({a = 123, b = 234, c = 345}, "b") --> c   345
next({a = 123, b = 234, c = 345}, "c") --> nil
next({a = 123, b = 234, c = 345}, nil) --> a   123
next({a = 123, b = 234, c = 345}, "a") --> b   234
```

Allows a program to traverse all fields of a table. 
Its first argument is a table and its second argument is an index in this table. 
`next` returns the next index of the table and its associated value. 
When called with `nil` as its second argument, `next` returns an initial index and its associated value. 
When called with the last index, or with `nil` in an empty table, `next` returns `nil`. 
If the second argument is absent, then it is interpreted as `nil`. 
In particular, you can use `next(t)` to check whether a table is empty.

用于遍历表中的元素。第一个参数是一个表，第二个参数是表的一个索引。
`next`函数返回表的下一个索引以及它对应的值。
当用`nil`作为第二个参数调用时，`next`返回表的第一个索引及其值。
当用最后一个元素的索引值调用时，或空表最后一个元素的索引`nil`调用时，`next`会返回`nil`。
如果第二个参数没有给定，它的默认值是`nil`。
特别的，可以使用`next(t)`检查表是否是一个空表。

The order in which the indices are enumerated is not specified, even for numeric indices. 
(To traverse a table in numerical order, use a numerical `for`.)

The behavior of `next` is undefined if, during the traversal, 
you assign any value to a non-existent field in the table. 
You may however modify existing fields. 
In particular, you may clear existing fields. 

索引枚举的顺序是不确定的，对数值索引也一样（要按数值顺序遍历表，使用数值型`for`）。
如果在遍历的过程中新增加一个元素到表中，则`next`函数的行为是无定义的。
但是，你可以修改已经存在元素的值，还可以清除已存在的元素。

### pairs 
```lua
pairs(t)
```

If `t` has a metamethod `__pairs`, calls it with `t` as argument and 
returns the first three results from the call.
Otherwise, returns three values: the `next` function, the table `t`, and `nil`, so that the construction
```lua
for k,v in pairs(t) do body end
```
will iterate over all key–value pairs of table `t`.
See function `next` for the caveats of modifying the table during its traversal.

如果`t`有一个元函数`__pairs`则使用`t`调用这个函数，并返回这个函数的前3个返回值。
否则这个函数返回这3个值：`next`函数，表`t`，以及`nil`。？？？
参见函数`next`关于遍历表的过程中修改表的注意事项。

### ipairs 
```lua
ipairs(t)
```

Returns three values (an iterator function, the table `t`, and 0) so that the construction
```lua
for i,v in ipairs(t) do body end
```
will iterate over the key–value pairs (1,t[1]), (2,t[2]), ..., up to the first `nil` value.


### rawequal 
```lua
rawequal(v1, v2)
```

Checks whether `v1` is equal to `v2`, without invoking any metamethod. Returns a `boolean`.

检查变量`v1`是否与`v2`相等，不调用元函数。

### rawget 
```lua
rawget(table, index)
```

Gets the real value of `table[index]`, without invoking any metamethod. 
`table` must be a table; `index` may be any value.

获取`table[index]`的真实值，不调用任何元函数。
`table`必须是一个表，`index`可以是任何值。

### rawlen 
```lua
rawlen(v)
```

Returns the length of the object `v`, which must be a table or a string, 
without invoking any metamethod. Returns an integer.

返回对象`v`的长度，这个对象必须是表或字符串，不调用任何元函数。

### rawset 
```lua
rawset(table, index, value)
-- set the the real value of `table[index]` to `value` 
-- and return `table`
```

Sets the real value of `table[index]` to value, without invoking any metamethod. 
`table` must be a table, `index` any value different from `nil` and `NaN`, and `value` any Lua value.
This function returns `table`.

将`table[index]`的真实值赋给`value`，不调用任何元函数。
`table`必须是一个表，`index`可以是除`nil`和`NaN`之外的任何值，`value`可以是任何Lua值。
这个函数返回`table`。

### tonumber 
```lua
tonumber(e [, base])
```

When called with no base, `tonumber` tries to convert its argument to a number. 
If the argument is already a number or a string convertible to a number, 
then tonumber returns this number; otherwise, it returns `nil`.

The conversion of strings can result in integers or floats, 
according to the lexical conventions of Lua (see §3.1). 
(The string may have leading and trailing spaces and a sign.)

如果没有指定指数`base`，`tonumber`将字符串转换成数值型值（可以是整数和浮点）。
如果参数已经是一个数值或是可转换成数值的字符串，则返回这个数值；否则返回`nil`。
字符串根据Lua的词法规则（见3.1）可以转换成整型或浮点型
（字符串可以有头部和尾部空白，还可以有一个正负符号）。

When called with base, then `e` must be a string to be interpreted as an integer numeral in that base. 
The base may be any integer between 2 and 36, inclusive. 
In bases above 10, the letter `'A'` (in either upper or lower case) represents 10, 
`'B'` represents 11, and so forth, with `'Z'` representing 35. 
If the string `e` is not a valid numeral in the given base, the function returns `nil`.

如果指定了基数，`e`必须是对应基数的整数字符串。
基数可以是2到36中的一个值。
对于大于10的基数，字母`A`（不管大写还是小写）代表10，
字母`B`代表11，一次类推，直到字母`Z`代表35。
如果`e`中出现对应基数不合法的字符，函数会返回`nil`。

### tostring 
```lua
tostring(v)
```

Receives a value of any type and converts it to a string in a human-readable format. 
(For complete control of how numbers are converted, use `string.format`.)

If the metatable of `v` has a "__tostring" field, 
then `tostring` calls the corresponding value with `v` as argument, 
and uses the result of the call as its result.

将任何类型值转换成可读格式字符串（要对转换作控制，使用`string.format`）。
如果`v`的元表有`__tostring`域，则用`v`调用这个域对应的函数，并返回这个函数的值。

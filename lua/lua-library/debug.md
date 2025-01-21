
## The Debug Library

This library provides the functionality of the debug interface (§4.9) to Lua programs. 
You should exert care when using this library. 
Several of its functions violate basic assumptions about Lua code 
(e.g., that variables local to a function cannot be accessed from outside; 
that userdata metatables cannot be changed by Lua code; 
that Lua programs do not crash) and therefore can compromise otherwise secure code. 
Moreover, some functions in this library may be slow.

该库提供Lua程序的调试接口（见4.9）。使用这些库应该特别小心。
该库的一些函数违背了Lua代码的一些基本假设（例如函数内部的局部变量不能被外部访问；
例如`userdata`的元表不能被Lua代码修改；例如Lua程序不会崩溃），
因此可能损坏原本安全的代码。
而且该库中的一些函数可能执行得比较慢。

All functions in this library are provided inside the `debug` table. 
All functions that operate over a thread have an optional first argument 
which is the thread to operate over. 
The default is always the current thread. 

库的所有函数都导出在`debug`表中。
所有使用线程的函数的第一个参数都是一个可选的线程参数。
这个参数的默认值是当前线程。

### debug.debug 
```lua
debug()
```

Enters an interactive mode with the user, running each string that the user enters. 
Using simple commands and other debug facilities, the user can inspect global and local variables, 
change their values, evaluate expressions, and so on. 
A line containing only the word `cont` finishes this function, 
so that the caller continues its execution.

进入用户交互模式，执行用户输入的每个字符串。
使用简单的命令和其他调试功能，用户可以检查全局和局部变量，
修改它们的值，计算表达式结果，等等。
仅包含`cont`的行表示结束这个函数，继续调用函数的执行。

Note that commands for `debug.debug` are not lexically nested within any function 
and so have no direct access to local variables.

注意调试命令在词法上并没有嵌套在任何函数里面，因此不能直接对局部变量进行访问。

### debug.gethook 
```lua
gethook([thread])
```

Returns the current hook settings of the thread, as three values: 
the current hook function, the current hook mask, and the current hook count 
(as set by the `debug.sethook` function).

返回`thread`的当前`hook`设定，即三个值：当前`hook`函数、
当前`hook`掩码、以及当前`hook`计数。

### debug.sethook 
```lua
sethook([thread,] hook, mask [, count])
```

Sets the given function as a hook. 
The string `mask` and the number `count` describe when the hook will be called. 
The string `mask` may have any combination of the following characters, with the given meaning:
- **'c'**: the hook is called every time Lua calls a function;
- **'r'**: the hook is called every time Lua returns from a function;
- **'l'**: the hook is called every time Lua enters a new line of code.

将指定函数设置为**hook**。字符串`mask`以及`count`值用于描述**hook**函数什么时候被调用。
字符串`mask`可以使用如下字符的组合：**'c'**表示每当Lua调用一个函数调用一次**hook**函数；
**'r'**表示每当Lua从一个函数返回时调用一次**hook**函数；
**'l'**表示每当Lua执行下一行代码时调用一次**hook**函数。

Moreover, with a `count` different from zero, 
the hook is called also after every `count` instructions.
When called without arguments, `debug.sethook` turns off the hook.

另外，如果`count`不是0，每当执行完`count`个指令后**hook**函数会被调用一次。
如果不指定参数，调用`debug.sethook`会关掉**hook**机制。

When the hook is called, its first parameter is a string describing the event that has triggered its call: 
"call" (or "tail call"), "return", "line", and "count". 
For line events, the hook also gets the new line number as its second parameter. 
Inside a hook, you can call `getinfo` with level 2 to get more information about the running function 
(level 0 is the `getinfo` function, and level 1 is the `hook` function).

当**hook**函数调用时，第一个参数是描述触发这次调用事件的字符串：
如"call"（或"tail call"）、"return"、"line"、以及"count"。
对于**line**事件，还会将新一行的行号作为第二个参数传入到**hook**函数中。
在**hook**函数内部，可以用Level 2调用`getinfo`函数获取运行函数的更多信息
（Level 0表示`getinfo`函数，Level 1表示**hook**函数）。

### debug.getinfo 
```lua
getinfo([thread,] f [, what])
```

Returns a table with information about a function. 
You can give the function directly or you can give a number as the value of `f`, 
which means the function running at level `f` of the call stack of the given thread: 
level 0 is the current function (`getinfo` itself); 
level 1 is the function that called `getinfo` 
(except for tail calls, which do not count on the stack); and so on. 
If `f` is a number larger than the number of active functions, then `getinfo` returns nil.

返回包含函数相关信息的表。可以明确指定这个函数，或传入一个数值表示其在调用栈中的层次：
其中Level 0表示当前函数（`getinfo`函数本身）；
Level 1表示调用`getinfo`的函数（不能是尾调用，为调用不增加栈的层次）；依次类推。
如果传入的数值大于当前活动的函数的个数，`getinfo`会返回`nil`。

The returned table can contain all the fields returned by `lua_getinfo`, 
with the string `what` describing which fields to fill in. 
The default for `what` is to get all information available, except the table of valid lines. 
If present, the option `'f'` adds a field named `func` with the function itself. 
If present, the option `'L'` adds a field named `activelines` with the table of valid lines.

返回的表可以包含`lua_getinfo`部分介绍的所有信息，通过`what`参数指定实际需要存储的信息。
参数`what`的默认值包含了除有效代码行列表外的所有其他信息。
如果存在，选项`'f'`增加一个名为`func`的信息表示函数本身；
选项`'L'`增加一个名为`activelines`的信息表示有效代码行的列表。

For instance, the expression `debug.getinfo(1,"n").name` returns a name for the current function, 
if a reasonable name can be found, and the expression `debug.getinfo(print)` 
returns a table with all available information about the `print` function.

例如，表达式`debug.getingo(1,"n").name`返回当前函数名称；
表达式`debug.getinfo(print)`返回包含`print`函数所有可用信息的表。

### debug.getlocal 
```lua
getlocal([thread,] f, local)
-- return the name and the value of a local variable at index `local`
-- or just return the function parameter's name if `f` is a function
```

This function returns the name and the value of the local variable 
with index `local` of the function at level `f` of the stack. 
This function accesses not only explicit local variables, 
but also parameters, temporaries, etc.

该函数返回指定函数中`local`索引处的局部变量名称和值。
它不仅可以访问局部变量，而且还可以访问函数参数、以及临时变量等。

The first parameter or local variable has index 1, and so on, 
following the order that they are declared in the code, 
counting only the variables that are active in the current scope of the function. 
Negative indices refer to vararg parameters; `-1` is the first vararg parameter. 
The function returns `nil` if there is no variable with the given index, 
and raises an error when called with a level out of range. 
(You can call `debug.getinfo` to check whether the level is valid.)

根据变量在代码中的声明顺序，第一个参数或第一个局部变量在索引位置1，依此类推。
只有函数作用域中当前活动的变量才被计入到可访问的局部变量中。
负索引用于表示传入的可变参数，如`-1`表示第一个可变参数。
如果给定的索引对应的变量不存在则返回`nil`，如果给定的Level值超出范围则会抛出异常
（可以调用`debug.getinfo`检查给定的Level是否有效）。

Variable names starting with `'('` (open parenthesis) represent variables with no known names 
(internal variables such as loop control variables, 
and variables from chunks saved without debug information).

The parameter `f` may also be a function. 
In that case, `getlocal` returns only the name of function parameters.

以`(`开始的变量名称代表没有名字的变量（如循环的控制变量，Chunk中的没有保存调试信息的变量）。
参数`f`也可以是一个函数。这种情况下，`getlocal`仅仅返回函数参数的名称。

### debug.setlocal 
```lua
setlocal([thread,] level, local, value)
```

This function assigns the value `value` to the local variable 
with index `local` of the function at level `level` of the stack. 
The function returns nil if there is no local variable with the given index, 
and raises an error when called with a level out of range. 
(You can call `getinfo` to check whether the level is valid.) 
Otherwise, it returns the name of the local variable.

See `debug.getlocal` for more information about variable indices and names.

将栈对应层次上的函数对应的局部变量设置成`value`。
如果对应索引位置的局部变量不存在则会返回`nil`，如果的`level`层次超出范围则会抛出异常
（可以调用`getinfo`检查对应的`level`是否有效）。
否则，该函数返回对应局部变量的名称。更多信息参见`debug.getlocal`。

### debug.getmetatable 
```lua
getmetatable(value)
```

Returns the metatable of the given value or nil if it does not have a metatable.

### debug.setmetatable 
```lua
setmetatable(value, table)
```

Sets the metatable for the given value to the given table (which can be nil). 
Returns value.

### debug.getupvalue 
```lua
getupvalue(f, up)
```

This function returns the name and the value of the upvalue with index `up` of the function `f`. 
The function returns nil if there is no upvalue with the given index.

Variable names starting with `'('` (open parenthesis) represent variables with no known names 
(variables from chunks saved without debug information).

### debug.setupvalue 
```lua
setupvalue(f, up, value)
```

This function assigns the value value to the upvalue with index up of the function `f`. 
The function returns nil if there is no upvalue with the given index. 
Otherwise, it returns the name of the upvalue.

### debug.getuservalue 
```lua
getuservalue(u)
```

Returns the Lua value associated to `u`. If `u` is not a userdata, returns nil.

### debug.setuservalue 
```lua
setuservalue(udata, value)
```

Sets the given value as the Lua value associated to the given `udata`. 
`udata` must be a full userdata.

Returns `udata`.

### debug.getregistry 
```lua
getregistry()
```

Returns the registry table (see §4.5).

### debug.traceback 
```lua
traceback([thread,] [message [, level]])
```

If message is present but is neither a string nor nil, 
this function returns message without further processing. 
Otherwise, it returns a string with a traceback of the call stack. 
The optional message string is appended at the beginning of the traceback. 
An optional level number tells at which level to start the traceback 
(default is 1, the function calling traceback).

### debug.upvalueid 
```lua
upvalueid(f, n)
```

Returns a unique identifier (as a light userdata) for 
the upvalue numbered `n` from the given function.

These unique identifiers allow a program to check whether different closures share upvalues. 
Lua closures that share an upvalue (that is, that access a same external local variable) 
will return identical ids for those upvalue indices.

### debug.upvaluejoin 
```lua
upvaluejoin(f1, n1, f2, n2)
```

Make the `n1`-th upvalue of the Lua closure `f1` 
refer to the `n2`-th upvalue of the Lua closure `f2`. 


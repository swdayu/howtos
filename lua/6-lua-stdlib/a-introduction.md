
# 6 Standard Libraries

The standard Lua libraries provide useful functions that are implemented directly through the C API. 
Some of these functions provide essential services to the language (e.g., `type` and `getmetatable`); 
others provide access to "outside" services (e.g., I/O); and others could be implemented in Lua itself, 
but are quite useful or have critical performance requirements that deserve an implementation in C 
(e.g., `table.sort`).

标准Lua库提供了一些有用的函数，它们直接通过C API函数实现。
这些函数其中一些提供了语言核心服务（如`type`和`getmetatable`），另外一些提供了对外部服务的访问（如I/O），
还有一些本可以使用Lua来实现，但由于它们的重要性或关键性能需求使得需要用C来实现（如`table.sort`）。
所有库都通过正式C API实现，并以独立C模块形式提供。当前Lua拥有的标准库如下：

All libraries are implemented through the official C API and are provided as separate C modules. 
Currently, Lua has the following standard libraries:
- basic library (§6.1);
- coroutine library (§6.2);
- package library (§6.3);
- string manipulation (§6.4);
- basic UTF-8 support (§6.5);
- table manipulation (§6.6);
- mathematical functions (§6.7) (sin, log, etc.);
- input and output (§6.8);
- operating system facilities (§6.9);
- debug facilities (§6.10).

Except for the basic and the package libraries, 
each library provides all its functions as fields of a global table or as methods of its objects.

除了基本库和包管理库，其他库的所有函数都作为全局表的元素或对象的方法供使用。

To have access to these libraries, the C host program should call the `luaL_openlibs` function, 
which opens all standard libraries. 
Alternatively, the host program can open them individually by using `luaL_requiref` to call `luaopen_base` 
(for the basic library), `luaopen_package` (for the package library), 
`luaopen_coroutine` (for the coroutine library), `luaopen_string` (for the string library), 
`luaopen_utf8` (for the UTF8 library), `luaopen_table` (for the table library), 
`luaopen_math` (for the mathematical library), `luaopen_io` (for the I/O library), 
`luaopen_os` (for the operating system library), and `luaopen_debug` (for the debug library). 
These functions are declared in `lualib.h`.

访问这些库，C宿主程序可以调用`luaL_openlibs`访问所有库。
另一方面，可以单独的打开使用某个库，如上。这些函数定义在`lualib.h`头文件中。

## 6.1 Basic Functions

The basic library provides core functions to Lua. 
If you do not include this library in your application, 
you should check carefully whether you need to provide implementations for some of its facilities.

基本库提供了Lua的核心函数。如果不在你的应用中包含这个库，应该检查是否自行实现其中一些功能。

## 6.2 Coroutine Manipulation

This library comprises the operations to manipulate coroutines, which come inside the table `coroutine`. 
See §2.6 for a general description of coroutines.

这个库包含协程的操作，这些函数都导出在`coroutine`表中。
见2.6部分对协程的一般描述。

## 6.3 Modules

The package library provides basic facilities for loading modules in Lua. 
It exports one function directly in the global environment: `require`. 
Everything else is exported in a table `package`.

这个库提供基本功能用于在Lua中加载模块。
这个库在全局变量中导出了一个函数`require`。
其他的函数导出在`package`表中。

## 6.4 String Manipulation

This library provides generic functions for string manipulation, such as finding and extracting substrings, and pattern matching. When indexing a string in Lua, the first character is at position 1 (not at 0, as in C). Indices are allowed to be negative and are interpreted as indexing backwards, from the end of the string. Thus, the last character is at position -1, and so on.

The string library provides all its functions inside the table `string`. 
It also sets a metatable for strings where the `__index` field points to the `string` table. 
Therefore, you can use the string functions in object-oriented style. 
For instance, `string.byte(s,i)` can be written as `s:byte(i)`.

The string library assumes one-byte character encodings.

字符串库提供对字符串的一般操作，例如查找和提取子串，以及模式匹配。
当索引字符串时，第一个字符在位置1（不像C言语是0）。
索引值可以是负数，从字符串结尾开始往回计数，因此最后一个字符在位置-1，依次类推。

字符串库的函数都在`string`表中，另外字符串也设置了一个元表，元表的`__index`元素指向这个`string`表。
因此，可以用面向对象的方式使用字符串函数，例如`string.byte(s,i)`可以写成`s:byte(i)`。

字符串库假设的是单字节的字符编码。


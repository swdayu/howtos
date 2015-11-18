
# Standard Libraries
- [Package Library](./package.md)
- [String Manipulation](./string.md)
- [UTF-8 Support](./utf8.md)

The standard Lua libraries provide useful functions that are implemented directly through the C API. 
Some of these functions provide essential services to the language (e.g., `type` and `getmetatable`); 
others provide access to "outside" services (e.g., I/O); and others could be implemented in Lua itself, 
but are quite useful or have critical performance requirements that deserve an implementation in C 
(e.g., `table.sort`).

标准Lua库提供了用C API实现的一些有用的函数。
这些函数一些提供了语言核心服务（如`type`和`getmetatable`），另外一些提供对外部服务的访问（如I/O），
还有一些可以用Lua实现，但由于重要性或性能需求都用C实现（如`table.sort`）。
所有库通过正式C API实现，并以独立C模块形式提供。当前Lua拥有如下标准库：

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

除了基本库和包管理库，其他库的所有函数都作为全局表元素或对象方法供使用。

To have access to these libraries, the C host program should call the `luaL_openlibs` function, 
which opens all standard libraries. 
Alternatively, the host program can open them individually by using `luaL_requiref` to call `luaopen_base` 
(for the basic library), `luaopen_package` (for the package library), 
`luaopen_coroutine` (for the coroutine library), `luaopen_string` (for the string library), 
`luaopen_utf8` (for the UTF8 library), `luaopen_table` (for the table library), 
`luaopen_math` (for the mathematical library), `luaopen_io` (for the I/O library), 
`luaopen_os` (for the operating system library), and `luaopen_debug` (for the debug library). 
These functions are declared in `lualib.h`.

访问这些库，C宿主程序可以调用`luaL_openlibs`打开所有库的访问。
或调用上面的函数单独访问某个库。这些函数定义在`lualib.h`头文件中。

## 6.1 Basic Functions

The basic library provides core functions to Lua. 
If you do not include this library in your application, 
you should check carefully whether you need to provide implementations for some of its facilities.

基本库定义了Lua核心函数。如果不包含这个库，应该考虑是否实现其中的一些功能。

## 6.2 Coroutine Manipulation

This library comprises the operations to manipulate coroutines, which come inside the table `coroutine`. 
See §2.6 for a general description of coroutines.

协程库定义协程相关的操作，函数都导出在`coroutine`全局表中供使用。
参考2.6部分对协程的描述。

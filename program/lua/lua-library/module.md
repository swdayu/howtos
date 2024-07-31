
## Modules

The package library provides basic facilities for loading modules in Lua. 
It exports one function directly in the global environment: `require`. 
Everything else is exported in a table `package`.

这个库提供模块加载功能，其中`require`函数以全局变量形式导出，
其他函数都导出在`package`表中供使用。

### require
```lua
require(modname)
-- usage: load the given module `modname`
-- return: the loaded module or raise an error
```

Loads the given module. The function starts by looking into the `package.loaded` table 
to determine whether `modname` is already loaded. 
If it is, then `require` returns the value stored at `package.loaded[modname]`. 
Otherwise, it tries to find a loader for the module.

用于加载指定的模块。这个函数首先查找`package.loaded`看这个模块是否已经被加载了。
如果是直接返回存在其中的值，否则会查找模块的加载函数。

To find a loader, `require` is guided by the `package.searchers` sequence. 
By changing this sequence, we can change how `require` looks for a module. 
The following explanation is based on the **default** configuration for `package.searchers`.

`require`会根据`package.searches`**序列**中的查询函数去查找模块加载函数。
通过改变这个**序列**，可以控制`require`怎么去查找模块。
下面看`package.searches`默认设置下`require`如果进行查询。

First `require` queries `package.preload[modname]`. 
If it has a value, this value (which must be a function) is the loader. 
Otherwise `require` searches for a Lua loader using the path stored in `package.path`. 
If that also fails, it searches for a C loader using the path stored in `package.cpath`. 
If that also fails, it tries an all-in-one loader (see `package.searchers`).

首先`require`查询`package.preload[modname]`，如果存在则找到这个加载函数。
否则`require`使用`package.path`中的路径查找Lua加载函数。
如果失败，继续使用`package.cpath`中的路径查找C加载函数。
如果还失败，则查询给定模块的根模块中的加载函数（见`package.searchers`）。

Once a loader is found, `require` calls the loader with two arguments: 
`modname` and an extra value dependent on how it got the loader. 
(If the loader came from a file, this extra value is the file name.) 
If the loader returns any non-nil value, `require` assigns the returned value to `package.loaded[modname]`. 
If the loader does not return a non-nil value and has not assigned any value to `package.loaded[modname]`, 
then `require` assigns `true` to this entry. 
In any case, `require` returns the final value of `package.loaded[modname]`.

如果找到一个加载函数，`require`会使用`modname`以及一个额外值调用这个函数
（如果加载函数来源于一个文件，这个额外值是这个文件的名称）。
如果加载器返回非`nil`值，`require`会将这个值赋给`package.loaded[modname]`。
如果返回`nil`并且`package.loaded[modname]`没有被赋值，则`require`会将它设为`true`。
最后，`require`返回`package.loaded[modname]`的值。

If there is any error loading or running the module, or if it cannot find any loader for the module, 
then `require` raises an error. 

如果发生任何错误，包括模块加载或运行失败、或模块加载函数没有找到，`require`都会抛出一个异常。

### package.config

A string describing some compile-time configurations for packages. 
This string is a sequence of lines:
- The first line is the directory separator string. 
  Default is '\' for Windows and '/' for all other systems.
- The second line is the character that separates templates in a path. Default is ';'.
- The third line is the string that marks the substitution points in a template. Default is '?'.
- The fourth line is a string that, in a path in Windows, 
  is replaced by the executable's directory. Default is '!'.
- The fifth line is a mark to ignore all text after it 
  when building the `luaopen_` function name. Default is '-'.

这个字符串包含**包**的一些配置信息。
它由多行组成：第1行是目录分隔符（默认是`/`或`\`）；第2行是路径分隔符（默认是`;`）；
第3行是模板路径中的替换符号（默认是`?`）；第4行是要被可执行文件目录路径替换的符号（默认为`!`）；
第5行是确定模块加载函数`luaopen_<model_name>`时，模块名称哪个字符开始不是加载函数名称的一部分（默认是`-`）。

### package.path

The path used by `require` to search for a Lua loader.

At start-up, Lua initializes this variable with the value of the environment variable `LUA_PATH_5_3` 
or the environment variable `LUA_PATH` or with a default path defined in `luaconf.h`, 
if those environment variables are not defined. 
Any `;;` in the value of the environment variable is replaced by the default path.

`require`会在这个路径中查找Lua加载函数。
在启动时，Lua使用环境变量`LUA_PATH_5_3`或`LUA_PATH`初始化这个值，
如果环境变量没有定义则使用`luaconf.h`中定义的默认路径进行初始化。
环境变量中的任何`;;`都会被默认路径替换掉。

### package.cpath

The path used by `require` to search for a C loader.

Lua initializes the C path `package.cpath` in the same way it initializes the Lua path `package.path`, 
using the environment variable `LUA_CPATH_5_3` or the environment variable `LUA_CPATH` 
or a default path defined in `luaconf.h`.

`require`会在这个路径中查找C加载函数。
Lua使用与`package.path`同样的方法初始化`package.cpath`，
即使用环境变量`LUA_CPATH_5_3`、`LUA_CPATH`，或定义在`luaconf.h`中的默认路径。

### package.loaded

A table used by `require` to control which modules are already loaded. 
When you `require` a module `modname` and `package.loaded[modname]` is not false, 
`require` simply returns the value stored there.

This variable is only a reference to the real table; 
assignments to this variable do not change the table used by `require`.

这个表存储已经被加载的模块。
当`require`一个模块`modname`时，如果`package.loaded[modname]`不是`false`，
`require`会直接返回存储在其中的值。
这个值仅仅是引用，对它赋值不会改变使用在`require`中的表。

### package.loadlib
```lua
loadlib(libname, funcname)
-- usage: dynamic load a given library `libname` and export the function `funcname`
-- return: return the function found
```

Dynamically links the host program with the C library `libname`.

If `funcname` is `"*"`, then it only links with the library, 
making the symbols exported by the library available to other dynamically linked libraries. 
Otherwise, it looks for a function `funcname` inside the library and returns this function as a C function. 
So, `funcname` must follow the `lua_CFunction` prototype (see `lua_CFunction`).

动态加载函数。如果`funcname`是`"*"`，则导出这个库中的所有符号供其他动态链接库使用。
否则，会在库中查找这个函数`funcname`并返回这个函数。
这个函数必须是`lua_CFunction`类型的函数。

This is a low-level function. It completely bypasses the package and module system. 
Unlike `require`, it does not perform any path searching and does not automatically adds extensions. 
`libname` must be the complete file name of the C library, including if necessary a path and an extension. 
`funcname` must be the exact name exported by the C library (which may depend on the C compiler and linker used).

这是一个底层函数，会完全绕过Lua的包和模块系统。
不像`require`，它不会做任何路径查询，也不会自动添加文件扩展名。
因此`libname`必须是C库的完整文件名，包含必要的路径和扩展名。
`funcname`必须是这个C库中的一个确定的名字（跟使用的C编译器和链接器相关）。

This function is not supported by Standard C. 
As such, it is only available on some platforms 
(Windows, Linux, Mac OS X, Solaris, BSD, plus other Unix systems that support the `dlfcn` standard). 

这个函数不是C标准库提供的功能，仅在一些平台上才能使用
（Windows, Linux, Mac OS X, Solaris, BSD以及支持`dlfcn`标准的其他Unix系统）。

### package.preload

A table to store loaders for specific modules (see `require`).
This variable is only a reference to the real table; 
assignments to this variable do not change the table used by `require`.

这个表存储了用于加载模块的加载函数（见`require`）。
这个值仅仅是引用，对它赋值不会改变使用在`require`中的表。

### package.searchers
```lua
-- [searcher function]
-- usage: search the loader function to load the module
-- return: return a loader function and the file name the module was found (except the 1st searcher)
```

A table used by `require` to control how to load modules.
Each entry in this table is a **searcher function**. 
When looking for a module, `require` calls each of these searchers in ascending order, 
with the module name (the argument given to `require`) as its sole parameter. 
The function can return another function (the module loader) plus an extra value 
that will be passed to that loader, 
or a string explaining why it did not find that module (or `nil` if it has nothing to say).

这个表使用在`require`中，用来控制怎样加载模块。
其中的每个元素都是一个查询函数。当查找模块时，`require`用模块名称依次调用这些函数。
这些函数会返回用于加载对应模块的加载函数以及要传给这个加载函数的一个额外值，
如果查找失败会返回一个字符串表明失败的原因（也可以返回`nil`）。

Lua用4个查询函数初始化这个表：

Lua initializes this table with four searcher functions.

- The first searcher simply looks for a loader in the `package.preload` table.
    
    第1个查询函数用于在`package.preload`中查找加载函数。

- The second searcher looks for a loader as a Lua library, using the path stored at `package.path`. 
  The search is done as described in function `package.searchpath`.

    第2个查询函数用于在Lua路径中（`package.path`）查找加载函数。见函数`package.searchpatch`。

- The third searcher looks for a loader as a C library, using the path given by the variable `package.cpath`. 
  Again, the search is done as described in function `package.searchpath`. 
  For instance, if the C path is the string `./?.so;./?.dll;/usr/local/?/init.so`.
  the searcher for module `foo` will try to open the files `./foo.so`, `./foo.dll`, 
  and `/usr/local/foo/init.so`, in that order. 
  Once it finds a C library, this searcher first uses a dynamic link facility 
  to link the application with the library. 
  Then it tries to find a C function inside the library to be used as the loader. 
  The name of this C function is the string `luaopen_` concatenated with a copy of the module name 
  where each dot is replaced by an underscore. 
  Moreover, if the module name has a hyphen, its suffix after (and including) the first hyphen is removed. 
  For instance, if the module name is `a.b.c-v2.1`, the function name will be `luaopen_a_b_c`.

    第3个查询函数用于在C路径中（`package.cpath`）查找加载函数。见函数`package.searchpath`。
    例如C路径是`./?.so;./?.dll;/usr/local/?/init.so`，
    对模块`foo`会依次尝试打开文件`./foo.so`、`./foo.dll`和`/usr/local/foo/init.so`。
    如果找到了一个C动态库，首先会用动态链接功能对应用进行链接，然后在库中寻找加载函数作为模块的加载器。
    这个函数的名称是`luaopen_`加上模块的名称，其中的点号都用下划线替换。
    另外，如果有横杠符会将该符号以及之后的字符忽略。
    例如模块名称是`a.b.c-v2.1`，则加载函数是`luaopen_a_b_c`。

- The fourth searcher tries an all-in-one loader. 
  It searches the C path for a library for the root name of the given module. 
  For instance, when requiring `a.b.c`, it will search for a C library for `a`. 
  If found, it looks into it for an open function for the submodule; 
  in our example, that would be `luaopen_a_b_c`. 
  With this facility, a package can pack several C submodules into one single library, 
  with each submodule keeping its original open function.

    第4个查询函数用于在C路径中查找指定模块的根模块。
    例如查找的模块是`a.b.c`则会查找根模块`a`。
    如果找到，则在这个根模块中查找子模块的加载函数，如这个例子中的`luaopen_a_b_c`。
    利用这个功能，几个C子模块可以合并到一个库中，而且每个子模块的加载函数名词会保持不变。

All searchers except the first one (`preload`) return as the extra value the file name 
where the module was found, as returned by `package.searchpath`. 
The first searcher returns no extra value.

除第1个查询函数（不会返回一个额外值）外，其他查询函数都会将模块所在的文件名称作为额外参数返回
（来源于`package.searchpath`的调用结果）。

### package.searchpath
```lua
searchpath(name, path [, sep [, rep]])
-- usage: search `name` in `path`
-- return: the first file name searched or nil plus error message
```

Searches for the given name in the given path.
A `path` is a string containing a sequence of templates separated by semicolons. 
For each template, the function replaces each interrogation mark (if any) in the template with 
a copy of `name` wherein all occurrences of `sep` (a dot, by default) were replaced by `rep` 
(the system's directory separator, by default), and then tries to open the resulting file name.

在指定路径中查找指定名称。路径是以分号分隔的多个模板组成的字符串。
对每一个模板，该函数先用要查找的名称替换模板中的问号，
如果名称中有`sep`字符（默认是点号）则用`rep`字符替换（默认是目录分割符），
然后尝试打开替换后的文件名。

For instance, if the path is the string `./?.lua;./?.lc;/usr/local/?/init.lua`
the search for the name `foo.a` will try to open the files `./foo/a.lua`, `./foo/a.lc`, 
and `/usr/local/foo/a/init.lua`, in that order.

例如路径是字符串`./?.lua;./?.lc;/usr/local/?/init.lua`，要查找名称`foo.a`，
则该函数会依次尝试打开以下3个文件：`./foo/a.lua`、`./foo/a.lc`以及`/usr/local/foo/a/init.lua`。

Returns the resulting name of the first file that it can open in read mode (after closing the file), 
or `nil` plus an error message if none succeeds. 
(This error message lists all file names it tried to open.)

返回第一个能用读模式打开的文件名，如果都没有成功则返回`nil`以及一个错误消息
（这个错误消息会列出所有尝试过的文件名）。

### luaL_requiref
```c
void luaL_requiref(lua_State* L, const char* modname, lua_CFunction openf, int glb);
```

If `modname` is not already present in `package.loaded`,
calls function `openf` with string `modname` as an argument
and sets the call result in `package.loaded[modname]`, 
as if that function has been called through `require`.

If `glb` is true, also stores the module into global `modname`.
Leaves a copy of the module on the stack.

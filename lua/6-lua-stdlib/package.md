
## 6.3 Modules

The package library provides basic facilities for loading modules in Lua. 
It exports one function directly in the global environment: `require`. 
Everything else is exported in a table `package`.

这个库提供模块加载功能，其中一个函数`require`以全局变量形式导出，
其他函数都导出在`package`表中供使用。

### require(modname)

Loads the given module. The function starts by looking into the `package.loaded` table 
to determine whether modname is already loaded. 
If it is, then `require` returns the value stored at `package.loaded[modname]`. 
Otherwise, it tries to find a loader for the module.

To find a loader, `require` is guided by the `package.searchers` sequence. 
By changing this sequence, we can change how `require` looks for a module. 
The following explanation is based on the **default** configuration for `package.searchers`.

First `require` queries `package.preload[modname]`. 
If it has a value, this value (which must be a function) is **the loader**. 
Otherwise `require` searches for a **Lua loader** using the path stored in `package.path`. 
If that also fails, it searches for a **C loader** using the path stored in `package.cpath`. 
If that also fails, it tries an **all-in-one loader** (see `package.searchers`).

Once a loader is found, `require` calls the loader with two arguments: 
`modname` and an extra value dependent on how it got the loader. 
(If the loader came from a file, this extra value is the file name.) 
If the loader returns any non-nil value, `require` assigns the returned value to `package.loaded[modname]`. 
If the loader does not return a non-nil value and has not assigned any value to `package.loaded[modname]`, 
then `require` assigns `true` to this entry. 
In any case, require returns the final value of `package.loaded[modname]`.

If there is any error loading or running the module, or if it cannot find any loader for the module, 
then `require` raises an error. 


### package.config

A string describing some compile-time configurations for packages. This string is a sequence of lines:
- The first line is the directory separator string. Default is '\' for Windows and '/' for all other systems.
- The second line is the character that separates templates in a path. Default is ';'.
- The third line is the string that marks the substitution points in a template. Default is '?'.
- The fourth line is a string that, in a path in Windows, is replaced by the executable's directory. Default is '!'.
- The fifth line is a mark to ignore all text after it when building the `luaopen_` function name. Default is '-'.


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

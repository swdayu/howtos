## Introduction
- http://www.lua.org/manual/5.3/manual.html
- http://www.lua.org/cgi-bin/demo

Lua is an extension programming language designed to support 
general procedural programming with data description facilities. 
Lua also offers good support for object-oriented programming, functional programming, and data-driven programming. 
Lua is intended to be used as a powerful, lightweight, embeddable scripting language for any program that needs one.
Lua is implemented as a library, written in clean C, the common subset of Standard C and C++. 

As an extension language, Lua has no notion of a "main" program: 
it only works embedded in a host client, called the embedding program or simply the host. 
The host program can invoke functions to execute a piece of Lua code, 
can write and read Lua variables, and can register C functions to be called by Lua code. 
Through the use of C functions, Lua can be augmented to cope with a wide range of different domains, 
thus creating customized programming languages sharing a syntactical framework. 
The Lua distribution includes a sample host program called lua, which uses the Lua library to offer a complete, 
standalone Lua interpreter, for interactive or batch use.

Lua is free software, and is provided as usual with no guarantees, as stated in its license. 
The implementation described in this manual is available at Lua's official web site, [www.lua.org](www.lua.org).
Like any other reference manual, this document is dry in places. 
For a discussion of the decisions behind the design of Lua, see the technical papers available at Lua's web site. 
For a detailed introduction to programming in Lua, see Roberto's book, Programming in Lua. 

>Lua是一种扩展性的拥有数据描述功能的通用过程式编程语言。
它对面向对象编程、函数式编程、数据驱动式编程也有很好的支持。
Lua通常作为强大、轻量、可嵌入的脚本语言用在其他程序中。
Lua是用clean C（标准C和C++的通用子集）实现的程序库。

>作为一种扩展语言，Lua没有main程序概念：它仅在宿主程序中工作。
宿主程序可以调用函数执行Lua代码、读写Lua变量、也可以注册C函数在Lua中调用。
通过使用C函数，Lua可以共享相同的语法框架来定制编程语言，扩展其应用到不同领域中。
Lua发布版中包含了一个叫lua的宿主程序，它使用Lua库实现了一个完整的Lua解释器，可用于交互式应用或批处理。

>Lua是免费软件，如使用许可陈述，其对使用过程不提供任何担保。
这份手册中描述的实现也可以在Lua官方网站（[www.lua.org](www.lua.org)）上找到。
像其他参考手册一样，这份文档是枯燥的。关于Lua背后为什么这样设计的讨论，可以查看Lua官方网站上的技术论文。
关于Lua编程的详细介绍，可以参考Reberto的书《Programming in Lua》。

## Install
```
$ curl -R -O http://www.lua.org/ftp/lua-5.3.2.tar.gz
$ tar zxf lua-5.3.2.tar.gz
$ cd lua-5.3.2
$ make linux test # make macosx test
$ sudo make install

# if fatal error: readline/readline.h: No such file or directory
# install this library first
$ sudo apt-get install libreadline-dev 
```

## Quick reference

### Lua primary type
- nil (the variable has no value)
- boolean (only nil and false are false)
- number (including integer and float, 64-bit default)
- string (immutable byte sequence)
- function
- userdata (including full userdata and light userdata)
- thread (coroutine)
- table
```lua
type(v) -- "nil", "boolean", "thread" ...
```

### Value and reference
- nil, boolean, number, string, light userdata are value types
- function, full userdata, thread, table are reference types
- variables of reference type don't actually contain their values, just reference to them
- value types comparation will compare their real values
- reference types comparation just compare the reference, so only equaled when pointer to the same object
- but reference types can define meta-method to change the comparation behaivor

### Lua function
- Lua can call functions written in Lua and in C, they are both represented by the type function
- Function can access external local variables outside function, these kind of variables are called upvalues

### Lua userdata
- Full userdata is a block of memory managed by lua, light userdata is simply a C pointer value
- Userdata cannot be created or modified in Lua, only through the C API

### Lua table
- The table can be indexed with any Lua value except nil and NaN
- Tables can contain values of all Lua types except nil
```lua
t.name --> syntactic sugar for t["name"]
```

### Lua variables
- Kinds of variables: global variables, local variables, and table fields
- Variable is assumed to be global unless explicitly declared as a local
- Global variable 'x' is equivalent to '_ENV.x', '_ENV' is the upvalue of current chunk
- Every chunk is compiled in the scope of an external local variable named _ENV
- Lua keeps a distinguished environment called the global environment '_G' (LUA_RIDX_GLOBALS)

### Lua expressions
```lua
and or not  --> logical and, or, not
&  |  ~     --> bitwise and, or, not
==  ~=      --> equality, inequality
```

### Lua statements
```lua
{ <stat>... }                 --> block is a list of statements
;                             --> empty statement
;(print or io.write)('done')  --> add ';' before '(' to avoid ambiguity
do <block> end                --> do end
<chunk>                       --> a compilation unit of Lua, represented as an anonymous function
::Lable::
goto Lable
break
return <explist>
local <namelist>
local <namelist> = <explist>
while <exp> do <block> end
repeat <block> until <exp>
if <exp> then <block> end
if <exp> then <block> else <block> end
if <exp> then <block> elseif <exp> then <block> end
for v = <exp>, <exp> do <block> end         --> for (val=i; i<=j; i+=1) {}
for v = <exp>, <exp>, <exp> do <block> end  --> for (val=i; i<=j; i+=k) {} or for (val=i; i>=j; i-=k) {}
for <varlist> in <explist> do <block> end   --> func, state, val = explist; only evaluated once
```

### Lua assignment
- Lua allows multiple assignments, "varlist = explist"
- First, the list of values is adjusted to the length of the varialbes
- Extra values are thrown away, or nil values are appended to the tail
- If the explist ends with a function call, all values are counted (except the call is enclosed in parentheses)

### Extra examples
```lua
-- dumb varaible `_`
function foo()
  return 1, 2, 3, 4, 5, 6, 7
end
v1, _, v3, _, v5, _, v7 = foo()
print(v1, _, v3, _, v5, _, v7)   --> 1  2  3  2  5  2  7

function bar(a1, _, a3, _, a5, _, a7)
  print(a1, _, a3, _, a5, _, a7)
end
bar(1, 2, 3, 4, 5, 6, 7)         --> 1  6  3  6  5  6  7
```

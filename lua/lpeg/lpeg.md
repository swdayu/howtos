
# LPeg
- http://www.inf.puc-rio.br/~roberto/lpeg/
- http://www.inf.puc-rio.br/~roberto/docs/peg.pdf
- http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
- http://bford.info/packrat/
- http://lua-users.org/wiki/LpegTutorial

LPeg是一种新的Lua模式匹配库，它基于PEG（Parsing Expression Grammars）语法实现。

## 函数

**lpeg.match**
```lua
lpeg.match(pattern, subject[, init])
```
查找字符串`subject`中满足模式`pattern`的子串。
如果匹配成功则返回子串后一个字符的索引，或所有捕获的值（如果pattern包含了捕获的语法）。

该函数有一个可选的参数`init`，用于指定字符串`subject`的启始查找索引，如果传入一个负数表示从后往前算的一个值。
注意这个函数只会去匹配从`subject`字符串init索引位置开始的字符串，不会去匹配从任何位置开始的字符串。
如果要匹配从任何位置开始的字符串，可以写一个循环或使用匹配任何位置的模式`pattern`。

**lpeg.type**
```lua
lpeg.type(value)
```
如果传入的是一个模式（pattern），则会返回字符串"pattern"，否则返回nil。

**lpeg.version**
```lua
lpeg.version()
```
返回当前运行的LPeg的版本字符串。

**lpeg.setmaxstack**
```lua
lpeg.setmaxstack(max)
```
设置LPeg使用的栈大小（默认值是400）。
一般不用调整这个值，除非要使用递归语法进行深层递归，否则应该去优化模式（pattern）的写法。

## 模式构造

**lpeg.P**
```lua
lpeg.P(value)
```



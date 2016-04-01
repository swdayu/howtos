
# LPeg
- http://www.inf.puc-rio.br/~roberto/lpeg/
- http://www.inf.puc-rio.br/~roberto/docs/peg.pdf
- http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
- http://bford.info/packrat/
- http://lua-users.org/wiki/LpegTutorial

LPeg是一种新的Lua模式匹配库，它基于PEG（Parsing Expression Grammars）语法实现。
LPeg中的模式（pattern）是普通的Lua值（使用userdata表示），并且通过元表为模式定义了一些特定的操作。

## 函数

**lpeg.match**
```lua
lpeg.match(pattern, subject[, init])
```
查找输入串`subject`中满足模式`pattern`的子串。
如果匹配成功则返回子串后一个字符的索引，或所有captur的值（如果pattern包含了captur的语法）。

该函数有一个可选的参数`init`，用于指定输入串`subject`的查找起始索引，如果传入一个负数表示从后往前算的一个值。
注意这个函数只会去匹配输入串`subject`init索引位置开始的子串，不会匹配从任何位置开始的子串。
如果要匹配从任何位置开始的子串，可以写一个循环或匹配任何位置的模式`pattern`。

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
将传入的值转成对应的pattern：
- 如果值本身就是pattern，直接返回这个pattern
- 如果值是字符串，则返回匹配这个字符串的pattern
- 如果值是非负数n，则返回匹配n个字符串的pattern
- 如果值是负数-n，则返回的pattern在输入串只剩不到n个字符时才匹配成功；lpeg.P(-n)相当于-lpeg.P(n)，见一元减操作符部分
- 如果值是布尔值，则返回的pattern总匹配成功或失败（根据布尔实际值），它不消耗输入字符串中的字符
- 如果值是一个表，它被当作语法进行解析，见Grammars部分
- 如果值是一个函数，`returns a pattern equivalent to a match-time capture over the empty string`

```lua
lpeg.B(patt)
```
返回的pattern只在输入串当前位置之前的字符匹配patt时才表示匹配。
模式patt必须只匹配固定长度的字符串，且不能包含capture。
像predicate一样，返回的pattern不管匹配成功或失败都不会消耗输入字符串中的字符。

```lua
lpeg.R({range})
```
返回pattern匹配给定范围内的单个字符。
每个范围是一个长度为2的字符串，例如"xy"表示的范围包含两个字符x和y。
例如lpeg.R("09")匹配数字，lpeg.R("az", "AZ")匹配字母。

```lua
lpeg.S(string)
```
返回pattern匹配给定集合中的单个字符。例如lpeg.S("+-*/")匹配算术运算符。
注意如果传入的字符串只包含一个字符，则如lpeg.P("a")等价于lpeg.S("a")也等价于lpeg.R("aa")，
另外lpeg.S("")和lpeg.R()返回的pattern总匹配失败。

```lua
lpeg.V(v)
```
这个函数创建语法的非终结符（或变量），`The created non-terminal refers to the rule indexed by v in the enclosing grammar`。
见Grammars部分。

```lua
lpeg.locale([table])
```

Returns a table with patterns for matching some character classes according to the current locale. The table has fields named alnum, alpha, cntrl, digit, graph, lower, print, punct, space, upper, and xdigit, each one containing a correspondent pattern. Each pattern matches any single character that belongs to its class.

If called with an argument table, then it creates those fields inside the given table and returns that table.

**#patt**
返回的pattern只有输入字符串匹配patt时才匹配，但不管成功或失败都不消耗输入字符串中的字符。
这个pattern是一种and predicate，与原PEG中的&patt等价。这种pattern不产生任何capture。

**-patt**
返回的pattern只有输入串不匹配patt的时候才匹配，不管成功或失败它都不会消耗
输入串中的字符（这个pattern与原PEG中的!patt等价）。
例如-lpeg.P(1)只匹配字符串的末尾。这种pattern不产生任何capture，
因为patt会匹配失败或-patt会匹配失败（匹配失败的pattern不产生capture）。

**patt1+patt2**
返回的pattern匹配patt1或者patt2（与原PEG中的patt1/patt2等价，注意不要与LPeg中的/操作混淆），匹配不会回溯。
如果patt1和patt2都匹配字符集合，则这个操作等价于匹配这两个字符集合的并集。例如：
```lua
lower = lpeg.R("az")
upper = lpeg.R("AZ")
letter = lower + upper
```

**patt1-patt2**
返回的pattern等价于PEG中的!patt2 patt1，它表示匹配patt2失败，但匹配patt1成功。
如果匹配成功，该pattern会产生源于patt1的所有capture。
它不会产生源于patt2的任何capture（因为patt2会匹配失败或patt1-patt2会匹配失败）。
如果patt1和patt2都匹配字符集合，则这个操作等价于匹配这两个字符集合的差
（匹配的字符集合是将patt1字符集合中属于patt2字符集合的字符都去掉后的字符集合）。
注意-patt等价于""-patt（或0-patt），如果patt是字符集合，则1-patt是它的补集。

**patt1*patt2**
返回的pattern只有在匹配patt1成功后接着匹配patt2成功才匹配成功。

**patt^n**
如果n是非负数，这个pattern等价于PEG中的pattn patt*，它表示匹配n次或更多次patt。
如果n是负数，则这个pattern等价于PEG中的(patt?)-n，它表示匹配最多|n|次patt。
特别地patt^0等价与PEG中的patt*，patt^1等价于PEG中的patt+，而patt^-1则等价于PEG中的patt?。
这个匹配使用无回溯贪婪匹配方式进行匹配（也称为possessive repetition），即它只匹配patt的最长匹配序列。

**Grammars**
使用Lua变量可以增量式的定义pattern，新的pattern可以使用原来已经定义的pattern。
然而使用这种方式不能定义递归pattern，此时我们需要用到grammer
LPeg使用table表示grammer，table中的每一个entry表示一条规则。

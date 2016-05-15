
# LPeg
- http://www.inf.puc-rio.br/~roberto/lpeg/
- http://www.inf.puc-rio.br/~roberto/docs/peg.pdf
- http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
- http://bford.info/packrat/
- http://lua-users.org/wiki/LpegTutorial

LPeg是一种新的Lua模式匹配库，它基于PEG（Parsing Expression Grammars）语法实现。
LPeg中的模式（pattern）是普通的Lua值（使用userdata表示），并且通过元表为模式定义了一些特定的操作。

## 基本函数

**lpeg.match**
```lua
lpeg.match(pattern, subject[, init])
```
查找输入串`subject`中满足模式`pattern`的子串。
如果匹配成功则返回子串后一个字符的索引，或所有capture的值（如果pattern包含了capture的语法）。
如匹配失败则返回nil。

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
- 如果值是非负数n，则返回匹配n个字符的pattern
- 如果值是负数-n，则返回的pattern在输入串只剩不到n个字符时才匹配成功；lpeg.P(-n)相当于-lpeg.P(n)，见一元减操作符部分
- 如果值是布尔值，则返回的pattern总匹配成功或失败（根据布尔实际值），它不消耗输入字符串中的字符
- 如果值是一个表，它被当作语法进行解析，见Grammars部分
- 如果值是一个函数，`returns a pattern equivalent to a match-time capture over the empty string`

**lpeg.B**
```lua
lpeg.B(patt)
```
返回的pattern只在输入串当前位置之前的字符匹配patt时才表示匹配。
模式patt必须只匹配固定长度的字符串，且不能包含capture。
像and predicate（#patt）一样，返回的pattern不管匹配成功或失败都不会消耗输入字符串中的字符。

**lpeg.R**
```lua
lpeg.R({range})
```
返回pattern匹配给定范围内的单个字符。
每个范围是一个长度为2的字符串，例如"xy"表示的范围包含两个字符x和y。
例如lpeg.R("09")匹配数字，lpeg.R("az", "AZ")匹配字母。

**lpeg.S**
```lua
lpeg.S(string)
```
返回pattern匹配给定集合中的单个字符。例如lpeg.S("+-*/")匹配算术运算符。
注意如果传入的字符串只包含一个字符，则如lpeg.P("a")等价于lpeg.S("a")也等价于lpeg.R("aa")，
另外lpeg.S("")和lpeg.R()返回的pattern总匹配失败。

**lpeg.V**
```lua
lpeg.V(v)
```
这个函数创建语法的非终结符（或变量），创建的变量引用的pattern位于当前table的v位置（v是table的索引或键）。
见Grammars部分。

**lpeg.locale**
```lua
lpeg.locale([table])
```
返回当前locale对应的字符类的匹配pattern，所有pattern保存在一个table中。
其中包括alnum，alpha，cntrl，digit，graph，lower，print，punct，space，upper，xdigit。
每个pattern都匹配属于对应字符集合中的单个字符。
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
然而使用这种方式不能定义递归pattern，此时我们需要用到grammer。
LPeg使用table表示grammer，table中的每一个entry表示一条规则。
例如下面的例子匹配由a和b组成的字符串，并且其中的a和b的个数相等（the following grammar matches
strings of a's and b's that have the same number of a's and b's）：
```lua
equalcount = lpeg.P{
  "S";                                               --> 初始规则的名称为S
  S = "a" * lpeg.V"B" + "b" * lpeg.V"A" + "",        --> 规则S的定义
  A = "a" * lpeg.V"S" + "b" * lpeg.V"A" * lpeg.V"A", --> 规则A的定义
  B = "b" * lpeg.V"S" + "a" * lpeg.V"B" * lpeg.V"B", --> 规则B的定义
} * -1
```
其中table索引1位置定义了语法的初始规则，如果其值是字符串则这个字符串是初始规则的名称，否则索引1位置的值就是初始规则本身。
语法最终构建的pattern是匹配初始规则的pattern。

## 生成捕获

捕获只有在匹配成功时才产生值，每个捕获可以产生0或多个值。
一般情况下，捕获的值只有在匹配完全成功后才开始运算，但除了match-time的捕获e除外。
这种捕获只要自己匹配，就会立即运算所有嵌套的值，并调用对应的函数（这些函数定义是否匹配以及要产生哪些值）。

**lpeg.C**
```lua
lpeg.C(patt)
```
创建一个simple capture，用于捕获匹配patt的输入子串，
如果patt还有其他的捕获，这些捕获在这个捕获之后返回。

**lpeg.Carg**
```lua
lpeg.Carg(n)
```
创建一个argument capture，这个捕获匹配空字符串，产生的值是lpeg.match的第n个额外参数。


**lpeg.Cb**
```lua
lpeg.Cb(name)
```
创建一个back capture，它匹配空字符串，产生的值是最近匹配完整的名为name的group capture的值。
匹配完整的意思是该group capture对应的整个pattern已完成匹配（A Complete capture means that 
the entire pattern corresponding to the capture has matched）。
最近的group capture是上一个完整的最外层的group capture，该capture不在其他完整capture的内部
（Most recent means the last complete outermost group capture with the given name, 
an Outermost capture means that the capture is not inside another complete capture）。

**lpeg.Cc**
```lua
lpeg.Cc([value,...])
```
创建一个constant capture，它匹配空字符串，产生的值为所有传入的参数。

**lpeg.Cf**
```lua
lpeg.Cf(patt,func)
```
创建一个fold capture，如果patt产生额捕获为C1 C2 ... Cn，
那么这个捕获产生的值为func(...func(func(C1,C2),C3)...,Cn)。
其中patt至少应该有一个捕获并产生至少一个值。例如：
```lua
number = lpeg.R"09"^1 / tonumber --> 匹配1到多个数字，创建的捕获会将这个数字字符串传入tonumber函数（将字符串转换成数值）
list = number * ("," * number)^0 --> 匹配逗号分割的number序列
function add(acc, newvalue)      --> 辅助函数用于累加
  return acc + newvalue
end
sum = lpeg.Cf(list, add)         --> 创建的捕获会将list匹配的所有number数值通过add函数进行累加
print(sum:match("10,30,43"))     --> 83
```

**lpeg.Cg**
```lua
lpeg.Cg(patt[,name])
```
创建一个group capture，它将patt匹配返回的所有值group成一个capture。
形成的capture可以是匿名的（name没有指定），也可以是命名的（指定了一个非nil的Lua值为name）。
匿名group通常用于将多个capture的所有值group到一个capture中。
而命名group大多数情况下不返回值，它的值仅在随后的back capture中或用在table capture内部时才有意义
（its values are only relevant for a following back capture or when used inside a table capture）。

**lpeg.Cp**
```lua
lpeg.Cp()
```
创建一个position capture，它匹配空字符串，产生的值是收入串匹配的位置（一个整数）。

**lpeg.Cs**
```lua
lpeg.Cs(patt)
```
创建一个substitution capture，它捕获匹配patt的输入子串，并对它进行替换。
For any capture inside patt with a value, the substring that matched the capture
is replaced by the capture value (which should be a string).
The final captured value is the string resulting from all replacements.

**lpeg.Ct**
```lua
lpeg.Ct(patt)
```
创建一个table capture。这个捕获将创建一个table，patt匹配的所有匿名捕获值都将添加到这个table中（从索引1开始添加）。
另外patt匹配的所有命名capture group，也会以capture group的名称为键保存到table中（Moreover, for each named capture group
created by patt, the first value of the group is put into the table with the group name as its key）。
最后匹配的结果以table返回，这个table通过以上方式保存了所有捕获的值。

**patt/string**

创建一个string capture，产生的值是string的拷贝，除非字符串中包含%转义字符。
转义序列%n，其中1到9表示patt中的n个捕获，而0表示patt的整个捕获。另外%%表示字符%。

**patt/number**

创建一个numbered capture，其中0表示没有捕获值，而非零表示patt的第n个捕获。

**patt/table**

创建一个query capture，匹配patt后返回的第1个值会作为table的索引或键用来查询table中的值，
如果查询成功则这个值作为最终capture的值返回，否则不产生capture值。

**patt/function**

创建一个function capture，patt的所有捕获值被作为参数传入函数（如果patt没有捕获则传入整个匹配子串），
函数的返回值是这个捕获的值。如果该函数没有返回值，则这个捕获不产生值。

**lpeg.Cmt**
```lua
lpeg.Cmt(patt, function)
```
创建一个match-time capture，不同于其他捕获，这个捕获自身一旦匹配就会立即运算其值。
它所有的嵌套捕获值都会立即运算出来，然后调用给定的函数function。
传入这个函数的参数是整个输入串、当前匹配位置、以及所有patt产生的捕获值。
该函数返回的第一个值定义了匹配的行为，如果返回一个整数则表示匹配成功，而返回的整数变成新的当前位置
（假设输入串的长度为n并且当前位置为i，则返回的整数必须在范围[i, n+1]内）。
如果返回的是true则表示匹配成功而且不销毁输入字符（相当于然后整数i);
如果返回false、nil或没有返回值则表示匹配失败。
而任何额外的函数返回值，都会作为该捕获的产生值。

## 简单示例

**Using a Pattern**

```lua
local lpeg = require "lpeg"
p = lpeg.R"az"^1 * -1          --> 匹配小写字母1次或多次然后再匹配-1（end-of-string）
print(p:match("hello"))        --> 6
print(lpeg.match(p, "hello"))  --> 6
print(p:match("1 hello"))      --> nil
```

**Name-value lists**

```lua
lpeg.locale(lpeg)                         --> adds locale entries into 'lpeg' table
local space = lpeg.space^0                --> 匹配0个或多个space字符
local name = lpeg.C(lpeg.alpha^1) * space --> 匹配1个或多个字母（这1个或多个字母形成一个捕获），后面跟随空白
local sep = lpeg.S(",;") * space          --> 匹配逗号或分号后跟空白
local pair = lpeg.Cg(name * "=" * space * name) * sep^-1 --> 匹配名称、等号、空白和名称，后跟最多一个分割符号
local list = lpeg.Cf(lpeg.Ct("") * pair^0, rawset)       --> 
t = list:match("a=b, c = hi; next = pi")                 --> { a = "b", c = "hi", next = "pi" }
```

**Splitting a string**

```lua
function split(s, sep)
  sep = lpeg.P(sep)                --> sep匹配指定的分割字符
  local elem = lpeg.C((1 - sep)^0) --> (1-sep)表示不匹配分割字符但匹配任何1个字符（1等价与lpeg.P(1)），
                                   --> 因此elem匹配0到多个非分割字符（lpeg.C将这些字符构建成一个捕获）
  local p = elem * (sep * elem)^0  --> p先匹配一个elem，然后再匹配0到多个sep和elem的序列
  return lpeg.match(p, s)          --> 对给定输入串s进行匹配，返回所有的捕获值（即所有的elem）
end
```

如果split返回结果太多，可能导致Lua函数返回值个数溢出。这种情况下我们可以使用table收集这些值：
```lua
function split(s, sep)
  sep = lpeg.P(sep)                        --> sep匹配指定分割字符
  local elem = lpeg.C((1 - sep)^0)         --> 捕获0到多个非分割字符
  local p = lpeg.Ct(elem * (sep * elem)^0) --> 创建table capture，捕获的值将会保存到table中
  return lpeg.match(p, s)                  --> 对给定输入串s进行匹配，返回保存了所有捕获值的table
end
```

**Searching for a pattern**

LPeg中基本的match函数只能执行原地匹配，给定模式p，如果编写出匹配任何位置的子串呢？
方法之一如下：
```lua
function anywhere(p)
  return lpeg.P{ p + 1 * lpeg.V(1) } --> 匹配p或者跳过1个字符后继续匹配
end

-- 利用position capture进一步获取匹配子串的位置信息
local I = lpeg.Cp()
function anywhere (p)
  return lpeg.P{ I * p * I + 1 * lpeg.V(1) }
end
print(anywhere("world"):match("hello world!")) --> 7   12
```

另一种方式是：
```lua
local I = lpeg.Cp()
function anywhere(p)
  return (1 - lpeg.P(p))^0 * I * p * I
end

-- 限制在一个单词内部匹配
local t = lpeg.locale()
function atwordboundary(p)
  return lpeg.P{
    [1] = p + t.alpha^0 * (1 - t.alpha)^1 * lpeg.V(1)
  }
end
```

**Balanced parentheses**

```lua
b = lpeg.P{ "(" * ((1 - lpeg.S"()") + lpeg.V(1))^0 * ")" }
```


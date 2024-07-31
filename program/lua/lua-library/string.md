
## String Manipulation

This library provides generic functions for string manipulation, 
such as finding and extracting substrings, and pattern matching. 
When indexing a string in Lua, the first character is at position 1 (not at 0, as in C). 
Indices are allowed to be negative and are interpreted as indexing backwards, from the end of the string. 
Thus, the last character is at position -1, and so on.

The string library provides all its functions inside the table string. 
It also sets a metatable for strings where the `__index` field points to the string table. 
Therefore, you can use the string functions in object-oriented style. 
For instance, `string.byte(s,i)` can be written as `s:byte(i)`.

The string library assumes one-byte character encodings.

字符串库实现对字符串的操作，如查找和提取子串，以及模式匹配。 索引字符串时，第一个字符在位置1上（不像C语言是0）。
索引值可以是负数，从字符串结尾开始往回计数，因此最后一个字符在位置-1，依次类推。

字符串库函数都导出在string表中供使用。 另外，字符串都设置了元表，元表的`__index`元素指向string全局表。
因此，可以用面向对象的方式使用字符串函数，例如`string.byte(s,i)`可以写成`s:byte(i)`。

字符串库假设使用单字节的字符编码。

### string.byte
```lua
byte(s [, i [, j]])
-- return integers of characters in s[i..j]

s = “0123456789”
s:byte()    --> 48
s:byte(1)   --> 48
s:byte(1,1) --> 48
s:byte(1,2) --> 48 49
s:byte(1,3) --> 48 49 50
```

Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`. 
The default value for `i` is 1; the default value for `j` is `i`. 
These indices are corrected following the same rules of function `string.sub`.
Numeric codes are not necessarily portable across platforms.

返回字符子串`s[i..j]`中每个字节对应的整数值。
默认`i`是1，`j`是`i`。对传入的索引参数的处理和调整跟`string.sub`函数相同。

### string.char
```lua
char(···)
-- return a string with each byte from a integer argument
-- the integer cann't be larger than 255

string.char(48)       --> 0
string.char(48,49)    --> 01
string.char(48,49,50) --> 012
string.char(255)      --> ok
string.char(256)      --> bad argument
print(string.char() == "") --> true
```

Receives zero or more integers. Returns a string with length equal to the number of arguments, 
in which each character has the internal numeric code equal to its corresponding argument.
Numeric codes are not necessarily portable across platforms.

接收0个或多个整数，并将每个整数当作一个字节值，返回所有这些字节组成的字符串。
如果传入0个整数，则返回空字符串。

### string.len 
```lua
len(s)
-- return the length of the string `s`
```

Receives a string and returns its length. The empty string "" has length 0. 
Embedded zeros are counted, so "a\000bc\000" has length 5.

返回字符串的长度。空字符串`""`的长度是0。
允许包括内嵌的0,如`"a\000bc\000"`的长度是5。

### string.lower 
```lua
lower(s)
-- return a lowercase copy of the string `s`
```

Receives a string and returns a copy of this string with all uppercase letters changed to lowercase. 
All other characters are left unchanged. 
The definition of what an uppercase letter is depends on the current locale.

将字符串转换成小写形式，除大写字母之外的其他字符都保持不变。
大写字母的定义依赖于当前的本地设置。

### string.upper 
```lua
upper(s)
-- return a uppercase copy of the string `s`
```

Receives a string and returns a copy of this string with all lowercase letters changed to uppercase. 
All other characters are left unchanged. 
The definition of what a lowercase letter is depends on the current locale. 

将字符串转换成大写形式，除小写字母之外的其他字符都保持不变。
小写字母的定义依赖于当前的本地设置。

### string.reverse 
```lua
reverse(s)
-- return the reverse version of the string `s`.
```

Returns a string that is the string `s` reversed.

返回`s`的反转字符串。

### string.dump 
```lua
dump(function [, strip])
-- dump `function` to binary representation
-- return the string of this binary representation
-- @strip: strip debug informaion or not
```

Returns a string containing a binary representation (a binary chunk) of the given function, 
so that a later load on this string returns a copy of the function (but with new upvalues). 
If `strip` is a `true` value, the binary representation may not include all debug information 
about the function, to save space.

返回给定函数的二进制表示字符串，后面对这个字符串进行加载会返回这个函数的一份拷贝（但是使用新的**上值**）。
如果`strip`为`true`，则二进制表示不会包含函数的调试信息，来节省空间。

Functions with upvalues have only their number of upvalues saved. 
When (re)loaded, those upvalues receive fresh instances containing `nil`. 
(You can use the debug library to serialize and reload the upvalues 
of a function in a way adequate to your needs.)

拥有上值的函数，保存的仅是上值的个数。
当函数加载（或重新加载）时，这些上值会创建出新的实例初始化为`nil`
（可以使用调试库将函数的上值保存起来并重新加载这些值）。

### string.format 
```lua
format(formatstring, ···)
-- format variable number of arguments according to the `formatstring`
-- return the formatted result string
```

Returns a formatted version of its variable number of arguments 
following the description given in its first argument (which must be a string). 
The format string follows the same rules as the ISO C function `sprintf`. 
The only differences are that the options/modifiers `*`, `h`, `L`, `l`, `n`, and `p` are not supported 
and that there is an extra option, `q`. 
The `q` option formats a string between double quotes, 
using escape sequences when necessary to ensure that it can safely be read back by the Lua interpreter. 

根据给定格式将参数转换成字符串。格式字符串与C函数`sprintf`相似。
不同的是它不支持`*`、`h`、`L`、`l`、`n`以及`p`这些选项，但支持一个额外的选项`q`。
这个选项`p`会对字符串中的字符作适当的转义，以保证可以被Lua解释器安全读回。参考如下示例：

For instance, the call 
```lua
string.format('%q', 'a string with "quotes" and \n new line')
```
may produce the string:
```lua
"a string with \"quotes\" and \
new line"
```

Options `A`, `a`, `E`, `e`, `f`, `G`, and `g` all expect a number as argument. 
Options `c`, `d`, `i`, `o`, `u`, `X`, and `x` expect an integer. 
Option `q` expects a string. 
Option `s` expects a string without embedded zeros; if its argument is not a string, 
it is converted to one following the same rules of `tostring`.

选项`A`、`a`、`E`、`e`、`f`、`G`和`g`表示期待一个数值类型值。
选项`c`、`d`、`i`、`o`、`u`、`X`和`x`表示期待一个整数值。
选项`q`表示期待一个字符串。
选项`s`表示期待一个没有内嵌0的字符串，如果参数不是一个字符串，
则会根据`tostring`相同的规则将参数转换成字符串。

When Lua is compiled with a non-C99 compiler, options `A` and `a` (hexadecimal floats) 
do not support any modifier (flags, width, length). 

如果Lua使用非C99编译器编译，选项`A`和`a`不支持任何格式修饰符。

### string.rep 
```lua
rep(s, n [, sep])
-- concatenate `n` copies of the string `s` with a separate string `sep`
-- return the concatenated result string
```

Returns a string that is the concatenation of `n` copies of the string `s` separated by the string `sep`. 
The default value for `sep` is the empty string (that is, no separator). 
Returns the empty string if `n` is not positive.

返回字符串`s`的`n`份拷贝并用字符串`sep`进行分隔的字符串。
字符串`sep`的默认值是空串（即不对字符串进行分隔）。
如果`n`不是正数，会返回空字符串。

### string.find
```lua
find(s, pattern [, init [, plain]])
-- find the first sub-string that match `pattern`
-- return the sub-string's start and end index or nil
-- @init: start searching index of `s`
-- @plain: treat `pattern` as plain text
```

Looks for the first match of pattern (see §6.4.1) in the string `s`. 
If it finds a match, then find returns the indices of `s` where this occurrence starts and ends; 
otherwise, it returns `nil`. 
A third, optional numeric argument `init` specifies where to start the search; 
its default value is `1` and can be negative. 
A value of `true` as a fourth, optional argument `plain` turns off the pattern matching facilities, 
so the function does a plain "find substring" operation, 
with no characters in `pattern` being considered magic. 
Note that if `plain` is given, then `init` must be given as well.

在字符串`s`中查找第一个与模式匹配的子字符串。
如果查找成功，返回子字符串的开始索引和结束索引，否则返回`nil`。
第3个参数`init`表示从哪个索引处开始搜索，默认是1并且可以是负数。
第4个参数`plain`如果是`true`会关掉模式匹配功能，
函数会执行普通的子字符串查找功能，`pattern`中的字符都变成普通字符。
当指定`plain`时，`init`也同时要指定。

If the pattern has captures, then in a successful match the captured values are also returned, 
after the two indices.

如果模式串有**捕获**，这些捕获的匹配结果（子字符串）也会返回，跟在两个索引值后面。例如：
```lua
string.find("abcdefghijk", "ab(c(de)f(g)h)i")
-- 19cdefghdeg
```

### string.match 
```lua
match(s, pattern [, init])
-- look for the first match 
-- return all captured strings in the match or nil
```

Looks for the first match of pattern (see §6.4.1) in the string `s`. 
If it finds one, then `match` returns the captures from the pattern; otherwise it returns `nil`. 
If pattern specifies no captures, then the whole match is returned. 
A third, optional numeric argument `init` specifies where to start the search; 
its default value is 1 and can be negative.

在`s`中查找第一个与模式匹配的子字符串。如果找到模式的所有**捕获**，否则返回`nil`。
如果模式字符串中没有捕获，则返回匹配的整个子字符串。
第3个参数指定从`s`哪个索引处开始查找，这个值默认是1还可以是一个负数。

### string.gmatch 
```lua
gmatch(s, pattern)
-- return an iterator function
```

Returns an iterator function that, each time it is called, 
returns the next captures from `pattern` (see §6.4.1) over the string `s`. 
If pattern specifies no captures, then the whole match is produced in each call.

返回一个迭代函数，每次对这个迭代函数的调用都返回下一个匹配的字符串。如下面的例子。

As an example, the following loop will iterate over all the words from string `s`, printing one per line:
```lua
s = "hello world from Lua"
for w in string.gmatch(s, "%a+") do
  print(w)
end
```

The next example collects all pairs `key=value` from the given string into a table:
```lua
t = {}
s = "from=world, to=Lua"
for k, v in string.gmatch(s, "(%w+)=(%w+)") do
  t[k] = v
end
```

For this function, a caret `^` at the start of a `pattern` does not work as an anchor, 
as this would prevent the iteration. 

这个函数中的匹配字符串开头的`^`不匹配目标字符串的开头，而会阻止字符串迭代匹配。

### string.sub 
```lua
sub(s, i [, j])
-- return the substring s[i..j]
```

Returns the substring of `s` that starts at `i` and continues until `j`; 
`i` and `j` can be negative. 
If `j` is absent, then it is assumed to be equal to `-1` 
(which is the same as the string length). 
In particular, the call `string.sub(s,1,j)` returns a prefix of `s` with length `j`, 
and `string.sub(s, -i)` returns a suffix of `s` with length `i`.

返回从`s[i]`到`s[j]`对应的子字符串，`i`和`j`可以是负数。
如果`j`没有指定，则它的值是`-1`（表示字符串的长度）。
特别地`string.sub(s,1,j)`返回长度为`j`的前缀；`string.sub(s, -i)`返回长度为`i`的后缀。

If, after the translation of negative indices, `i` is less than `1`, it is corrected to `1`. 
If `j` is greater than the string length, it is corrected to that length. 
If, after these corrections, `i` is greater than `j`, the function returns the empty string.

当将负索引进行转换后，如果`i`小于1则会将它改成1，如果`j`大于字符串的长度会将它改成这个长度值。
调整之后，如果`i`比`j`大则会返回空字符串。

### string.gsub
```lua
gsub(s, pattern, rep [, n])
-- return a copy of `s` with all matched substring replaced by `rep`, and the total number of matches
-- @rep: can be a string, a table, or a function；if it is `false` or `nil`, no replacement
-- @n: only replace first `n` substrings
```

Returns a copy of `s` in which all (or the first `n`, if given) occurrences of the `pattern` (see 6.4.1)
have been replaced by a replacement string specified by `rep`, which can be a string, a table, or a function.
`gsub` also returns, as its second value, the total number of matches that occurred.
The name `gsub` comes from `Global SUBstitution`.

将字符串`s`中的所有（或前`n`个）匹配子串都替换成`rep`，然后返回替换之后的新字符串以及匹配的子串个数。
`rep`可以是字符串、表、或者函数。名字`gsub`来源于`Global SUBstitution`。

If `rep` is a string, then its value is used for replacement.
The character `%` works as an escape character: any sequence in `rep` of the form `%d`,
with `d` between 1 and 9, stands for the value of the `d`-th captured substring.
The sequence `%0` stands for the whole match. The sequence `%%` stands for a single `%`.

如果`rep`是一个字符串，则使用它的值对匹配子串进行替换。
转义字符`%`可以用在`rep`中，例如`%d`（`d`是从1到9中的一个数）表示当前匹配字符子串中的第`d`个**捕获**子串。
`%0`表示当前匹配的整个匹配子串。`%%`表示字符`%`。

If `rep` is a table, then the table is queried for every match, using **the first capture** as the key.
If `rep` is a function, then this function is called every time a match occurs,
with **all captured substrings** passed as arguments, in order.

如果`rep`是一个表，则使用当前匹配子串中的第1个**捕获**子串查询这个表，
然后用查询得到的字符串替换当前的匹配子串。
如果`rep`是一个函数，则使用当前匹配子串中的所有**捕获**子串去调用这个函数，
然后用函数返回的字符串替换当前的匹配子串。

In any case, if the pattern specifies no captures, then it behaves as if the whole pattern was inside a capture.
If the value returned by the table query or by the function call is a string or a number,
then it is used as the replacement string; otherwise, if it is `false` or `nil`, 
then there is no replacement (that is, the original match is kept in the string).

如果模式字符串中没有设置**捕获**，那么**捕获**的子串是整个匹配的字符子串。
如果表或函数返回的结果是字符串和数值，则使用它们对应的字符串值；
如果返回的是`false`或`nil`，那么匹配子串不会被替换。

Here are some examples:
```
x = string.gsub("hello world", "(%w+)", "%1 %1")
--> x = "hello hello world world"

x = string.gsub("hello world", "%w+", "%0 %0", 1)
--> x = "hello hello world"

x = string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2 %1")
--> x="world hello Lua from"

x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv)
--> x="home = /home/roberto, user = roberto"

x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)
     return load(s)()
   end)
--> x="4+5 = 9"

local t = {name="lua", version="5.3"}
x = string.gsub("$name-$version.tar.gz", "%$(%w+)", t)
--> x="lua-5.3.tar.gz"
```

### string.pack 
```lua
pack(fmt, v1, v2, ···)
-- pack the values into binary form according to the given format `fmt`
-- return the result string
```

Returns a binary string containing the values `v1`, `v2`, etc. packed 
(that is, serialized in binary form) according to the format string `fmt` (see §6.4.2).

根据`fmt`字符串指定的格式将值序列化成二进制形式，并将结果保存在字符串中返回。

### string.unpack 
```lua
unpack(fmt, s [, pos])
-- unpack values out in string `s` according to the format string 'fmt'
-- return unpacked values and the first unread byte in `s`
-- @pos: index where to start reading the string of `s`
```

Returns the values packed in string `s` (see `string.pack`) 
according to the format string `fmt` (see §6.4.2). 
An optional `pos` marks where to start reading in `s` (default is 1). 
After the read values, this function also returns the index of the first unread byte in `s`.

根据格式化字符串`fmt`将`s`中的二进制值解析出来并返回。
参数`pos`指出从`s`哪个位置开始进行读取（默认是1）。
该函数还会返回`s`中没有被解析部分的开始索引。

### string.packsize 
```lua
packsize(fmt)
-- return the result string's size according to the format string `fmt`
```

Returns the size of a string resulting from `string.pack` with the given format. 
The format string cannot have the variable-length options `s` or `z` (see §6.4.2).

返回格式化字符串`fmt`对应的最终字符串长度。格式字符串中不能包含长度不定的`s`或`z`选项。

## Patterns

Patterns in Lua are described by regular strings, which are interpreted as patterns by the pattern-matching
functions `string.find`, `string.gmatch`, `string.gsub`, and `string.match`.
This section describes the syntax and the meaning (that is, what they match) of these strings.

模式字符串用在`string.find`、`string.gmatch`、`string.gsub`、以及`string.match`函数中。
这部分描述这些字符串的语法以及其含义（它们能匹配哪些字符串）。

**Character Class:**

A *character class* is used to represent a set of characters.
The following combinations are allowed in describing a character class:

字符类别用于表示一个字符集合。下面的这些表示都是一个字符类别：

- **x:** (where `x` is not one of the *magic characters* ^$()%.[]*+-?) represents the character `x` itself
- **.:** (a dot) represents all characters
- **%a:** represents all letters
- **%l:** represents all lowercase characters
- **%u:** represents all uppercase characters
- **%d:** represents all digits
- **%w:** represents all alphanumeric characters
- **%p:** represents all punctuation characters
- **%g:** represents all printable characters except space
- **%c:** represents all control characters
- **%s:** represents all space characters
- **%x:** represents all hexadecimal digits
- **%**`x`**:** (where `x` is any non-alphanumeric charatcher) represents the character `x`.
  This is the standard way to escape the magic characters.
  Any non-alphanumeric character (including all punctuation characters, even the non-magical)
  can be preceded by a `%` when used to represent itself in a pattern.

    不是特殊字符`^$()%.[]*+-?`的其他字符都表示字符本身；点号`%.`代表所有字符；`%a`表示所有字母；
    `%l`表示小写字母；`%u`表示所有大写字母；`%d`表示数字；`%w`表示所有字母数字；`%p`表示所有标点符号；
    `%g`表示除空格之外的所有可打印字符；`%c`表示所有控制字符；`%s`表示所有空白字符；`%x`表示十六进制数字；
    
    `%<non-alphnum>`表示非字母数字字符本身。
    它可用于表示特殊字符，也可以用于表示除字母数字之外的其他字符（例如所有的标点符号）。
    
- **[set]:** represents the class which is the union of all characters in `set`.
  A range of characters can be specified by separating the end characters of the range,
  in ascending order, with a `-`. All classes described above can also be used as components in `set`.
  All other characters in `set` represent themselves.
  For example, `[%w_]` (or `[_%w]`) represents all alphanumeric characters plus the underscore,
  `[0-7]` represents the octal digits, and `[0-7%l%-]` represents the octal digits plus the lowercase letters 
  plus the `-` character. The interaction between ranges and classes is not defined.
  Therefore, patterns like `[%a-z]` or `[a-%%]` have no meaning.
  
    `[set]`表示`set`集合中的所有字符构成一个字符类别。可以使用字符`-`表示一个范围。
    上面介绍的所有字符类别都可以用在`set`中表示一类字符，所有其他字符都代表它们本身。
    例如`[%w_]`（或`[_%w]`）表示字母数字和下划线。`[0-7]`表示八进制数字。
    `[0-7%l%-]`表示八进制数字，以及小写字母和字符`-`。
    注意表示范围的`-`不能与字符类别使用在一起，例如`[%a-z]`或`[a-%%]`是没有意义的。

- **[~set]:** represents the complement of `set`, where `set` is interpreted as above.

    `[~set]`表示`set`的补集，`set`的解释如上。

For all classes represented by string letters (`%a`, `%c`, etc.),
the corresponding uppercase letter represents the complement of the class.
For instance, `%S` represents all non-space characters.

用字母表示的所有字符类别（例如`%a`、`%c`、等等），它的大写形式表示其字符集合的补集。
例如`%S`表示所有非空白字符。

The definitions of letter, space, and other character groups depend on the current locale.
In particular, the class `[a-z]` may not be equivalent to `%l`.

字母、空格、以及其他字符的定义都依赖于当前的本地设置。
例如`[a-z]`不一定等价于`%l`。

**Pattern Item:**

A *pattern item* can be

- a single character class, which matches any single character in the class

    一个匹配项可以是一个字符类别，它匹配字符类别中的一个字符。

- a single character class followed by `*`, 
  which matches 0 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence.
    
    可以是一个字符类别跟上`*`，它匹配字符类别中的0个或多个字符形成的字符串。
    匹配采用最长匹配原则。
  
- a single character class followed by `+`, 
  which matches 1 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence.

    可以是一个字符类别跟上`+`，它匹配字符类别中的1个或多个字符形成的字符串。
    匹配采用最长匹配原则。

- a single character class followed by `-`, 
  which also matches 0 or more repetitions of characters in the class.
  Unlike `*`, these repetition items will always match the shortest possible sequence.

    可以是一个字符类别跟上`+`，它匹配字符类别中的0个或多个字符形成的字符串。
    与`*`不同，它采用最短匹配原则。

- a single character class followed by `?`, 
  which matches 0 or 1 occurrence of a character in the class.
  It always matches one occurrence if possible.

    可以是一个字符类别跟上`?`，它匹配字符类别中的0个或1个字符。
    匹配使用最长匹配原则，尽可能去匹配一个字符。

- `%n`, for `n` between 1 and 9; 
  such item matches a substring equal to the `n`-th captured string (see below).

    匹配项还可以是`%n`，其中`n`表示从1到9之间的数字。
    它匹配与第`n`个**捕获**子串相等的字符串。

- `%bxy`, where `x` and `y` are two distint characters; 
  such item matches strings that start with `x`, end with `y`,
  and where the `x` and `y` are *balanced*. 
  This means that, if one reads the string from left to right, 
  counting `+1` for an `x` and `-1` for a `y`, 
  the ending `y` is the first `y` where the count reaches 0.
  For instance, the item `%b()` matches expressions with balanced parentheses.

    匹配项还可以是`%bxy`，其中`x`和`y`是两个不相同的字符。
    它匹配以`x`开始用`y`结束，并且`x`的个数与`y`的个数相等的字符串。

- `%f[set]`, a *frontier pattern*; such item matches an empty string at any position such that 
  the next character belongs to `set` and the previous character does not belong to `set`.
  The set `set` is interpreted as previously described.
  The begining and the end of the subject are handled as if they were the character `\0`.

    匹配项还可以是`%f[set]`，它匹配任何位置上前一个字符不属于`set`而后一个字符属于`set`的空字符串。
    目标字符串的开头和结尾被当作字符`\0`来处理。

**Pattern:**

A *pattern* is a sequence of pattern items. 
A caret `^` at the beginning of a pattern anchors the match at the beginning of the subject string.
A `$` at the end of a pattern anchors the match at the end of the subject string.
At other positions, `^` and `$` have no special meaning and represent themselves.

匹配字符串是由多个匹配项组成的序列。
匹配字符串开头的`^`表示匹配目标字符串的开头，匹配字符串结尾的`$`表示匹配目标字符串的结尾。
其他位置的`^`和`$`没有特殊含义，仅代表其字符本身。

**Capture:**

A pattern can contain sub-patterns enclosed in parentheses; they describe **capture**.
When a match succeeds, the substrings of the subject string 
that match captures are stored (captured) for future use.
Captures are numbered according to their left parentheses.
For instance, in the pattern `(a*(.)%w(%s*))`, 
the part of the string matching `a*(.)%w(%s*)` is stored as the first capture (and therefore has number 1);
the character matching `.` is captured with number 2, and the part matching `%s*` has number 3.

匹配字符串可以包含用括号括起的子匹配串，这些子串称为**捕获**。
匹配到一个字符串后，字符串中与所有**捕获**对应的子串都会保存起来以供使用。
这些**捕获**的序号依据左括号来计数。
例如`(a*(.)%w(%s*))`，匹配`a*(.)%w(%s*)`的部分是第1个**捕获**字符串（序号是1），
匹配`.`的部分是第2个，而匹配`%s*`的部分是第3个。

As a special case, the empty capture `()` captures the current string position (a number).
For instance, if we apply the pattern `()aa()` on the string `flaaap`, there will be two captures: 3 and 5.

特别地，空**捕获**`()`捕获字符串的当前位置（一个数值）。
例如，用`()aa()`去匹配`flaaap`，产生的两个**捕获**是3和5
（前面的`()`匹配其后字符的位置，后面的`()`匹配其当前占据的位置）。

### Format Strings for Pack and Unpack

The first argument to `string.pack`, `string.packsize`, and `string.unpack` is a format string,
which describes the layout of the structure being created or read.

A format string is a sequence of conversion options. The conversion options are as follows:
- **<:** sets little endian
- **>:** sets big endian
- **=:** sets native endian
- **![n]:** sets maximum alignment to `n` (default is native alignment)
- **b:** a signed byte (`char`)
- **B:** an unsigned byte (`char`)
- **h:** a signed `short` (native size)
- **H:** an unsigned `short` (native size)
- **l:** a signed `long` (native size)
- **L:** an unsigned `long` (native size)
- **j:** a `lua_Integer`
- **J:** a `lua_Unsigned`
- **T:** a `size_t` (native size)
- **i[n]:** a signed `int` with `n` bytes (default is native size)
- **I[n]:** an unsigned `int` with `n` bytes (default is native size)
- **f:** a `float` (native size)
- **d:** a `double` (native size)
- **n:** a `lua_Number`
- **cn:** a fixed-sized string with `n` bytes
- **z:** a zero-terminated string
- **s[n]:** a string preceded by its length coded as an unsigned integer with `n` bytes (default is a `size_t`)
- **x:** one byte of padding
- **Xop:** an empty item that aligns according to option `op` (which is otherwise ignored)
- **' ':** (empty space) ignored

用在`string.pack`、`string.packsize`、以及`string.unpack`中的格式字符串可以使用如下的**格式选项**：
**<**表示使用小端字节序；**>**表示使用大端字节序；**=**表示使用本地机器使用的字节序；
**![n]**指定最大对齐字节数为`n`个字节；**b**和**B**表示有符号和无符号字节型（`char`）；
**h**和**H**表示有符号和无符号短整型（`short`）；**l**和**L**表示有符号和无符号长整型（`long`）；
**j**和**J**表示`lua_Integer`和`lua_Unsigned`；**T**表示`size_t`；
**i[n]**和**I[n]**表示有符号和无符号的`n`字节整型（默认是`int`型）；
**f**和**d**表示浮点型`float`和`double`；
**n**表示`lua_Number`；**cn**表示长度为`n`的字符串；**z**表示0结尾的字符串；
**s[n]**表示字符串长度存储在前`n`个字节中的字符串（默认的长度类型是`size_t`）；
**x**表示一个填补字节；**Xop**表示忽略一个格式选项`op`对应的字节数；
格式字符串中可以包含空格**' '**，它们没有含义。

(A `[n]` means an optional integral numeral.) Except for padding, spaces, and configurations (options "xX <=>!"),
each option corresponds to an argument (in `string.pack`) or a result (in `string.unpack`).

For options `!n`, `sn`, `in`, and `In`, `n` can be any integer between 1 and 16.
All integral options check overflows; `string.pack` checks whether the given value fits in the given size;
`string.unpack` checks whether the read value fits in a Lua integer.

`[n]`表示一个可选的整数。除了这些选项（`xX <=>!`）之外的其他**格式选项**
都对应`string.pack`中的一个参数或`string.unpack`中的一个结果。
可选整数`n`可以是1到16中的任何一个整数。
所有与整数相关的**格式选项**都会检查是否会发生溢出。
`string.pack`会检查当前的值是否能够存储在指定大小的整数中；
`string.unpack`会检查读取的值是否能够存储到Lua的整型变量中。

Any format string starts as if prefixed by `!1=`, that is, 
with maximum alignment of 1 (no alignment) and native endianness.

Alignment works as follows: For each option, the format gets extra padding until the data starts at an offset
that is a multiple of the minimum between the option size and the maximum alignment; 
this minimum must be a power of 2.
Options `c` and `z` are not aligned; option `s` follows the alignment of its starting integer.

All padding is filled with zeros by `string.pack` (and ignored by `string.unpack`).

任何格式字符串都相当于使用`!1=`开头，即默认不进行对齐并且使用本地机器使用的字节序。
数据对齐会对齐到**格式选项**的字节数与最大对齐字节数的较小值，这个较小值必须是2的幂。
格式选项`c`和`z`对应的数据不会进行对齐，格式选项`s`对应的数据根据其开始整数的对齐而对齐。
所有填补字节都被`string.pack`写成0（并且被`string.unpack`忽略）。

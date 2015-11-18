
## UTF-8 Support

This library provides basic support for UTF-8 encoding. 
It provides all its functions inside the table `utf8`. 
This library does not provide any support for Unicode other than the handling of the encoding. 
Any operation that needs the meaning of a character, such as character classification, is outside its scope.

这个库提供对UTF-8编码最基础的支持。所有函数都导出在全局表`utf8`中供使用。
这个库不支持Unicode编码之外的任何其他功能。
例如像字符分类等字符相关的操作都不在其支持范围内。

Unless stated otherwise, all functions that expect a byte position as a parameter assume that 
the given position is either the start of a byte sequence or one plus the length of the subject string. 
As in the string library, negative indices count from the end of the string. 

除非特别说明，所有函数的位置参数默认都是第一个字节位置或字符串长度加1。
像字符串库一样，负的索引位置从字符串末尾算起。

### utf8.char 
```lua
char(···)
-- return a string with each utf-8 character from a integer argument
-- the integer can be larger than 255
```

Receives zero or more integers, converts each one to its corresponding UTF-8 byte sequence 
and returns a string with the concatenation of all these sequences.

这个函数接收0个或多个整数，并将每个整数转换成对应的UTF-8字符的字节序列，返回所有这些序列组成的字符串。
如果传入0个整数，则返回空字符串。

### utf8.charpattern

The pattern (a string, not a function) `[\0-\x7F\xC2-\xF4][\x80-\xBF]*` (see §6.4.1), 
which matches exactly one UTF-8 byte sequence, assuming that the subject is a valid UTF-8 string.

这个是一个匹配字符串，用于匹配一个有效的UTF-8字节序列。

### utf8.codes 
```lua
codes(s)
-- used to interate characters in utf-8 string
```

Returns values so that the construction 
```lua
for p, c in utf8.codes(s) do body end
```
will iterate over all characters in string `s`, with `p` being the position (in bytes) 
and `c` the code point of each character. 
It raises an error if it meets any invalid byte sequence.

每次迭代中`p`取得当前UTF-8字符的开始字节位置，`c`取得当前的UTF-8字符值。
如果遇到非法的UTF-8字节序列则会抛出异常。

### utf8.codepoint 
```lua
codepoint(s [, i [, j]])
-- return integers for all utf-8 characters in s[i..j]
```

Returns the codepoints (as integers) from all characters in `s` that 
start between byte position `i` and `j` (both included). 
The default for `i` is 1 and for `j` is `i`. 
It raises an error if it meets any invalid byte sequence.

返回UTF-8字符子串`s[i..j]`中所有的字符整数值。默认`i`是1，`j`是`i`。
如果遇到非法的UTF-8字节序列则会抛出异常。

### utf8.len 
```lua
len(s [, i [, j]])
-- return the number of utf-8 characters in s[i..j]
-- otherwise return false and the postion of the first invalid byte
```

Returns the number of UTF-8 characters in string `s` that 
start between positions `i` and `j` (both inclusive). 
The default for `i` is `1` and for `j` is `-1`. 
If it finds any invalid byte sequence, 
returns a `false` value plus the position of the first invalid byte.

返回字符子串`s[i..j]`中的UTF-8字符个数。默认`i`是1，`j`是`i`。
如果找到不合法的UTF-8字节序列，则返回`false`以及非法字节序列的第一个字节位置。

### utf8.offset 
```lua
offset(s, n [, i])
-- return the index of n-th utf-8 character in s[i..$]
-- or the index of |n|-th uft-8 character before s[i] if n is negative
-- or nil if the result position is invalid

utf8.offset("abcdefg", 1)     --> 1
utf8.offset("abcdefg", -1)    --> 7
utf8.offset("abcdefg", 3, 4)  --> 6
utf8.offset("abcdefg", -3, 4) --> 1
utf8.offset("abcdefg", 0, 4)  --> 4
utf8.offset("abcdefg", 8, 4)  --> nil
utf8.offset("abcdefg", 0, 9)  --> bad argument
```

Returns the position (in bytes) where the encoding of the `n`-th character of `s` 
(counting from position `i`) starts. 
A negative `n` gets characters before position `i`. 
The default for `i` is 1 when `n` is non-negative and `#s + 1` otherwise, 
so that `utf8.offset(s, -n)` gets the offset of the `n`-th character 
from the end of the string. 
If the specified character is neither in the subject nor right after its end, 
the function returns `nil`.

返回字符子串`s[i..$]`中的第`n`个UTF-8字符的位置。
如果`n`是负数，则返回`i`之前`|n|`个UTF-8字符的位置（从`i`前一个位置开始算）。
如果`n`是非负数，则`i`的默认值是1，否则`i`的默认值是`#s + 1`。
因此`utf8.offset(s, -n)`表示字符串末尾之前`n`个UTF-8字符的位置。
如果对应的字符位置不是有效位置，则返回`nil`。

As a special case, when `n` is 0 the function returns the start of 
the encoding of the character that contains the `i`-th byte of `s`.

This function assumes that `s` is a valid UTF-8 string. 

如果`n`是0，则返回`i`处对应的UTF-8字符的位置。
这个函数假设`s`是一个合法的UTF-8字符串。

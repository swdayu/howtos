
## 6.4 String Manipulation

This library provides generic functions for string manipulation, such as finding and extracting substrings, and pattern matching. When indexing a string in Lua, the first character is at position 1 (not at 0, as in C). Indices are allowed to be negative and are interpreted as indexing backwards, from the end of the string. Thus, the last character is at position -1, and so on.

The string library provides all its functions inside the table string. It also sets a metatable for strings where the __index field points to the string table. Therefore, you can use the string functions in object-oriented style. For instance, string.byte(s,i) can be written as s:byte(i).

The string library assumes one-byte character encodings.

字符串库实现对字符串的操作，如查找和提取子串，以及模式匹配。 索引字符串时，第一个字符在位置1上（不像C语言是0）。 索引值可以是负数，从字符串结尾开始往回计数，因此最后一个字符在位置-1，依次类推。

字符串库函数都导出在string表中供使用。 另外，字符串都设置了元表，元表的__index元素指向string全局表。 因此，可以用面向对象的方式使用字符串函数，例如string.byte(s,i)可以写成s:byte(i)。

字符串库假设使用单字节的字符编码。


**string.byte(s [, i [, j]])**

Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`. 
The default value for `i` is 1; the default value for `j` is `i`. 
These indices are corrected following the same rules of function `string.sub`.
Numeric codes are not necessarily portable across platforms.

```
s = “0123456789”
s:byte()    => 48
s:byte(1)   => 48
s:byte(1,1) => 48
s:byte(1,2) => 48 49
s:byte(1,3) => 48 49 50
```

**string.char(···)**

Receives zero or more integers. Returns a string with length equal to the number of arguments, 
in which each character has the internal numeric code equal to its corresponding argument.
Numeric codes are not necessarily portable across platforms.

```
> string.char(48)       => 0
> string.char(48,49)    => 01
> string.char(48,49,50) => 012
> string.char(255) -- ok
> string.char(256) -- bad argument
```

**string.dump(function [, strip])**

Returns a string containing a binary representation (a binary chunk) of the given function, 
so that a later load on this string returns a copy of the function (but with new upvalues). 
If `strip` is a true value, the binary representation may not include all debug information about the function, 
to save space.

Functions with upvalues have only their number of upvalues saved. 
When (re)loaded, those upvalues receive fresh instances containing `nil`. 
(You can use the debug library to serialize and reload the upvalues of a function in a way adequate to your needs.)

**string.find (s, pattern [, init [, plain]])**

Looks for the first match of pattern (see §6.4.1) in the string s. 
If it finds a match, then find returns the indices of s where this occurrence starts and ends; 
otherwise, it returns nil. A third, optional numeric argument init specifies where to start the search; 
its default value is 1 and can be negative. 
A value of true as a fourth, optional argument plain turns off the pattern matching facilities, 
so the function does a plain "find substring" operation, with no characters in pattern being considered magic. 
Note that if plain is given, then init must be given as well.

If the pattern has captures, then in a successful match the captured values are also returned, 
after the two indices.


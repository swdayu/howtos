
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
s:byte()    --> 48
s:byte(1)   --> 48
s:byte(1,1) --> 48
s:byte(1,2) --> 48 49
s:byte(1,3) --> 48 49 50
```

**string.char(···)**

Receives zero or more integers. Returns a string with length equal to the number of arguments, 
in which each character has the internal numeric code equal to its corresponding argument.
Numeric codes are not necessarily portable across platforms.

```
> string.char(48)       --> 0
> string.char(48,49)    --> 01
> string.char(48,49,50) --> 012
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


**string.gsub(s, pattern, rep [, n])**

Returns a copy of `s` in which all (or the first `n`, if given) occurrences of the `pattern` (see 6.4.1)
have been replaced by a replacement string specified by `rep`, which can be a string, a table, or a function.
`gsub` also returns, as its second value, the total number of matches that occurred.
The name `gsub` comes from `Global SUBstitution`.

If `rep` is a string, then its value is used for replacement.
The character `%` works as an escape character: any sequence in `rep` of the form `%d`,
with `d` between 1 and 9, stands for the value of the `d`-th captured substring.
The sequence `%0` stands for the whole match. The sequence `%%` stands for a single `%`.

If `rep` is a table, then the table is queried for every match, using **the first capture** as the key.
If `rep` is a function, then this function is called every time a match occurs,
with **all captured substrings** passed as arguments, in order.

In any case, if the pattern specifies no captures, then it behaves as if the whole pattern was inside a capture.
If the value returned by the table query or by the function call is a string or a number,
then it is used as the replacement string; otherwise, if it is `false` or `nil`, 
then there is no replacement (that is, the original match is kept in the string).

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

### 6.4.1 Patterns

Patterns in Lua are described by regular strings, which are interpreted as patterns by the pattern-matching
functions `string.find`, `string.gmatch`, `string.gsub`, and `string.match`.
This section describes the syntax and the meaning (that is, what they match) of these strings.

**Character Class:**

A *character class* is used to represent a set of characters.
The following combinations are allowed in describing a character class:
- **x:** (where `x` is not one of the *magic characters* ^$()%.[]*+-?) represents the character `x` itself
- **.:** (a dot) represents all characters
- **%a:** represents all letters
- **%c:** represents all control characters
- **%d:** represents all digits
- **%g:** represents all printable characters except space
- **%l:** represents all lowercase characters
- **%p:** represents all punctuation characters
- **%s:** represents all space characters
- **%u:** represents all uppercase characters
- **%w:** represents all alphanumeric characters
- **%x:** represents all hexadecimal digits
- **%**`x`**:** (where `x` is any non-alphanumeric charatcher) represents the character `x`.
  This is the standard way to escape the magic characters.
  Any non-alphanumeric character (including all punctuation characters, even the non-magical)
  can be preceded by a `%` when used to represent itself in a pattern.
- **[set]:** represents the class which is the union of all characters in `set`.
  A range of characters can be specified by separating the end characters of the range,
  in ascending order, with a `-`. All classes described above can also be used as components in `set`.
  All other characters in `set` represent themselves.
  For example, `[%w_]` (or `[_%w]`) represents all alphanumeric characters plus the underscore,
  `[0-7]` represents the octal digits, and `[0-7%l%-]` represents the octal digits plus the lowercase letters 
  plus the `-` character. The interaction between ranges and classes is not defined.
  Therefore, patterns like `[%a-z]` or `[a-%%]` have no meaning.
- **[~set]:** represents the complement of `set`, where `set` is interpreted as above.

For all classes represented by string letters (`%a`, `%c`, etc.),
the corresponding uppercase letter represents the complement of the class.
For instance, `%S` represents all non-space characters.

The definitions of letter, space, and other character groups depend on the current locale.
In particular, the class `[a-z]` may not be equivalent to `%l`.

**Pattern Item:**

A *pattern item* can be
- a single character class, which matches any single character in the class
- a single character class followed by '*', which matches 0 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence
- a single character class followed by '+', which matches 1 or more repetitions of characters in the class.
  These repetition items will always match the longest possible sequence
- a single character class followed by '-', which also matches 0 or more repetitions of characters in the class.
  Unlike '*', these repetition items will always match the shortest possible sequence
- a single character class followed by '?', which matches 0 or 1 occurrence of a character in the class.
  it always matches one occurrence if possible.
- `%n`, for `n` between 1 and 9; such item matches a substring equal to the `n`-th captured string (see below)
- `%bxy`, where `x` and `y` are two distint characters; such item matches strings that start with `x`, end with `y`,
  and where the `x` and `y` are *balanced*. This means that, if one reads the string from left to right, counting
  `+1` for an `x` and `-1` for a `y`, the ending `y` is the first `y` where the count reaches 0.
  For instance, the item `%b()` matches expressions with balanced parentheses.
- `%f[set]`, a *frontier pattern*; such item matches an empty string at any position such that 
  the next character belongs to `set` and the previous character does not belong to `set`.
  The set `set` is interpreted as previously described.
  The begining and the end of the subject are handled as if they were the character `\0`.

**Pattern:**

A *pattern* is a sequence of pattern items. 
A caret `^` at the beginning of a pattern anchors the match at the beginning of the subject string.
A `$` at the end of a pattern anchors the match at the end of the subject string.
At other positions, `^` and `$` have no special meaning and represent themselves.

**Capture:**

A pattern can contain sub-patterns enclosed in parentheses; they describe *capture*.
When a match succeeds, the substrings of the subject string that match captures are stored (*captured) for future use.
Captures are numbered according to their left parentheses.
For instance, in the pattern `(a*(.)%w(%s*))`, 
the part of the string matching `a*(.)%w(%s*)` is stored as the first capture (and therefore has number 1);
the character matching `.` is captured with number 2, and the part matching `%s*` has number 3.

As a special case, the empty capture `()` captures the current string position (a number).
For instance, if we apply the pattern `()aa()` on the string `flaaap`, there will be two captures: 3 and 5.

### 6.4.2 Format Strings for Pack and Unpack

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
- **J:** a `lua_unsigned`
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

(A "[n]" means an optional integral numeral.) Except for padding, spaces, and configurations (options "xX <=>!"),
each option corresponds to an argument (in `string.pack`) or a result (in `string.unpack`).

For options "!n", "sn", "in", and "In", `n` can be any integer between 1 and 16.
All integral options check overflows; `string.pack` checks whether the given value fits in the given size;
`string.unpack` checks whether the read value fits in a Lua integer.

Any format string starts as if prefixed by "!1=", that is, 
with maximum alignment of 1 (no alignment) and native endianness.

Alignment works as follows: For each option, the format gets extra padding until the data starts at an offset
that is a multiple of the minimum between the option size and the maximum alignment; 
this minimum must be a power of 2.
Options "c" and "z" are not aligned; option "s" follows the alignment of its starting integer.

All padding is filled with zeros by `string.pack` (and ignored by `string.unpack`).




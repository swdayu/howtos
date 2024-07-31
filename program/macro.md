
# C语言宏

## 宏定义

```c
#define identifier 
#define identifier replacement-list
#define identifier(parameters) replacement-list
#define identifier(parameters, ...) replacement-list
#define identifier(...) replacement-list
#undef identifier
```

宏可以使用...传入不定个数参数，...只能作为最后一个形参。
在Visual Studio 2013上测试，只能在...形参处传入\_\_VA_ARGS__。
例如下面的例子第3行，会报参数不够的错误，ABCD(\_\_VA_ARGS__)认为只传了一个参数。
但GCC没有这种限制，下面的例子会编译成功。
```c
#define ABCD(a, b, c, d, ...) d
#define EFGH(...) ABCD(__VA_ARGS__)
EFGH(a, b, c, d, e)
```

标准C要求不定参数...必须传入至少一个参数。但是在GCC和VS上都做了扩展。
如果传入0个参数，VS会自动把\_\_VA_ARGS__前面的逗号移除掉；
而GCC则支持这种特殊语法 ## \_\_VA_ARGS__，当参数个数为0时移除前面的逗号。
```c
#define PRINT(fmt, ...) printf(fmt, __VA_ARGS__)
PRINT("string") // VS  => printf("string")
PRINT("string") // GCC => printf("string", ) => error
#define PRINT2(fmt, ...) printf(fmt, ## __VA_ARGS__)
PRINT2("string") // VS => printf("string") VS can support this special ## syntax
PRINT2("string") // GCC=> printf("string")
```

但\_\_VA_ARGS__后面的逗号不会自动移除，因此要传入至少一个参数，如下面的ARGS_N_HELPER。
这种情况在VS中不存在，因为VS只允许在...处传入\_\_VA_ARGS__，...是最后一个参数，
\_\_VA_ARGS__也应该是最后一个，其后不会有逗号。 
```c
#define ARGS_N(...) ARGS_N_HELPER(__VA_ARGS__, arg_end, 4, 3, 2, 1)
#define ARGS_N_HELPER(arg_end, a4, a3, a2, a1, N, ...) N
```

宏如果扩展成多条语句，为避免出错应该用do { ... } while (0)将多条语句包裹起来。
另外宏的每个参数应该都只使用一次，且每个参数都用小括号括起。
```c
#define ABCD() foo(); bar()
if (expr) ABCD(); // unexpected, fine when modify to #define ABCD() do { foo(); bar(); } while (0)
#define CALL(a) (f1(a), f2(a)) // use parameter `a` twice
CALL(foo()) // expanded to: (f1(foo()), f2(foo()), but expected behavior may be `a=foo(), f1(a), f2(a)`
```

**# (stringification)**

> In function-like macros, a # operator before an identifier in the replacement-list 
runs the identifier through parameter replacement and encloses the result in quotes, 
effectively creating a string literal. 
In addition, the preprocessor adds backslashes to escape the quotes surrounding embedded string literals, if any, 
and doubles the backslashes within the string as necessary. 
All leading and trailing whitespace is removed, and any sequence of whitespace in the middle of the text 
(but not inside embedded string literals) is collapsed to a single space. 
This operation is called "stringification". 
If the result of stringification is not a valid string literal, the behavior is undefined.
The order of evaluation of # and ## operators is unspecified.

宏函数中，替换列表中的标识符如果前面带有#操作符，会用传入的参数对其进行替换，
然后用双引号将替换后的结果括起来转换成字符串字面量。
这里的替换只会简单的用传入的参数直接替换，不会对参数中存在的宏进行彻底展开。例如:
```c
#define TOKEN_STRING(a) #a
#define MAX_SIZE 64
TOKEN_STRING(MAX_SIZE) // will produce "MAX_SIZE" not "64"
```
转换成字符串的过程中，预处理器会对引号以及反斜杠进行转义，并且移除开头和末尾的空白，
并将内容内部的空白都压缩到只剩一个空白符（内容内部的内嵌字符串字面量中的空白不会压缩）。
如果转换的结果不是一个合法的字符串字面量，则该操作的行为是未定义的。
如果有一个标志符的前面有#操作，后面有##操作，#和##的操作顺序是未定义的。
```c
#define showlist(...) puts(#__VA_ARGS__)
showlist(1, "x", int); // expands to puts("1, \"x\", int")
```

**## (token pasting)**

> A ## operator between any two successive identifiers in the replacement-list 
runs parameter replacement on the two identifiers and then concatenates the result. 
This operation is called "concatenation" or "token pasting". 
Only tokens that form a valid token together may be pasted: 
identifiers that form a longer identifier, digits that form a number, or operators + and = that form a +=. 
A comment cannot be created by pasting / and * because comments are removed 
from text before macro substitution is considered.
If the result of concatenation is not a valid token, the behavior is undefined.
The resulting token is available for further macro replacement. 
The order of evaluation of ## operators is unspecified.

> Note: some compilers offer an extension that allows ## to appear after a comma and before \_\_VA_ARGS__, 
in which case the ## does nothing when \_\_VA_ARGS__ is non-empty, but removes the comma when \_\_VA_ARGS__ is empty: 
this makes it possible to define macros such as `fprintf(stderr, format, ##__VA_ARGS__)`.

如果替换列表中的两个标志符中间有##操作符，首先会用传入的参数对这两个标志符进行替换，
然后将替换后的结果连接起来形成一个token。这里的替换只会简单的用传入的参数直接替换，不会对参数中存在的宏进行彻底展开。
这种操作称为token粘贴，只有能连接成一个合法的token，这个操作才是合法的。例如将两个标志符拼接成一个更长的标志符；
将数字拼接成一个更长的数值；将+和=拼接成+=等等。不能用将/和*拼接成注释，因为注释在处理宏替换之前已经从代码中移除了。
如果拼接的结果不是一个合法的token，则##操作的行为是未定义的。拼接的结果如果是宏，会像其他宏一样继续进行宏替换。
另外，连续多个##操作的执行顺序是未定义的。

有些编译器如GCC允许##出现在逗号和\_\_VA_ARGS__之间，它允许对变成参数...传入0个参数，
此时\_\_VA_ARGS__前面的逗号会被编译器移除；如果传入的参数不是0个，这个特殊的##操作会被忽略。
这个扩展的操作使得定义这样的宏`fprintf(stderr, format, ##VA_ARGS)`成为可能。

```c
// gcc version of separating first arg and rest args
#define VARGS_FIRSTARG(...) _FIRSTARG_HELPER(__VA_ARGS__, ellipsis)
#define VARGS_RESTARGS(...) _RESTARGS_HELPER_EX(_VARGS_ONE_OR_MORE(__VA_ARGS__), __VA_ARGS__)
#define _FIRSTARG_HELPER(first, ...) first
#define _RESTARGS_OF_ONE1ARG(first) 
#define _RESTARGS_OF_MOREARG(first, ...) , __VA_ARGS__
#define _RESTARGS_HELPER(tail, ...) _RESTARGS_OF_##tail(__VA_ARGS__)
#define _RESTARGS_HELPER_EX(tail, ...) _RESTARGS_HELPER(tail, __VA_ARGS__)
#define _VARGS_MAX8_ARGS(a1, a2, a3, a4, a5, a6, a7, a8, ...) a8
#define _VARGS_MORETOKS6(m) m, m, m, m, m, m  
#define _VARGS_ONE_OR_MORE(...) _VARGS_MAX8_ARGS(__VA_ARGS__, _VARGS_MORETOKS6(MOREARG), ONE1ARG, ellipsis)

// gcc version of counting the number of arguments
#define VARGS_N(...) _VARGS_N_HELPER(0, ## __VA_ARGS__, 5, 4, 3, 2, 1, 0)
#define _VARGS_N_HELPER(a0, a1, a2, a3, a4, a5, N, ...) N
```

> Argument substitution

> After the arguments for the invocation of a function-like macro have been identified, argument substitution takes place. 
A parameter in the replacement list, unless preceded by a # or ## preprocessing token 
or followed by a ## preprocessing token, is replaced by the corresponding argument 
after all macros contained therein have been expanded. 
Before being substituted, each argument’s preprocessing tokens are completely macro replaced 
as if they formed the rest of the preprocessing file; no other preprocessing tokens are available.

当传入宏函数的实参全部鉴别出来，就会进行参数替换。
宏定义替换列表中的形参，如果其前面没有#或##操作符，其后面没有##操作符，
就会用对应实参的彻底展开结果对这个形参进行替换。在替换前，实参中包含的所有宏都被完全展开。
而如果有#或##操作，实参会在展开前进行字符串化或token粘贴操作。
如下面的例子，宏TOKEN_PASTE中形参x和y都没有#和##操作，因此TOKEN_PASTE(ONE, TWO)传入的两个实参会首先进行彻底展开，
ONE会彻底展开成123，TWO会彻底展开成123，然后对形参x和y进行替换得到TOKEN_PASTE_HELPER(123, 123)，
由于TOKEN_PASTE_HELPER中的形参x和y有##操作，会直接进行替换，得到123123。
```c
#define TOKEN_PASTE_HELPER(x, y) x ## y
#define TOKEN_PASTE(x, y) TOKEN_PASTE_HELPER(x, y)
#define ONE 123
#define TWO ONE
TOKEN_PASTE(ONE, TWO)
```

## 条件预处理命令
```c
#if #ifdef #ifndef expression [1] must exist
// code block
#elif expression              [2] none or more
// code block
#else                         [3] none or one
// code block
#endif                        [4] must exist

// valid combination
[1][4]:          #if #endif
[1][3][4]:       #if #else #endif
[1][2]...[3][4]: #if #elif ... #else #endif
[1][2]...[4]:    #if #elif ... #endif

// #if #elif can use logic operators !, && and ||
#if !defined(ABCD) && (EFGH == 0 || !IJKL || defined(MNOP))
#endif

#undef ABCD
#if defined(ABCD)  // false
#if !defined(ABCD) // true
#if (ABCD == 0)    // true - undefined macro evaluates to 0
#if (ABCD)         // fasle
#if (!ABCD)        // true - undefined macro evaluates to 0

const int num = 23;
#define NUM 23
#if (num)          // false - num is not a macro and not a literal, evaluates to 0
#if (num == 0)     // true  - num is not a macro and not a literal, evaluates to 0
#if (NUM)          // true  - NUM is a macro and can evaluate to a integer literal 23
#if (NUM == 0)     // false - NUM is a macro and can evaluate to a integer literal 23
```

**#if, #elif**

> The expression is a constant expression, using only literals and identifiers, defined using #define directive. 
  Any identifier, which is not literal, non defined using #define directive, evaluates to 0.
> The expression may contain unary operators in form `defined identifier` or `defined(identifier)` which return 1 
  if the identifier was defined using #define directive and 0 otherwise.
  If any used identifier is not a constant, it is replaced with 0.

这两个预处理命令后面的表达式必须是常量表达式，只有字面常量和#define定义的名称可以用在这个表达式中。
如果出现的名称不是#define定义的名称，这个名称会被解析成0；如果名称在宏替换后不是字面常量，也会被解析成0。
这两个预处理命令可以使用defined操作符，例如defined identifier或defined(identifier)，含义和#ifdef一样。

**#ifdef, #ifndef**

> Checks if the identifier was defined using #define directive.  
> `#ifdef identifier` is essentially equivalent to `#if defined(identifier)`.  
> `#ifndef identifier` is essentially equivalent to `#if !defined(identifier)`.  

检查对应的名称是否已经定义或没有定义，如果为真，这个名称应该是由#define定义过的名称，并且没有被#undef。
另外#ifdef identifier与#if defined(identifier)等价，#ifndef identifier与#if !defined(identifier)等价。

## 预处理命令line
```c
#line lineno
#line lineno "filename"

#line 123
assert(__LINE__ == 123);
```
> Changes the current preprocessor line number to lineno. 
  Occurrences of the macro \_\_LINE__ beyond this point will expand to lineno plus 
  the number of actual source code lines encountered since.
  It can also change the current preprocessor file name to filename. 
  Occurrences of the macro \_\_FILE__ beyond this point will produce filename.
  Note that: the line number following the directive `#line __LINE__` is implementation-defined.

> This directive is used by some automatic code generation tools which produce C source files from a file written in another language. In that case, #line directives may be inserted in the generated C file referencing line numbers and the file name of the original (human-editable) source file.

可以将当前预处理行号修改成lineno，这个命令之后的\_\_LINE__会以这个行号为基准来表示（这个行号是该命令下一行的行号）。
也可以将当前预处理文件名修改成filename，这个命令之后的\_\_FILE__会用这个文件名表示。
注意的是`#line __LINE__`与编译器实现相关，对应的行号可能是line命令所在行的行号或前一行的行号，应该避免使用。

这个预处理命令可以用在代码自动生成工具中，生成的代码会插入line命令用来表示当前生成的代码对应的源代码的行数。
在处理生成的代码时如果发生错误，处理工具可以将错误发生的地点对应到源代码中的行数，指示出源代码中的错误。

## 预处理命令error
```c
// error_message can consist of several words not necessarily in quotes
#error error_message 

#if MAX_BUFFER_SIZE < 1024
#error "max buffer size too small"
#endif
```

这个预处理命令用于引发一个编译错误，会使编译器停止编译并显示错误消息error_message。
这个error_message是错误信息字符串，可以不用双引号引起。其用法一般是与条件预处理命令一起使用。

## 预定义宏
```c
__STDC__ // the integer constant 1 if the compiler conforms the c standard
__FILE__ // a string literal of current file name
__LINE__ // an integer constant of current line number
__DATE__ // a string literal as form "Mmm dd yyyy"
__TIME__ // a string literal as form "hh:mm:ss"

// a long integer constant to denotes the version of C++ standard the compiler used: 
// 199711L(until C++11), 201103L(C++11), or 201402L(C++14) 
__cplusplus // note that c++ may has __STDC__ equal to 1 if the compiler also conforms the c standard
```

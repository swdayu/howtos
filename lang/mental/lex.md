
## 匹配语法
```c
=== Regex (Regular Expression)
 1. .   点号匹配除换行符(\n)之外的任意单一字符
 2. ^   匹配行首
 3. $   匹配行尾
 4. *   匹配0个或多个
 5. +   匹配1个或多个
 6. ?   匹配0个或1个
 7. |   只要匹配其中之一即匹配成功，例如"a"|"bc"
 8. ()  将匹配表达式组合成一个新的表达式
 9. {n} {n,m} {n,} 匹配n个、n个到m个，大于等于n个，例如("a"|"bc"){8}
10. /   匹配斜杠之前的表达式，但是要求之后的字符串也要匹配斜杠之后的表达式，如"0"/"1"匹配"01"中的0，但不匹配"02"中的0
11. "abc" 匹配对应的字符串
12. ```abc\t\u0A1F``` 匹配对应的原始(没有进行转义的)字符串
13. {Expr} 匹配对应名称的表达式 
14. 字符集合：['0-9' 'a' '\t' '\u0A1F' '\'' ']' '[' '.'] [^ '0' 'A-Z' '^']
15. 字符差集：[]{-}[]，可扩展到表达式匹配差集？{Expr1 - Expr2}
16. 字符并集：[]{+}[]，可扩展到表达式匹配并集？{Expr1 + Expr2}

*每个模式只允许一个尾部上下文操作符，而且一个模式不能既有斜线又有尾部的$
*二义性处理：使用贪婪法尽可能多的匹配输入串；先定义的优先匹配，例如"+"和"+="；

=== Peg (Parsing Expression Grammars)
n: 匹配n个字符
"abc": 匹配字符a和b和c
Before(Expr): 当前位置之前匹配表达式Expr，不消耗字符
Range("az"), Range("az", "09", "AA", "BC"): 字符范围
Set("abc*/+"): 匹配其中的单一字符
#Expr: 当前位置之后匹配Expr，不消耗字符
-Expr: 只要当不匹配Expr是才匹配成功
Expr1+Expr2: 匹配其中一个表达式即匹配成功
Expr1-Expr2: 只要当不匹配Expr2但匹配Expr1时才匹配成功
Expr1*Expr2: 匹配Expr1并且匹配Expr2是才匹配成功
Expr^n: 匹配n个或多个Expr1

```

```c
KW_BOOL:    "bool"
KW_CHAR:    "char"
KW_BYTE:    "byte"
KW_INT8:    "int8"
KW_UINT16:  "uint16"
KW_INT16:   "int16"
KW_UINT32:  "uint32"
KW_INT32:   "int32"
KW_UINT64:  "uint64"
KW_INT64:   "int64"
KW_UINT:    "uint"
KW_INT:     "int"
KW_IPTR:    "iptr"
KW_UPTR:    "uptr"
KW_FLOAT:   "float"
KW_DOUBLE:  "double"
KW_STRING:  "string"

KW_TRUE:    "true"
KW_FALSE:   "false"
//char literal
//int literal
//float literal
//string literal

"var"
"struct"
"class"
"enum"
"func"
"module"
"using"
"typedef"


"{"
"}"
"["
"]"
"("
")"
"="
","

AT_PARAM: "@"{IDENTIFY}
DL_PARAM: "$"{NUMBER}
```

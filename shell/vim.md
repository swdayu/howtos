
## Basic
```shell
INSERT - change to insert mode
ESC - exit from editor mode to command mode

:q   - quit without save
:wq  - save and then quit
:wq! - force overwrite and quit

: LINE_NUMBER ENTER
/ STRING_TO_SEARCH ENTER - first match after cursor
? STRING_TO_SEARCH ENTER - first match before cursor
n - next match
N - prev match
```

## Skills

```c
x   删除光标下的字符
.   重复上一次操作，这里再次删除光标下的字符
u   撤销上一次操作
u   撤销上上一次操作，这里文本将复原

dd  删除光标所在行
.   重复上一次操作，这里再次删除光标所在行
uu  撤销上述操作

>G  增加从当前行到文档末尾的缩进层次
>gg 增加从文档开头到当前行的缩进层次

$         光标移到行尾
a;<ESC>   在当前光标之后添加一个分号，并退出插入模式
j$.       光标下移一行，并移到到行尾，重复上一次操作

A;<ESC>   其中A相当于$a，这里在当前行尾添加一个分号，并退出插入模式
j.        光标下移一行，重复上一次操作，即在行尾添加一个分号并退出插入模式

f+        在当前行查找下一个加号，并将光标移动到+字符上
s + <ESC> 删除当前字符并进入插入模式，添加一个空格一个加号和一个空格，退出插入模式
;.        正向继续上一次查找（使用,可以反向查找），并重复上一次操作

:set hls       可以打开高亮显示
*              查找当前光标所在位置的单词
cw[word]<ESC>  删除当前单词光标位置到单词结尾间的字符，并输入替换的单词，然后退出插入模式
n.             查找下一个单词，并执行上述替换操作

o<ESC>    在当前行行尾添加一个换行，并退出插入模式
h j k l   将光标向左、向下、向上、向右移动一位
```

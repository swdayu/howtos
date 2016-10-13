
# vim

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

comment/uncomment multiple lines
```shell
<c-v>   # enter visual block mode
j       # select multiple lines
I       # enter insert mode
//      # input the comment characters
ESC     # finish

<c-v>   # enter visual block mode
j and k # select multiple lines and columns
d       # delete comments
```

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

[理想模式：用一键移动，另一键执行]
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

b         将光标移动到当前单词的第一个字符上
dw        删除光标位置到下一个单词开头的内容
daw       可以理解为delet a word

yyp       复制当前行并将复制的内容插入当前行之下
cw        删除单词当前光标位置到单词末尾的字符，并进入插入模式
<c-a>     将当前行光标所在的数字或下一个数字加1
<c-x>     将当前行光标所在的数字或下一个数字减1
180<c-x>  将当前行光标所在的数字或下一个数字减180

c3wsome more<ESC> 进入插入模式删除3个单词，并输入some more，然后退出插入模式
d3w               删除3个单词（或者3dw）

[操作符 + 动作命令 = 操作]
:h operator 查看所有操作符
c{motion}    cl 删除当前字符 cw 删除单词光标之后的字符 caw 删除整个单词 cap 删除段落 cc 删除当前行 => 并保留在插入模式
d{motion}    dl 删除当前字符 dw 删除单词光标之后的字符 daw 删除整个单词 dap 删除段落 dd 重复作用于当前行
gu{motion}   gul guaw guap 转换成小写 gugu guu 作用于当前行
gU{motion}   gUl gUaw gUap 转换成大写 gUgU gUU 作用于当前行
g~{motion}   g~l g~aw g~ap 大小变小大 g~g~ g~~ 作用于当前行
>{motion}    >ap >> 增加缩进
<{motion}    <ap << 减少缩进
={motion}    =ap == 自动缩进

:h :map-operator
:h omap-info

[插入模式]
<c-h> 删除前一个字符
<c-w> 删除前一个单词
<c-u> 删除至行首

<c-o>zz 插入模式下使用<c-o>可临时进入普通模式，然后执行一个普通模式命令后返回插入模式 

```

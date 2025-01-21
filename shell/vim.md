VIM编辑器

http://vimdoc.sourceforge.net/
https://www.fprintf.net/vimCheatSheet.html

```
* 普通模式（normal mode）
* h/j/k/l       向左/下/上/右移动一个位置
* H             移动到屏幕最上面一行开头
* M             移动到屏幕最中间一行开头
* L             移动到屏幕最下面一行开头
* zt            将当前行移动到屏幕第一行
* zz            将当前行移动到屏幕最中央
* zb            将当前行移动到屏幕最下一行
* N<enter>      向下移动N行
* N+            向下移动N行
* N-            向上移动N行
* gg            移动到第一行开头
* G             移动到最后一行开头
* CTRL+f        移动到下一页
* CTRL+b        移动到上一页
* CTRL+d        向下移动半页
* CTRL+u        向上移动半页
* m<char>       用一个字符标记当前行
* '<char>       跳转到对应字符标记的行开头
* `<char>       跳转到对应字符标记所在行和列
* b             移动到当前单词开头字符，如果已在开头字符，移动到前一个单词的开头字符
* e             移动到当前单词结束字符，如果已在结束字符，移动到后一个单词的结束字符
* w             移动到下一个单词的开头字符
* ge            移动到上一个单词的结尾字符
* %             移动到下一个括号对的结束括号
* b/e/w/ge      基于单词移动位置
* B/E/W/gE      基于字串移动位置
* 0             移动到当前行开头字符
* $             移动到当前行结束字符
* ^             移动到当前行第一个非空白字符
* g_            移动到当前行最后一个非空白字符
* ga            查看当前字符的字符编码
* j/k/0/^/$     基于实际行移动位置
* gj|gk/g0/g^/g$   基于屏幕行移动位置
* f             在当前行查找一个字符并移动到该字符，用逗号(,)查找前一个，用分号(;)查找后一个
* t             在当前行查找一个字符并移动到该字符的前一个字符上
* F/T           在当前行反方向查找一个字符并移动
* *             查找当前单词的下一位置，并移动到该位置单词的开头字符，使用n查找下一个，N查找上一个
* #             查找当前单词的上一个位置
* x             删除当前字符并保持在普通模式
* X             删除前一个字符并保持在普通模式
* r{char}       替换当前字符
* gu            转换成小写
* gU            转换成大写
* u             撤销上一个修改
* CTRL+r        重做下一个修改
* yy            复制当前行
* p             将内容粘贴到下一行
* P             将内容粘贴到上一行
* dd            删除当前行
* .             在当前位置重复上一次在插入模式中的操作，但在插入模式中移动光标会重置修改状态
* i             进入插入模式，插入的字符会在当前字符之前
* I             进入插入模式，并移动到当前行首，相当于^i
* a             进入插入模式，并移动到当前字符之后
* A             进入插入模式，并移动到当前行尾，相当于$a
* o             进入插入模式，并移动到当前行尾，插入一个换行
* O             进入插入模式，并移动到当前行首，插入一个换行
* C             删除当前字符以及到行尾的所有字符，最终处于插入模式
* D             删除当前字符以及到行尾的所有字符，最终处于普通模式
* 插入模式（insert mode）
* CTRL+w        删除前一个单词
* CTRL+u        删除至行首
* CTRL+o        退出插入模式执行一条普通模式命令并返回插入模式
* CTRL+r0       粘贴当前寄存器的内容
* CTRL+r=3*4    插入一个计算结果
* 可视模式（visual mode）
* v             从普通模式进入字符可视模式，可以使用h/j/k/l/b/e等进行选取
* V             行模式
* CTRL+v        列模式
* o             切换到当前选取块的开头字符或结束字符
* 命令模式（command mode）
* :N            移动到第N行开头
* :$            移动到最后一行开头
* :!shell       执行shell命令
* :ls           列出VIM当前管理的所有文件缓冲区，其中标有%的文件是当前可见的文件
* :bnext        切换到下一个文件
* :bprev        切换到上一个文件
* :bfirst       切换到第一个文件
* :blast        切换到最后一个文件
* :bN           切换到第N个文件
* :b name       切换到包含名称的文件，可用TAB补全
* :bd N1 N2 N3  移除缓冲区中的文件
* :N,M bd       通过范围移除缓冲区中的文件
* :args         显示VIM当前的文件参数列表，参数列表可用于将缓冲区文件分组
* :args file    清空并重置参数列表，没有在文件缓冲区的文件会加到缓冲区
* :args `shell` 用shell命令返回的文件重置参数列表
* :args *.*     用批量文件重置参数列表，不会递归子目录
* :args **/*.*  通配符**会递归子目录
* :next         切换到参数列表的下一个文件
* :prev         切换到参数列表的下一个文件
* :first        第一个文件
* :last         最后一个文件
* :tabe file    在新标签页中打开文件
* :tabc[lose]   关闭当前标签页和其中的所有窗口
* :tabo[nly]    关闭其他所有标签页
* :tabn         切换到下一个标签页
* :tabp         切换到上一个标签页
* :tabnN        切换到第N个标签页
* :tabm0        将当前标签页移动到开头
* :tabm[ove]    将当前标签页移动到结尾
* :tabmN        将当前标签页移动到第N位置
* CTRL+ws       水平分割窗口，CTRL+w然后按s，不是一直按着CTRL，CTRL+s是锁屏命令会导致VIM假死，按CTRL+q解锁恢复
* CTRL+wv       垂直分割窗口
* CTRL+ww       循环切换窗口
* CTRL+w[hjkl]  切换到对应方向的窗口
* CTRL+g        查看文件状态
* :sp[lit] file 水平切分当前窗口并载入文件，相当于CTRL+ws然后：edit file
* :vsp[lit] fl  垂直切分当前窗口并载入文件
* :clo[se]      关闭当前窗口
* :on[ly]       关闭其他所有窗口
* :w            把缓冲区中的内容写入文件
* :wa!          把所有缓冲区中的内容写入文件
* :e!           重新读取文件到缓冲区，即回滚所有操作
* :qa!          关闭所有窗口，摒弃所有修改
* :saveas file  文件另存为
* :e file       在当前窗口载入新文件
* :e .          打开文件管理器，并显示当前目录文件
* :E            打开文件管理器，并显示活动缓冲区所在目录
* :Se           在水平窗口中打开文件管理器
* :Ve           在垂直窗口中打开文件管理器
* CTRL+^        
* :set nu       显示行号
* :set nonu     取消行号
* :Nt.          将第N行的内容拷贝到当前行之下
* :t.           将当前行的内容拷贝到当前行之下
* :NtM          将第N行的内容拷贝到第M行之下
* :N,MtL        将范围内的行或高亮选取的内容拷贝到第L行之下
* :NmM          将第N行的内容剪切到第M行之下
* :N,MmL        将范围内的行或高亮选取的内容剪切到第L行之下
* :normal cmd   执行普通模式下的命令
CTAGS和代码提示
$ sudo apt-get install exuberant-ctags
$ ctags --help  #检查ctags是否安装成功
$ ctags -R --languages=c --langmap=c:+.h -h +.h  #生成当前目录下所有C文件的标签文件tags
* :set tags?    查看VIM当前关联tags文件
* :set tags=... 设置VIM当前关联的tags文件，排在前面的tags文件优先级高
* :set tags+=.. 添加VIM当前关联的tags文件，排在前面的tags文件优先级高
* :set omnifunc=ccomplete#Complete
* CTRL+]        跳转到当前光标关键字的定义处
* gCTRL+]       如果有多个匹配位置，会提供选择跳转到哪个匹配处
* CTRL+t        回到上一个跳转处或回到最初位置
* :pop          反向遍历标签历史，相当于CTRL+t
* :tag          正向遍历标签历史
* :tselect      如果匹配不止一个，这个命令可查看匹配列表，并进行选择
* :tnext        跳转到下一个匹配位置
* :tprev        跳转到上一个匹配位置
* :tfirst       跳转到第一个匹配位置
* :tlast        跳转到最后一个匹配位置
* :tag keyword  无需移动光标版的CTRL+]，在输入keyword时，可以使用TAB键进行自动补全
* :tjump word   无需移动光标版的gCTRL+]
* :tag /phone$  关键字可以使用正则表达式，例如此处查找以phone结尾的关键字定义位置
* CTRL+n/CTRL+p 普通关键字补全，显示提示列表，同时有向下/下选择功能
* CTRL+xCTRL+n  当前缓冲区关键字补全
* CTRL+xCTRL+i  包含文件关键字补全
* CTRL+xCTRL+]  标签关键字补全
* CTRL+xCTRL+f  文件名补全
* CTRL+xCTRL+l  整行补全
* CTRL+xCTRL+k  字典补全
* CTRL+xCTRL+o  全能（Omni）补全，C语言可以补全结构体成员名称
* CTRL+e        放弃这次补全
VIM上可直接执行的SHELL命令
* :pwd :grep :make
* :vimgrep keyword **/*.c **/*.h   在当前以及所有子目录的.c和.h文件中查找keyword
* :copen        打开quickfix窗口,如果在某一项按Enter会打开对应的文件，如果这个文件已在某个窗口中打开，则会复用这个缓冲区
* :cclose       关闭quickfix窗口
* :colder       上一次quickfix结果
* :cnewer       新一次quickfix结果
* :cnext        跳转到quickfix列表的下一项，这个命令如此的常用，可将它映射成快捷键
* :cprev        跳转到quickfix列表的上一项
* :5cnext　　　　快速前进
* :5cprev       快速后退
* :cfirst       第一项
* :clast        最后一项
* :cnfile       下一个文件的第一项
* :cpfile       上一个文件的最后一项
* :cc N         跳转到第N项
* :lmake :lgrep :lvimgrep  会使用位置列表，区别在于在任意时刻，只能有一个quickfix列表，而位置列表要多少有多少
重复
* qa            开启一个宏录制命令序列，这个宏保存在寄存器a中
* q             停止录制
* :reg a        查看寄存器a中宏的内容
* @a            回放命令序列
* @@            回放上一次序列
* qA            追加命令到宏a中

---

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

comment/uncomment multiple lines
<c-v>   # enter visual block mode
j       # select multiple lines
I       # enter insert mode
//      # input the comment characters
ESC     # finish

<c-v>   # enter visual block mode
j and k # select multiple lines and columns
d       # delete comments

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

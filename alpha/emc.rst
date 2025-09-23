https://www.gnu.org/software/emacs/manual/html_mono/emacs.html
https://www.gnu.org/software/emacs/manual/html_mono/elisp.html
https://pavinberg.github.io/emacs-book/zh/


Emacs版本

- Emacs-gtk 使用 GTK 图形库的版本
- Emacs-lucid 是由Ubuntu特别调整的版本，主要用于Ubuntu系统。它提供了更好的兼容性和
  性能优化，特别是在图形界面方面‌
- emacs-nox 是不带 x system 的 emacs 版本，这个版本不包含图形界面支持，主要用于没有
  图形界面的环境，如服务器或终端。它专注于文本模式下的操作，适合那些主要在命令行环境下
  工作的用户‌

Emacs启动： ::

    emacs           # 正常启动
    emacs -nw       # 不带图形界面
    emacs file.txt  # 打开一个文件

Emacs键位： ::

    C-<key>     CTRL+<key>
    M-<key>     META/EDIT/ALT+<key>，如果没有这三个键可以等效使用按一下 ESC 键放开
                再输入 <key>

    C-x C-c     退出Emacs
    C-g         取消当前输入的命令，或当前执行过久的，或失去响应的命令；例如取消重复
                前缀或ESC键或输入一半的命令，特殊的可以连按两次ESC取消ESC

    C-v         查看下一屏文字，也可以使用PageDn
    M-v         上一屏，也可以使用PageUp
    C-l         重绘屏幕，将光标所在行置于屏幕的中央，再次置于顶部，再次置于底部
    C-p         上一行（previous），相当于上方向键
    C-n         下一行（next），相当于下方向键

    C-b         向左移（backword），相当于左方向键
    C-f         向右移（forward），相当于右方向键
    M-b         后退到当前词汇的开头，词在英文表示单词，中文表示空格或标点分隔内容
    M-f         移动到当前词汇的末尾

    C-a         一行的开头
    C-e         一行的结尾
    M-a         一句的开头，英文句号或中文句号分隔的内容
    M-e         一句的结尾
    M-Shift-<   文件开头
    M-Shift->   文件结尾
    M-g M-g 8   跳转到第8行

    C-u 8       重复前缀，或者使用 M-8
    C-u 8 C-v   特殊的C-v，是整个屏幕向下移动8行，相当于屏幕滚动，等价于滚动条的操作
    C-u 8 M-v   整个屏幕向上移动8行，相当于屏幕滚动，例如鼠标滚轮或拖动滚动条
    C-u 8 C-l   重绘屏幕，将光标所在行置于顶部位置，该位置所在行到顶部间距8行
    C-7 8 *     输入8个*字符

    <DEL>       删除光标左边的一个字符，即退格Backspace
    M-<DEL>     删除光标左边的一个词汇
    C-d         删除（delete）光标右边的一个字符
    M-d         删除（delete）光标右边的一个词汇
    C-k         移除（kill）到行尾
    M-k         移除（kill）到句尾
    C-w         移除（kill）选中的内容，先用C-<SPC>并移动光标选中内容，然后按C-w移除
                所选内容，由于中文输入法快捷键的冲突可以使用C-@代替
    M-w         复制所选内容
    C-y         召回（yanking）最近一次移除（kill）的内容，如果有多次C-k，按C-y
                会一次性召回，如果重复按C-y相当于复制最近移除的内容
    M-y         召回前一次移除的内容，再按召回前前次，最后是最近一次移除的内容

    C-/         撤销（undo）前一个命令造成的改变，只对改变文字的命令有效，如果是从键
                盘输入文字会以组为单位，每组最多20个字符，这是为了减少撤销插入文字动
                作时需要输入的C-/的次数。该命令还可以写作C-_（在某些终端上可以不按
                shift键，即C--），或者C-x u。
    C-g C-/     撤销之后，可以按C-g改变撤销的方向，相当于重做（redo），当所有的都重
                做之后，它又会自动改变方向进行撤销（undo）



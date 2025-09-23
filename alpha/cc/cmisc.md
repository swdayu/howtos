# C Language
- http://www.cplusplus.com/reference/clibrary/
- http://en.cppreference.com/w/c

# 整数陷阱

下面的例子在Visual Studio中编译会报C4146错误，是因为-2147483648会分成两步进行解析：
第一步先读取2147483648，但这个数不能用32位有符号数表示，因为它的最大值只能表示2147483647，因此这个值被转换成无符号数；
然后对这个无符号数进行取负，但是对无符号数进行取负是没有意义的，因为无符号数本身没有符号，因而会报错。
避免这个错误的方法是将-2147483648写成(-2147483647 - 1)，或使用limits.h头文件中定义的INT_MIN。

```c
//error C4146: unary minus operator applied to unsigned type, result still unsigned
//modify to `a = -2147483647 - 1` to avoid this error
int32_t a = -2147483648; // 2147483648 is not int (max 2147483647) but unsigned
```

> Unsigned types can hold only non-negative values, 
so unary minus (negation) does not usually make sense when applied to an unsigned type. 
Both the operand and the result are non-negative.
Practically, this occurs when the programmer is trying to express the minimum integer value, which is -2147483648. 
This value cannot be written as -2147483648 because the expression is processed in two stages:
The number 2147483648 is evaluated. 
Because it is greater than the maximum integer value of 2147483647, 
the type of 2147483648 is not int, but unsigned int.
Unary minus is applied to the value, with an unsigned result, which also happens to be 2147483648.

> The example program below prints just one line.
The expected second line, 1 is greater than the most negative int, 
is not printed because ((unsigned int)1) > 2147483648 is false.
You can avoid C4146 by using INT_MIN from limits.h, which has the type signed int.

另外如果使用-2147483648与其他值进行比较，可能会导致不预期的错误。
因为2147483648是一个无符号数，然后对这个无符号数取负，其结果还是无符号数，这个值恰好是2147483648。
如果两个操作数中有一个是无符号数，另外一个操作数首先会被转换成无符号数，再进行运算。
因此下面的例子中只有(-5 > -2147483648)是符合预期的，它相当于(0xFFFFFFB > 0x80000000)；
而(1 > -2147483648)不成立，因为1要比0x80000000小，导致不预期的结果。

```c
// this sample will generate C4146 error when compile with /W2
void check(int i) {
  if (i > -2147483648) { // unsigned value of -2147483648 is 0x80000000
    printf("%d is greater than the most negative int\n", i);
  }
}
int main() {
  // easy found that unsigned value of -5 is larger than 0x80000000, and 0x80000000 is large than 1 
  check(-5); check(1);
}
//0x00000000 -> (0x00000001) -> 0x7FFFFFFF  0x80000000 -> (0xFFFFFFB)   -> 0xFFFFFFFF
//0          ->      (1)     -> 2147483647 -2147483648 ->   (-5)        -> -1
```

有符号数如果在正数方向溢出会变成负数（下面例子中的a），
如果在负数方向溢出会变成正数（下面例子中的b）。

```c
int32_t a = 2147483647; // 0x7FFFFFFF: max value of int32_t
a = a + 1;              // 0x80000000: become min value of int32_t -2147483648
int32_t b = -2147483647 - 1; // 0x80000000: min value of int32_t
b = b - 1;                   // 0x7FFFFFFF: become max value of int32_t 2147483647
```

无符号数与有符号数进行运算，有符号数会被转换成无符号数，可能会导致不预期的错误。
如下面例子中`1 - 3`会变成一个很大的正数，导致`1 - 3 < 0`不成立。
```c
unsigned int a = 1;
int b = 3;
if (a - b < 0) {
  printf("1 < 3");
}
```

无符号整数的使用，还可能会导致意外的无限循环，如下面的例子。
因为无符号数大于等于0永远都成立，for循环永远都不会结束。
```c
unsigned int a = 0;
for (a = 10; a >= 0; --a) {
  // do something according to `a`
}
```

# 条件陷阱

注意负数的条件为真，非零整数的条件都为真
```c
int i = -1
if (i) {
  printf("%d is true\n", i);
}
```

C
```
编译环境
* MAKE 文件主要由一系列构建规则组成，每个构建规则分为三部分：工作目标（target），工作目标的必要条件（prerequisite）和需要执行的命令（command）
* 工作目标是一个必须建造的文件或进行的事情，必要条件是工作目标成功创建之前必须事先存在的文件，而命令是必要条件成立时创建工作目标需要执行的SHELL命令
* 链接库可以作为目标的必要条件，例如 count: count.c -lfl，当查找链接库 -l<NAME> 时 make 会依次搜素 libNAME.so 和 libNAME.a 形式的库文件
* 在执行一个工作目标时，会先检查目标的必要条件，如果有文件不存在会搜寻合适的目标创建这个文件，当所有必要文件都存在后就执行命令创建工作目标
* 工作目标不会更新的唯一情况是：目标文件和必要条件中的文件都已经存在，且目标文件时间戳比所有必要文件的时间戳都要新；另外每条命令会在单独的SHELL中运行
* MAKE 文件的第一个工作目标称为默认工作目标，当执行 make 时不指定工作目标，则执行的是默认工作目标
* MAKE 提供了很多命令行选项，其中一个有用的选项是 --just-print 或 -n，该选项使 make 仅显示而不执行工作目标的命令，该功能在编写 MAKE 文件时特别有用
* 一条构建规则的一般形式如下，其中目标可以有0个或多个必要条件，当必要条件为0时对应的命令仅在目标文件不存在时执行，另外多个目标可以共享相同的必要条件和命令
* 需要执行的命令也可以是0个或多个，如果命令为0个表示这个工作目标仅依赖于必要条件，如果必要条件也为空，则这是一个空目标
* target1 target2 target3: prerequisite1 prerequisite2
* <tab> command1
* <tab> command2
* <tab> command3
* 工作目标的必要条件如果很多可以分多次书写，第一次之后指定的必要条件会追加到原来工作目标的必要条件中，例如：
* vpath.o: lexer.c hash.h commands.h filedef.h job.h dep.h
* vpath.o: vpath.c make.h config.h getopt.h gettext.h vpath.h
* <tab> $(CC) $(CFLAGS) -o $@ -c $<
* 模式规则的一般形式如下所示，它们常用于说明某类文件如何生成，例如下面目标文件以及两种可执行文件的生成规则：
* %.o: %.c
* <tab> $(CC) $(CFLAGS) -o $@ -c $<
* %: %.c
* <tab> $(LINK) $^ $(LDFLAGS) $(LDFLAGS) -o $@
* %: %.mod
* <tab> $(CLMOD) -o $@ -e $@ $^
* 模式规则中的百分号 % 可以替代任意多字符，百分号可以放在模式串任何位置但只能出现一次，例如 %,v s%.o wrapper_%
* 当 MAKE 需要使用模式规则生成某类文件时，它会查找相符的模式规则的工作目标，并以匹配百分号的字符串替换到必要条件中以得到具体规则
* 另外还有静态模式规则能应用在特定的工作目标上，例如下面例子中 %.o 只会使用 $(OBJECTS) 中的目标文件进行替换：
* $(OBJECTS): %.o: %.c
* <tab> $(CC) -c $(CFLAGS) $< -o$@
* MAKE 定义了很多隐含规则，这些规则不是模式规则就是老式的后缀规则，这些内置规则可应用于各种类型的文件，可以通过 make -p 查看这些规则
* 当 make 检查一个工作目标时如果找不到可以更新它的具体规则，就会使用隐含规则，隐含规则很容易使用，当编写自己的具体规则时不指定执行命令就行了
* 另外一个没有指定命令脚本的模式规则会将对应的 MAKE 隐含规则删除，例如 %.c: %.l 会删除从 .l 文件生成 .c 文件的隐含规则
* 当链接器连接目标文件或库时，会依次搜索命令行上指定的文件，如果库A包含了一个未定义的符号而且该符号定义在库B中，那么就必须在B之前指定A
* 否则一旦链接器读进A发现未定义的符号再要链接器回头就迟了，因为链接器不会回头再读取前面的程序库，因此命令行上库的指定顺序相当重要
* 一个相关的问题是程序库之间的相互引用或循环引用，此时需要在命令行指定一个程序库两次以解决依赖问题，例如 -lA -lB -lA，下面是一个示例：
* xpong: xpong.o libui.a libdynamics.a libui.a -lX11
* <tab> $(CC) $+ -o $@  # 这里使用了 $+，它不会删除重复的文件以确保连接操作的正确执行
* MAKE 变量的值由赋值符号右边已删除前导空格的所有字符组成，但值尾部空格不会删除；变量有简单扩展（使用 := 赋值）和递归扩展（使用 = 赋值）两种类型
* 简单扩展的含义是变量的值会在定义时立即进行扩展，此方式下赋值时引用的变量必须都已经定义，未定义的变量会扩展成空字符串
* 递归扩展变量在定义时对应的值不立即进行扩展（只简单记住所有字符）而是延迟到变量使用时，这种扩展不会影响简单的字符串赋值，因为这些值不需要扩展
* 另外两个赋值操作符是 += 和 ?=，第一个操作符 += 用于为变量追加新值，而 ?= 仅在变量的值尚未设定（即使设置为空也表示已经设定）时才对变量赋值
* 变量可以用来存储单行字符串，如果要保存多行字符串（例如多行命令）则需要使用宏，通过 define 命令定义的变量称为宏，宏可以包含内置的换行符，例如：
* define create-jar
*   @echo creating $@...
*   $(JAR) -ufm $@ $(MANIFEST)
* endef # 然后宏可以像普通变量那样使用
* 总体来说，赋值符左边部分的变量名会立即扩展，:= 赋值符的右边部分也会立即扩展，而 = 和 ?= 右边部分会等到执行时扩展
* 而 += 赋值符如果左边变量原本是一个简单扩展变量则右边部分会立即扩展，否则延迟到执行时；而对于宏定义，变量名会立即扩展，主体部分会延迟到执行时
* 对于规则，工作目标和必要条件都会立即扩展，而命令则会延迟到执行时；一个准则是尽量先定义变量和宏再使用它们，尤其是在工作目标和必要条件中使用变量时
* 一个重要特性是变量可以在目标的必要条件中赋值，此种赋值仅在工作目标以及相应的任何必要条件需要处理时才执行，且工作目标处理完后变量会恢复其原有值
* gui.o: CPPFLAGS += -DUSE_NEW_MALLOC=1
* gui.o: gui.cpp gui.h
* 另外，使用 vpath 命令可以告诉 MAKE 怎样搜索文件，例如 vpath %.l %.c src 表示在当前 src 目录中搜索 .l 和 .c 文件
* MAKE 还定义了一些默认变量，它们可以获取工作目标以及必要条件中的元素，例如 $@ 表示当前工作目标文件名，$< 表示第一个必要条件的文件名
* $^ 表示所有必要条件的文件名，中间用空格隔开，这份列表删除了重复的文件名，而 $+ 与 $^ 相同只是没有删除重复文件名
* $? 表示时间戳在工作目标时间戳之后的所有必要条件文件名，$* 表示去除文件名后缀的工作目标文件名（但注意是如果文件名没有以.开始的后缀，该变量返回空）
* 这些变量都是单字符变量，在引用时可以不必使用括号，而这些变量的变体需要使用括号，例如 $(@D)、$(<D) 等表示目录部分，$(@F) 等表示文件部分
* 变量可以通过 include 来源于其他文件，也可以在命令行为 make 指定选项重新定义变量，例如：
* make CFLAGS=-g CPPGLAGS="-DBSD -DDEBUG"  # 命令行上定义的变量会覆盖环境变量以及 MAKE 文件中的赋值结果
* 为了避免被命令行的变量覆盖，MAKE 文件中的变量可以使用 override 命令来定义，例如 override LDFLAGS = -EB # 使用 big endian
* 在 make 启动时，所有来自于环境的变量都会自动定义成 make 变量，这些变量具有最低的优先级，所有 MAKE 文件或命令行的赋值都会覆盖环境变量的值
* 当使用条件处理指令时，MAKE 文件根据条件处理结果有些部分会选中而有些部分会被省略，用来控制是否选择的条件具有各种形式：ifdef/ifndef/ifeq/ifneq
* 当使用 ifdef/ifndef 时不需要使用 $() 括住变量名，而使用 ifeq/ifneq 时测试表达式的形式为 "a" "b" 或 (a, b)
* 采用 (a, b) 的形式时必须注意括号内的空格，因为在解析时除了逗号之后的空格会删除外，其他空格都会保留作为变量值的一部分
* 为了创建更稳定的 MAKE 文件，可以使用引号形式的测试表达式，还可以使用 strip 函数手动去除空格，例如：
* ifeq "$(strip $(OPTION))" "-d"
*   CFLAGS += -DDEBUG
* endif
* 条件处理指令可以在 MAKE 文件顶层使用，也可以用在宏定义以及目标命令中使用，例如：
* libgui.a: $(gui_objects)
* <tab> $(AR) $(ARFLAGS) $@ $<
*   ifdef RANLIB
* <tab> $(RANLIB) $@
*   endif
* 注意条件处理指令只有 if-cond endif 和 if-cond else endif 两种形式，没有对应 else-if-cond 的命令，但可以使用嵌套的条件指令实现
* 另外在 MAKE 文件中还可以直接使用的变量有 MAKE_VERSION、CURDIR、MAKEFILE_LIST、.VARIABLES 等
* GCC -E 输出预处理后的源代码，-S 输出编译后的汇编代码，-c 输出汇编后的目标代码，不带选项输出链接后的可执行文件，都可通过 -o 指定输出文件名
WINDOWS环境
* MSYS2下载和安装：https://sourceforge.net/p/msys2/wiki/MSYS2%20installation/
* 安装WINDOWS SDK: https://www.microsoft.com/en-us/download/details.aspx?id=8279
* WINDOWS SDK安装的默认路径为：C:\Program Files\Microsoft SDKs\Windows\v7.1
* WINDOWS SDK帮助文档：C:\Program Files\Microsoft SDKs\Windows\v7.1\ReleaseNotes.Htm
* NMAKE参考：https://msdn.microsoft.com/en-us/library/dd9y37ha.aspx
* 工作目标可以指定一个或多个，它们可以是文件名、目录名、或伪目标（不真实存在），目标之间可以用一个或多个空格或tab隔开，但第一个目标必须顶格开始
* 目标包含的字符不区分大小写，字符的最大长度不能超过256个，如果冒号之前的目标是一个单独的字符，需要在字符与冒号之间加空格，避免解析成盘符
* 相同目标的依赖条件会按顺序合并到一起，例如：
* bounce.exe: jump.obj
* bounce.exe: up.obj
* <tab> echo building bounce.exe...
* 相当于：
* bounce.exe: jump.obj up.obj
* <tab> echo building bounce.exe...
* 多个目标共享相同的依赖条件相当于用相同的依赖条件单独定义，而命令部分只属于当前规则中的目标
* leap.exe bounce.exe: jump.obj
* bounce.exe climb.exe: up.obj
* <tab> building bounce.exe...
* 相当于：
* leap.exe: jump.obj　# 目标 leap 没有命令部分
* bounce.exe: jump.obj up.obj
* <tab> building bounce.exe...
* climb.exe: up.obj
* <tab> building bounce.exe...
* 依赖条件在工作目标之后以冒号（:）分隔，依赖条件可以有0个或多个且不区分大小写，依赖条件可以指定文件名或伪目标
* 一般情况下，NMAKE 会在当前目录下查找依赖文件，但可以使用 {dir;dir2}dependent 形式的语法指定搜索路径
* NMAKE 在执行命令之前会打印命令，除非使用了 /S、.SILENT、!CMDSWITCHES、或@，另外-command或-n command可以忽略非0或大于n的返回错误码
* 命令部分可以包含一条或多条命令，每条命令占据单独一行，在规则和命令之间不能出现空行（命令和命令之间可以），仅包含空格和tab的行是空命令不是空行
* 一个命令行以1个或多个空格或tab开始，续行使可以使用反斜杠加换行符（会被解析成空格），但注意反斜杠之后不能有任何除换行之外的字符
* 单独一条命令可以出现在依赖条件之后，中间使用分号（;）进行分隔，例如 project.obj: project.c project.h ; cl /c project.c
* NMAKE 使用 name=value 形式定义变量，可以包含字母、数字、和下划线，最多1024个字符，名字中可以包含变量，但必须是已经定义的且不能为空
* 变量的名字区分大小写，值部分可以包含0个或多个任意的字符，如果包含0个或仅包含空格和tab，则这个变量的值为空，包括未定义和为空的变量都可以用在值中
* 未定义或值为空的变量会被解析成空串，变量的定义必须单行其顶格出现，不能以空格或tab开头，另外等号两边的空格和tabs会被忽略
* 但命令选项等号两边不能有空格或tab，例如 /D=a 选项中如果出现空白会解析成多个选项，空白在命令行中是选项的分隔符，如果选项值包含空白需使用引号括起
* NMAKE 中同名变量的优先级为（从高到低）：NMAKE 命令行定义、make 文件或包含文件中定义、环境变量、Tools.ini中定义、预定义变量
* 变量通过 $(name) 的形式进行引用，括号中不允许使用空格，如果名字只有一个字符可以不使用括号，引用变量之后，变量的值会替换到变量引用的地方
* NMAKE 定义的特殊变量包括：%@ 表示当前目标文件名，$? 时间戳在目标文件之后的所有依赖文件，这两个变量的含义与 GNU MAKE 中的含义相同
* $* 表示不包含后缀名的当前目标文件名，例如 dir/file、dir/file.txt 的 $* 值为 dir/file，注意 GNU MAKE 也有这个变量但只能使用在模式规则中
* $< 表示时间戳在目标文件之后的依赖文件，只能使用在模式规则中，注意 GNU MAKE 也有这个变量但表示依赖条件中的第一个文件
* $** 表示当前目标中的所有依赖文件，与 GNU MAKE 中的 $^ 相同；另外可以结合前面变量一起使用的 D 和 F 表示目录和文件名，与 GNU MAKE 一样
* 与 GNU MAKE 不一样的是 B 和 R，如果当前目标文件为 C:\folder\file.h，则 $(@B) 表示 file，而 $(@R) 表示 C:\folder\file
* $(MAKE) 相当于执行 namke，$(MAKEDIR) 表示 nmake 执行的当前目录，$(AS) 表示 ml（macro assembler）
* $(BC) 表示 bc（basic compiler），$(CC)、$(CPP)、$(CXX) 都表示 cl，$(RC) 表示 rc（resource compiler）
* NMAKE中的模式规则采用 GNU MAKE 中老式的后缀规则进行定义，例如:
* .c.obj:  # 定义了 .c 文件如何转换成 .obj文件，这些后缀名必须定义在 .SUFFIXES 规则中
* <tab> command
* 可以使用大括号指定文件的搜索路径，只能指定一个目录，如果其中一个指定了路径另一个文件类型也必须指定，可以使用 {.} 或 {} 表示当前目录，例如：
* {misc\}.c{$(OBJDIR)}.obj::    　　　　　　# ::形式的模式规则可以提高编译效率，在生成文件时 NMAKE 可以决定将所有如 .c 文件一次性编译成 .obj
* <tab> $(CC) $(CFLAGS) $<      　　　　　　# 如果使用 : 形式，每次只能编译一个 .c 文件
* {misc\}.cpp($(OBJDIR)}.obj::　　　　　　　　# 预定义变量 $< 只能使用在模式规则中，表示时间戳在目标文件之后的依赖文件
* <tab> $(CC) $(CFLAGS) $(YUPDB) $<　　　# 在模式规则中，如示例中的 .c 或 .cpp 是依赖文件，而 .obj 是目标文件
* NMAKE 定义了很多隐含的模式规则，使得其中的一类文件可以自动转换成另一类文件，可以使用 nmake /p 查看这些隐含模式规则
* NMAKE 定义的预处理命令有：!if/!ifdef/!ifndef !else !endif !include 等，这些命令都必须以 ! 开头，且 ! 之前不能有空白（但后面可以有）
* 预处理命令中可以使用的操作符有：defined(macro)、exist(file)、！、==、!=、>、>=、<、<=、&&、&#124;&#124（逻辑或）
* 整数操作符 +、－、*、/、%、<<、>>、&、^^（异或）、&#124（位或）、~　等，条件表达式中可以包含变量引用、字符串、整数常量等
* NMAKE 和 GNU MAKE 对比：
* !message hello          $(info hell)
* !error message          $(error message)
* !include file           include file
* nmake /n （也可以使用-n）  make -n  # 仅显示命令不执行
* nmake /p （也可以使用-p）  make -p  # 打印预定义变量和规则
* nmake /f （也可以使用-f）  make -f  # MAKE 指定的文件
CL编译器选项
* CL [option...] file... [option | file]... [lib...] [@command-file] [/link link-opt...]
* 编译选项列表：https://msdn.microsoft.com/en-us/library/19z1t1wy.aspx
* 编译器控制的链接选项：https://msdn.microsoft.com/en-us/library/92b5ab4h.aspx
* 代码优化技巧：https://msdn.microsoft.com/en-us/library/eye126ky.aspx
* 如何使用优化编译选项：https://msdn.microsoft.com/en-us/library/ms235601.aspx
* 要查看程序的执行性能，可以使用程序性能跟踪工具 perfmon.exe
* CL 编译完后会自动进行链接，除非使用了 /c 选项，在链接时可以通过 /link 修改链接选项，另外 /E、/EP、/P 只预处理不进行编译
* /D 定义宏、/U 取消宏定义、/I 包含头文件搜索路径、/LD 创建动态链接库、/LDd 创建 debug 版本的动态链接库
* /MD 创建多线程动态链接库（使用 MSVCRT.lib），/MDd 创建 debug 版本的多线程动态链接库（使用 MSVCRTD.lib）
* /MT 创建多线程可执行文件（使用 LIBCMT.lib），/MTd 创建 debug 版本的多线程可执行文件（使用 LIBCMTD.lib）
* /TC、/TP 认为指定的所有文件都是 C 或 C++ 源文件，/Tc 和 /Tp 可以单独指定一个 C 或 C++ 源文件
* /W0，/W1，/W2，/W3，/W4 警告等级，/Wall 开启所有的警告，/WX 把警告当成错误，/showIncludes 显示编译时所有包含的头文件
* /Fopathname 改变一个目标文件的输出路径和文件名，/Fepathname 改变一个可执行文件或动态链接库文件的输出路径和文件名
预定义宏
* http://nadeausoftware.com/articles/2012/01/c_c_tip_how_use_compiler_predefined_macros_detect_operating_system
* http://beefchunk.com/documentation/lang/c/pre-defined-c/prestd.html
* https://sourceforge.net/p/predef/wiki/OperatingSystems/
持续集成
* jenkins官网：https://jenkins.io
* Ubuntu安装步骤（https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Ubuntu）
* $ wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
* $ sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
* $ sudo apt-get update
* $ sudo apt-get install jenkins
* 启动jenkins: sudo /etc/init.d/jenkins start (jenkins默认运行在 localhost:8080 主机端口上)
* 关闭jenkins: sudo /etc/init.d/jenkins stop
* jenkins的log保存在 /var/log/jenkins/jenkins.log 文件中，jenkins的配置可以修改 /etc/default/jenkins 文件
* jenkins的默认安装目录为：/var/lib/jenkins/
* jenkins war 文件的默认位置为：/usr/share/jenkins/jenkins.war
```

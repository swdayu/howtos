
**debug**
```shell
$ strace
$ pstack
```

**make**
- https://gcc.gnu.org/onlinedocs/gcc-5.3.0/gcc/
- http://www.ruanyifeng.com/blog/2015/02/make.html
- https://www.gnu.org/software/make/manual/make.html
- https://gist.github.com/isaacs/62a2d1825d04437c6f08
- http://www3.ntu.edu.sg/home/ehchua/programming/cpp/gcc_make.html

Makefile文件由一系列规则（rules）构成，每条规则的格式是：
```make
<target>: <prerequisites>
[tab]  <command-line>
[tab]  <command-line>
       ....
```

从第2行开始的命令行（command-line）都必须以tab开头，但可以通过.RECIPEPREFIX修改这个字符，例如：
```make
.RECIPEPREFIX= >
clean:
> rm -f target.so
```

目标可以包含多条命令，这些命令可以在同一行或不同行

```make

# target: dependencies
#         script
# - 如果target比dependencies都更新，则不会对这个target进行处理
# - 否则会对target进行处理，所有dependencies中的项目都被运行或重新产生，script部分也会被执行

# make                   ## 相当于执行makefile中的第一个target
# make CFLAGS="-g -Wall" ## 预先指定makefile变量值

# make内置变量：
# - $@ 当前目标文件完整名称
# - $* 如目标文件是prog.o，则$*为prog而$*.c为prog.c
# - $< 如果正在制作prog.o，而prog.c刚被修改，则$<就是prog.c

# POSIX标准make有特殊的从a.c源文件到a.o的编译方法:
# $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
# - 例如make如果认为它必须产生demo.o，则它会执行: $(CC) $(CFLAGS) $(LDFLAGS) -o demo.o demo.c

# 如果make觉得你需要从目标文件编译出一个可执行文件时，它会使用下面的方式：
# $(CC) $(LDFLAGS) first.o second.o $(LDLIBS)
# - 例如LDLIBS= -lbroad -lgeneral，它的依赖顺序为目标文件可能依赖于broad和general，broad可能依赖于general

# make -p > default_rules ## 保存make默认的规则到文件中


CC= gcc -std=c99
CFLAGS= -I/usr/bin/lua/include -DLUA_RELEASE -g -O3 -Wall -Wextra
CLIBS= -L/usr/bin/lua/lib -lweirdlib

GCC预定义宏：gcc -E -dM - </dev/null

MKDIR= mkdir -p
RM= rm -f

OBJS= lpvm.o lpcap.o lptree.o lpcode.o lpprint.o

main: $(OBJS)

lpeg.so: $(OBJS)
	env $(CC) $(OBJS) -o lpeg.so

lpcap.o: lpcap.c lpcap.h lptypes.h
lpcode.o: lpcode.c lptypes.h lpcode.h lptree.h lpvm.h lpcap.h
lpprint.o: lpprint.c lptypes.h lpprint.h lptree.h lpvm.h lpcap.h
lptree.o: lptree.c lptypes.h lpcap.h lpcode.h lptree.h lpvm.h lpprint.h
lpvm.o: lpvm.c lpcap.h lptypes.h lpvm.h lpprint.h lptree.h
```

```make
# from .c to .o
$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
# from .o to execute
$(CC) $(LDFLAGS) first.o second.o $(LDLIBS)

make CFLAGS="-g -Wall"  # set a makefile variable
CFLAGS="-g -Wall" make  # set a environment variable used only for make and its subprocess

# @: run the command but don't dispaly any output to the screen
# -: if the comand return zero then continue run, otherwise stop at the first non-zero return
@echo "Please do 'make PLATFORM' where PLATFORM is one of these:"
@echo "   $(PLATS)"

VARIABLE = value
# 在执行时扩展，允许递归扩展。
VARIABLE := value
# 在定义时扩展。
VARIABLE ?= value
# 只有在该变量为空时才设置值。
VARIABLE += value
# 将值追加到变量的尾端。

P = program_name
OBJECTS = 
$(P): $(OBJECTS)

CC = gcc -std=c99 
CWARNS = -Wall -Wextra -Werror -pedantic-errors
CFLAGS = $(CWRANS) -g -O2 -I/usr/bin/lua/include -DLUA_RELEASE -DMAX_SIZE=64 -UMAX_SIZE
LDFLAGS = -L/usr/bin/lua/lib
LDLIBS = -lpthread -lm -ldl -lbroad -lgeneral
SHARED = -fPIC -shared -Wl,-E

# linux:  -fPIC -shared -Wl,-E -ldl
# macosx: -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup -ldl
# macosx: -fPIC -bundle -undefined dynamic_lookup

# -Lpath -Wl,-Rpath  # -Wl,options: pass options to linker
# -pg: gprof executable_file > profile.txt

GCC的-static选项可以使链接器执行静态链接。但简单地使用-static显得有些’暴力’，
因为他会把命令行中-static后面的所有-l指明的库都静态链接，更主要的是，有些库
可能并没有提供静态库（.a），而只提供了动态库（.so）。这样的话，使用-static就
会造成链接错误。
之前的链接选项大致是这样的:
CORE_LIBS="$CORE_LIBS -L/usr/lib64/mysql -lmysqlclient -lz -lcrypt -lnsl -lm -L/usr/lib64 -lssl -lcrypto"
修改过是这样的:
CORE_LIBS="$CORE_LIBS -L/usr/lib64/mysql -Wl,-Bstatic -lmysqlclient \
-Wl,-Bdynamic -lz -lcrypt -lnsl -lm -L/usr/lib64 -lssl -lcrypto"
其中用到的两个选项：-Wl,-Bstatic和-Wl,-Bdynamic。这两个选项是gcc的特殊选项，它会将选项的参数传递给链接器，
作为链接器的选项。比如-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用
静态链接；-Wl,-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接。
　　
# 输出预处理后/汇编后/编译后的结果，如果不使用这些选项则生成可执行文件 
$ gcc -E/S/c source-file.c -o out-file-name
$ gcc main.c @opt_file   # options can stored in a file
$ man gcc   # see gcc options
  -undefined
    These options are passed to the Darwin linker. The Darwin linker man page describes them in detail.
  -bundle
    Produce a Mach-o bundle format file. See man ld(1) for more information.
  -dynamiclib
    When passed this option, GCC produces a dynamic library instead of an executable when linking, using
    the Darwin libtool command
  -g
    Produce debugging information in the operating system's native format (stabs, COFF, XCOFF, or DWARF 2).
    GDB can work with this debugging information.
    GCC allows you to use -g with -O.  The shortcuts taken by optimized code may occasionally produce
    surprising results: some variables you declared may not exist at all; flow of control may briefly
    move where you did not expect it; some statements may not be executed because they compute constant
    results or their values are already at hand; some statements may execute in different places because
    they have been moved out of loops.
    Nevertheless it proves possible to debug optimized output. This makes it reasonable to use the optimizer
    for programs that might have bugs.
  -pg
    Generate extra code to write profile information suitable for the analysis program gprof. You must use
    this option when compiling the source files you want data about, and you must also use it when linking.
$ man ld    # see GNU linker options
  -s
  --strip-all
    Omit all symbol information from the output file.
  -S
  --strip-debug
    Omit debugger symbol information (but not all symbols) from the output file.
  -O level
    If level is a numeric values greater than zero ld optimizes the output. This might take significantly
    longer and therefore probably should only be enabled for the final binary. At the moment this option only
    affects ELF shared library generation.
    Future releases of the linker may make more use of this option. Also currently there is no difference in
    the linker's behaviour for different non-zero values of this option. Again this may change with future releases.
  -E
    When creating a dynamically linked executable, using the -E option or the --export-dynamic option causes
    the linker to add all symbols to the dynamic symbol table. The dynamic symbol table is the set of symbols
    which are visible from dynamic objects at run time.
    If you do not use either of these options (or use the --no-export-dynamic option to restore the default behavior),
    the dynamic symbol table will normally contain only those symbols which are referenced by some dynamic object
    mentioned in the link.
    If you use "dlopen" to load a dynamic object which needs to refer back to the symbols defined by the program,
    rather than some other dynamic object, then you will probably need to use this option when linking the
    program itself.
    You can also use the dynamic list to control what symbols should be added to the dynamic symbol table
    if the output format supports it.  See the description of --dynamic-list.
    Note that this option is specific to ELF targeted ports. PE targets support a similar function to export
    all symbols from a DLL or EXE; see the description of --export-all-symbols below.
  -rpath=dir
    Add a directory to the runtime library search path. This is used when linking an ELF executable with
    shared objects. All -rpath arguments are concatenated and passed to the runtime linker, which uses them
    to locate shared objects at runtime. The -rpath option is also used when locating shared objects which
    are needed by shared objects explicitly included in the link; see the description of the -rpath-link option.
    If -rpath is not used when linking an ELF executable, the contents of the environment variable "LD_RUN_PATH"
    will be used if it is defined.
    The -rpath option may also be used on SunOS. By default, on SunOS, the linker will form a runtime search
    path out of all the -L options it is given. If a -rpath option is used, the runtime search path will be formed
    exclusively using the -rpath options, ignoring the -L options. This can be useful when using gcc, which adds
    many -L options which may be on NFS mounted file systems.
    For compatibility with other ELF linkers, if the -R option is followed by a directory name, rather than a file
    name, it is treated as the -rpath option.
```

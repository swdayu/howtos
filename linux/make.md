
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
P= program_name
OBJECTS= 
$(P): $(OBJECTS)

CC= gcc -std=c99 
CWARNS = -Wall -Wextra -Werror -pedantic-errors
CFLAGS= $(CWRANS) -g -O3 -I/usr/bin/lua/include -DLUA_RELEASE
LDFLAGS = -L/usr/bin/lua/lib
LDLIBS = -lpthread -lm -ldl -lbroad -lgeneral

# -Lpath -Wl,-Rpath
# linux:  -fPIC -shared -Wl,-E
# macosx: -fPIC -dynamiclib -Wl,-undefined,dynamic_lookup # -bundle -undefined dynamic_lookup
 
# from .c to .o
$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $*.c
# from .o to execute
$(CC) $(LDFLAGS) first.o second.o $(LDLIBS)
```

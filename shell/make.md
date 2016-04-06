                              
## m    ake
- https://gcc.gnu.org/onlinedocs/gcc-5.3.0/gcc/
- http://www.ruanyifeng.com/blog/2015/02/make.html

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



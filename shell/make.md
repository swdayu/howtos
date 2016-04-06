
## make
- https://gcc.gnu.org/onlinedocs/gcc-5.3.0/gcc/

```make
CC= gcc -std=c99
CFLAGS= -O2 -Wall -Wextra

MKDIR= mkdir -p
RM= rm -f

OBJS= lpvm.o lpcap.o lptree.o lpcode.o lpprint.o

lpeg.so: $(OBJS)
	env $(CC) $(OBJS) -o lpeg.so

lpcap.o: lpcap.c lpcap.h lptypes.h
lpcode.o: lpcode.c lptypes.h lpcode.h lptree.h lpvm.h lpcap.h
lpprint.o: lpprint.c lptypes.h lpprint.h lptree.h lpvm.h lpcap.h
lptree.o: lptree.c lptypes.h lpcap.h lpcode.h lptree.h lpvm.h lpprint.h
lpvm.o: lpvm.c lpcap.h lptypes.h lpvm.h lpprint.h lptree.h
```

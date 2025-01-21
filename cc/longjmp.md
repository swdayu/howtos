
# setjmp.h

**Non-local jumps**

The tools provided through this header file allow the programmer 
to bypass the normal function call and return discipline, 
by providing the means to perform jumps preserving the calling environment.

这个头文件提供非局部跳转功能（局部跳转是指通过goto语句局限在函数内部的跳转）。
它通过保存调用环境信息进行跳转，允许程序员绕过正常的函数调用和返回机制。

应特殊注意的几点：

1. 调用`setjmp`的函数中的局部变量如果在`setjmp`到`longjmp`的执行路径上被修改了，应声明为`volatile`；
2. 调用`longjmp`的函数必须与调用`setjmp`的函数相同，或这个函数调用的函数调用了`longjmp`；
3. `longjmp`永远不会返回，调用它的函数或函数的函数都不会返回，局部变量可能没有机会运行到作用域结束，
   在作用域结束才调用的代码都不会执行，例如VLA的释放以及C++对象析构函数的调用；
4. `setjmp`的调用表达式必须是独立唯一的表达式，否则可能会导致无定义行为；
5. `setjmp`和`longjmp`调用对，必须在同一个线程中；

## jmp_buf

```c
// Type to hold information to restore calling environment
jmp_buf

// Defined in MS compiler for x86
typedef struct __JUMP_BUFFER {
  unsigned long Ebp;
  unsigned long Ebx;
  unsigned long Edi;
  unsigned long Esi;
  unsigned long Esp;
  unsigned long Eip;
  unsigned long Registration;
  unsigned long TryLevel;
  unsigned long Cookie;
  unsigned long UnwindFunc;
  unsigned long UnwindData[6];
} _JUMP_BUFFER;
typedef int jmp_buf[16];

// For ARM
typedef struct _JUMP_BUFFER {
    unsigned long Frame;
    unsigned long R4;
    unsigned long R5;
    unsigned long R6;
    unsigned long R7;
    unsigned long R8;
    unsigned long R9;
    unsigned long R10;
    unsigned long R11;
    unsigned long Sp;
    unsigned long Pc;
    unsigned long Fpscr;
    unsigned long long D[8]; // D8-D15 VFP/NEON regs
} _JUMP_BUFFER;
typedef int jmp_buf[28];

// For x64
typedef struct _JUMP_BUFFER {
    unsigned __int64 Frame;
    unsigned __int64 Rbx;
    unsigned __int64 Rsp;
    unsigned __int64 Rbp;
    unsigned __int64 Rsi;
    unsigned __int64 Rdi;
    unsigned __int64 R12;
    unsigned __int64 R13;
    unsigned __int64 R14;
    unsigned __int64 R15;
    unsigned __int64 Rip;
    unsigned long MxCsr;
    unsigned short FpCsr;
    unsigned short Spare;
    SETJMP_FLOAT128 Xmm6;
    SETJMP_FLOAT128 Xmm7;
    SETJMP_FLOAT128 Xmm8;
    SETJMP_FLOAT128 Xmm9;
    SETJMP_FLOAT128 Xmm10;
    SETJMP_FLOAT128 Xmm11;
    SETJMP_FLOAT128 Xmm12;
    SETJMP_FLOAT128 Xmm13;
    SETJMP_FLOAT128 Xmm14;
    SETJMP_FLOAT128 Xmm15;
} _JUMP_BUFFER;
typedef struct _CRT_ALIGN(16) _SETJMP_FLOAT128 {
    unsigned __int64 Part[2];
} SETJMP_FLOAT128;
typedef SETJMP_FLOAT128 jmp_buf[16];
```

This is an array type capable of storing the information of a calling environment to be restored later.
This information is filled by calling macro `setjmp` and can be restored by calling function `longjmp`.

类型`jmp_buf`是一个用于存储当前调用环境信息以便以后恢复的数组。
通过使用宏`setjmp`存储环境信息，通过调用`longjmp`恢复环境。

## setjmp

```c
// Save calling environment for long jump
int setjmp(jmp_buf env);
```

This macro with functional form fills `env` with information about the current state of 
the calling environment in that point of code execution, so that it can be restored a later call to `longjmp`.

Calling `longjmp` with the information stored in `env` restores this same state and
returns the control to that same point (the call to `setjmp`), which is evaluated as a particular non-zero value.

宏函数`setjmp`用于将当前代码执行点的调用环境信息保存到变量`env`中，后面调用`longjmp`可以恢复这个环境。
用`env`保存的信息调用`longjmp`，环境会恢复到与之相同的状态并跳转到对应的执行点（即调用`setjmp`的地方），
（恢复到`setjmp`内部后，`setjmp`）会返回一个非零值。

Upon return to the scope of `setjmp`, all accessible objects, floating-point status flags, 
and other components of the abstract machine have the same values as they had when `longjmp` was executed, 
except for the non-volatile local variables in `setjmp`'s scope, 
whose values are indeterminate if they have been changed since the `setjmp` invocation.

如果从`setjmp`到`longjmp`的执行路径上，调用`setjmp`的函数的局部变量有被修改，
这些局部变量要声明为`volatile`，否则会导致无定义行为。
`volatile`声明的变量在使用时，每次访问都必须从内存中取值，防止编译器优化将其缓存到寄存器中。
必须声明为`volatile`的原因是，当环境恢复后寄存器中的值会恢复到原来的值，如果这个变量被修改了，
再从寄存器中取值就会发生错误，这种情况下必须访问内存中变量的实际值。

The invocation of `setjmp` shall be an expression statement by itself,
or be evaluated in a selection or iteration statement 
either as the (potentially negated) entire controlling expression 
or compared against an integer constant expression.
Otherwise, it causes *undefined behavior*.

对`setjmp`的调用，只能作为自身表达式的语句，
或作为唯一的控制表达式（可以取逻辑非或与整数常量表达式进行比较）用在选择或迭代语句(if, switch, for, while)中，
否则会导致无定义行为。

```c
// the entire expression of an expression statement
setjmp(env);

// the entire controlling expression
switch (setjmp(env)) { ... }

// with the nagative operator and as the entire controlling expression
while (!setjmp(env)) { ... }

// with compare to a integer constant expression and as the entire controlling expression
if (setjmp(env) > 10) { ... }
```

This macro may return more than once: A first time, on its direct invocation; in this case it always reutrns 0.
When `longjmp` is called with the information set to `env`, the macro returns again;
this time it returns the value passed to `longjmp` as second argument if this is different from zero,
or 1 if it is 0.

这个宏会返回多次：第一次是对它的直接调用，这时会返回0；
其他情况是从`longjmp`恢复过来，它会再次返回，这时会返回`longjmp`第2个参数的值，除非这个值是0（是0则返回1）。

## longjmp
```c
void longjmp(jmp_buf env, int val);
```

Restores the environment to the state indicated by `env` saved by a previous call of `setjmp`.
This function does not return. Instead, the function transfers the control to the point where `setjmp` was called.
That `setjmp` then returns the value, passed as the `val` (unless it is 0, in which case will return 1).

函数`longjmp`用于将环境恢复到前一次`setjmp`保存的`env`状态。
这个函数永远不会返回，相反会将控制权转移到对应的`setjmp`调用点，
然后`setjmp`返回`longjmp`的参数`val`（除非这个值是0，则会返回1）。

If `env` was not filled by a previous call to `setjmp` or if the function with such call has terminated execution 
(whether by return or by a different `longjmp` higher up the stack), it causes *undefined behavior*.
In other words, only long jumps up the call stack are allowed.

如果没有调用`setjmp`将恢复点的环境保存在`env`，
或调用`setjmp`的函数已经执行完了（不管是返回还是另外的`longjmp`），都会导致无定义行为。
也即，当函数`longjmp`被调用时，`env`必须通过调用`setjmp`保存好了恢复环境，
另外调用`setjmp`的函数当前必须还在调用栈中。
因此调用`longjmp`的函数必须与调用`setjmp`的函数相同，或这个函数调用的函数调用了`longjmp`。

On the way up the stack, `longjmp` does not deallocate any *VLA*s, 
memory leaks may occur if their lifetimes are terminated in this way.

In C++, the implementation may perform *stack unwinding* that destorys objects with automatic duration.
If this invokes any non-trivial destructors, it causes *undefined behavior*.

因为`longjmp`不会返回，调用它的函数或函数的函数都不会返回，
这些函数中定义的变长数组（VLA）都没有机会运行到其作用域结束，
因此`longjmp`恢复调用环境时，这些变长数组都不会释放，可能引起内存泄漏（根据VLA的实现方式）。

在C++中使用`longjmp`的情况也一样，如果调用`longjmp`的函数中定义的对象有实际意义的析构函数，
栈展开时（栈回到环境恢复点的状态）对应的析构函数都不会被调用（因为对象都没有运行到作用域结束），导致无定义行为。

```c
void g(int n)
{
    int a[n]; // a may remain allocated
    h(n); // does not return
}
void h(int n)
{
    int b[n]; // b may remain allocated
    longjmp(buf, 2); // might cause a memory leak for h's b and g's a
}
```

Data races: The scope of the `setjmp` and `longjmp` pair is limited to the current thread.

数据竞争：`setjmp`和`longjmp`调用对仅限于在当前线程中使用。

`longjmp` is intended for handling unexpected error conditions where the function cannot return meaningfully. 
This is similar to exception handling in other programming languages.

`longjmp`主要用来处理不预期错误条件，该情况下函数不能进行有意义的返回，与其他语言中的异常处理类似。

## examples

```c
/* setjmp example: error handling */
#include <stdio.h>      /* printf, scanf */
#include <stdlib.h>     /* exit */
#include <setjmp.h>     /* jmp_buf, setjmp, longjmp */

int main() {
  jmp_buf env;
  int val;

  val = setjmp (env);
  if (val) {
    fprintf (stderr,"Error %d happened",val);
    exit (val);
  }

  /* code here */

  longjmp (env,101);   /* signaling an error */
  
  return 0;
}

Output:
Error 101 happened
```

```c
/* longjmp example */
#include <stdio.h>      /* printf */
#include <setjmp.h>     /* jmp_buf, setjmp, longjmp */

int main() {
  jmp_buf env;
  int val;

  val=setjmp(env);

  printf ("val is %d\n",val);

  if (!val) longjmp(env, 1);

  return 0;
}

Output:
val is 0
val is 1
```

```c
#include <stdio.h>
#include <setjmp.h>
#include <stdnoreturn.h>
 
jmp_buf jump_buffer;
 
noreturn void a(int count) 
{
    printf("a(%d) called\n", count);
    longjmp(jump_buffer, count+1); // will return count+1 out of setjmp
}
 
int main(void)
{
    volatile int count = 0; // local vars must be volatile for setjmp
    if (setjmp(jump_buffer) != 9)
        a(count++);
}
```

```c
jmp_buf env; // only can share in the same thread

void DoSomething() {
  if (error) {
    longjmp(env, SOMETHING_ERROR);
  }
}

void Test() {
  switch (setjmp(env)) {
  case 0:
    DoSomething(env);
    break;
  case SOMETHING_ERROR:
    // handle error
    break;
  }
}
```


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

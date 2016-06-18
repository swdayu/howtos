

## 函数参数

```c
//[1] 值类型参数

//1.1 不可修改参数{{/*
int ia;
int ib = ia + 5;
const int aa = 1;
const int bb = ia + ib;
int addOne(const int a) {
  return a + 1;
}
int addOne(const BigData* a) {
  return *a + 1;
}
int a = 3;
int b = a * 5;
addOne(1);    //可以传递常量
addOne(b+a);  //可以传递变量
*/}}
//相当于C中的(const int a)
func addOne(int a) int {
  return a + 1 // 写成++a或a+=1会报错
}
func addOne(immutable int a) int {
  return a + 1
}

//1.2 可修改参数
func addTwo(int a) int {
  var b = a
  return b += 2
}
//1.2.1 取消var的使用{{/*
int addTwo(const int a) {
  int b = a;
  return b += 2;
}
void modify(const BigData data) {
  BigData tmp = data; //影响性能
  tmp.value = 1;
}
//改进
void modify(const BigData* data) {
  BigData tmp = *data;
  tmp.value = 1;
}
*/}}


//[2] 对于引用类型

/*2.1 不可修改参数
func calc(RefData r) int { // 相当于int calc(const RefData*const r)
  r = new RefData() //报错
  r.value = 3       // 报错
  return r.value + 1 
  var r1 = r       // 报错（也可以拷贝一份给r1，但不符合引用语义），const RefData*不能转换成RefData*
}

/*2.2 可修改参数
func calc(inout RefData r) int { //相当于RefData*const r
  r = new RefData() //报错
  r.value = 3       //ok
  return r.value + 1
  var r1 = new RefData() //相当于RefData* r1
  r1 = r
}

## 示例
func addOne(int a) int {
  return a + 1
}
func addOne(inout int a) int {
  return a += 1
}
var ival = 0
addOne(ival)  //ival不变
addOne(&ival) //ival会改变

func calc(RefData r) int {
  return r.value + 1
}
func calc(inout RefData r) int {
  return r.value += 1
}
val rval = new RefData()
calc(rval)  //rval保证不会改变
calc(&rval) //rval会改变
rval = createRefData() //rval引用到新的对象

## 函数参数语法
*parameter表示形参，argument表示实参

// 如果没有返回值，无需使用void
func foo(int a, double b) { /**/ }
func foo(in int a, b, in double c) int { /**/ }
func bar(inout int a, b, int c, d, double e) int { /**/ }

Parameter:
  ParameterQualifier ParameterDefinition |
  ParameterDefinition

ParameterQualifier:
  "in" | 
  "inout"

// TypeName cannot be "void", void不是一个关键字
ParameterDefinition:
  TypeName ParameterName |
  ParameterName

VariableParameterDefinition:
  "..." ParameterName

// TypeName cannot be "void"，void不是一个关键字
SameTypeVariableParamerDefinition:
  TypeName "..." ParameterName

ParameterList:
  Parameter |
  ParameterList "," Parameter

// 可变参数只能是作为最后一个参数
VariableParameterList:
  VariableParameterDefinition |
  SameTypeVariableParamerDefinition |
  ParameterList "," VariableParameterDefinition |
  ParameterList "," SameTypeVariableParamerDefinition

ParameterPart:
  "(" ")" |
  "(" ParameterList ")" |
  "(" VariableParameterList ")"
  

```

## 自定义类型中的函数

**构造和析构函数**
```c
class Test {
  var size = int
  init() @zero
  init(int size) {
    .size = size
  }
  deinit() {
    /**/
  }
}
```

**静态函数**
```c
// 全局可访问静态函数
func Test:create(int size) Test {
  return Test(size)
}
// 仅限当前文件访问
func Test:_create() Test {
  return Test.create(1)
}
```

**成员函数**
```c
func Test.start(self, int flag) {
  startTest((self.size + 8) & flag)
}
func Test._start(self, int flag) {
  startTest((self.size + 8) & flag)
}
func Test.start(inout self, int flag) {
  self.size += 8
  startTest(self.size & flag)
}
func Test._start(inout self, int flag) {
  self.size += 8
  startTest(self.size & flag)
}
```

**默认参数和显式命名参数**
```c
// 默认参数只能用@paraName显示命名方式定义，参数列表内的参数不能带返回值
func foo(int a, b, double... dargs) {
  @c double  // 无默认参数的参数可以是in也可以是inout
  @d = 3.14f // 有默认参数的参数只能是in，不能是inout类型的参数
}
foo(1, 2, .c=3.0, 1.0, 2.0)
foo(.c=3.0, 1, 2, 1.0, 2.0, .d=6.28f)
```

**tuple参数的处理**
```c
只能作为最后一个参数，每次调用都会产生一个新的结构体，也即自动生成一个新的重载函数
func print_tuple_int_double({.a=1, .b=3.14} arg) {}
func print_tuple_int_int({.a = 1, .b = 2} arg) {}
```

**可变单一类型参数的处理**
```c
只能作为最后一个参数，每次调用不会产生新的重载
func print(int... args) {}
逻辑上等价于函数:
func print_arr([int] iarr) {}
但是两者的调用方式不同：
print(1, 2, 3, 4)
print_arr([1, 2, 3, 4])
```

**函数重载的处理**
```c
1. 一个文件内（包括导入的名称）相同的函数名称，定义了一组重载的函数，级重载函数拥有相同的函数名
2. 根据以下规则来决定最终会调用那个函数（如果能调用多于一个函数，应该报错）
   - 先去掉所有的显示命名参数，然后从左到右边依次比较实参和形参的类型
   - 除了实参子类的情况，类型必须完全匹配，只要有一个不匹配就会报错终止
   - 再检查显式命名参数，所有的显示名称都必须完全匹配，否则会报错终止
3. 返回值的处理：同一列重载函数可以有不同的返回类型，只要它们能够赋给同一类型（基类或整数最大类型等）
```

**多个返回值的处理**
```c
func bar() int, double {}
var ival, dval = bar()

//返回值@error必须进行错误处理，否则会报编译错误
func create() @error, Test {}
var ok, test = create()
if !ok {
  /* error log */
}
```

**解释器的原理**
```c
将支持的函数都生成到动态库中
程序的解释过程，即解析代码中的操作然后动态调用动态库中对应的操作的过程
```

**操作符重载**

**匿名函数的写法**

**函数赋值变量的写法**

**省略调用***
```c
// call function that has only one argument with string/array/table/set type:
Test.print(string s) { /* ... */ }
Test.print([|int] a) { /* ... */ }
Test.print([int] a) { /* ... */ }
Test.print([int:string] t) { /* ... */ }

var test = Test()
test.print"abcd"
test.print[|1, 2, 3]
test.print[23, 12,]
test.print[12:"a", 23:"b"]
```

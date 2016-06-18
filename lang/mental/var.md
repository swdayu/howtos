
- http://stackoverflow.com/questions/25846561/swift-printing-optional-variable

```c
You have to understand what an Optional really is.
Many Swift beginners think `var age: Int?` means that age is an Int which may or may not has a value.
But it means that age is an Optional which may or may not hold an Int.
Inside your `description()` function you don't print the Int, but instead you print the Optional.
If you want to print the Int you have to unwrap the Optinal.
You can use "optional binding" to unwrap an Optional: `if let a = age { /* a is an Int */ }`
If you are sure that the Optional holds an object, you can use "forced unwrapping": `let a = age!`

// 变量只能一次定义一个，除非多个函数返回值的情况
var lang = string
var title = string
var body = Content
var charset = CharsetAttr"utf-8"
var metaData = [MetaTag]
var css = [LinkTag]
var js = [ScriptTag]

var a = int     // 使用默认值初始化，相当于int()
var b = 3       // 其他值初始化
var c = [int]   // 默认值初始化，相当于[int]()
var d = [0, 2]  // 其他值初始化
var e = [int](.size=8,.value=0)
var f = string  // 相当于""，也相当于string()
var f = "abc"
var charset = CharsetAttr"utf-8"
var r = new RefValue    // 引用类型必须使用new分配对象，相当于new RefValue()
var v = RefValue or nil // 当前变量是可空变量，它的初始值为nil，使用时必须先判断是否为空

var obj = ValueData //相对于ValueData()
var obj = new ClassTest()
var obj2 = new Child() as BaseClass

var a = 3.0
var str = "double = {{a}}"
var s2 = "complex calculate {{
  var b = 3.14
  add(a, b, c) //上文必须已经定义了a和c，以及函数add
}}"

// 1. 普通字符串
var s1 = "doube dval = {{dval}}\tfloat fval = {{fval}}\n"
// 2. 原始字符串，不会对其中的字符进行转义
var s2 = ```c:\nop\data.txt```
// 3. 多行字符串，相当于"string line one\nstring line two\n"
var s3 = {"""2 //去掉行前的2个空格
  string line one
  string line two
"""}
var s4 = {```2
  string line one
  string line two```} //与上面相同，只是少了最后一行的换行符号

// 4. 将文件转换成字符串
var s4 = ```here is a string of file =>{{#inc "layout/header.html"}}```

var a1 = [int]                   // empty array
var a2 = [int](.size=3,.value=0)  // array with 3 elements
var a3 = [1, 2, 3]

var t1 = [int:string]            // empty table
var t2 = [int:string](.size=128) // table with 128 elements space
var t3 = [1:"a", 2:"b"]

var s1 = [|int]               // empty set
var s2 = [|int](.size=4)           // set with 5 elements space
var s3 = [|3, 6, 9]

// 一般变量
var a = 3.14      // global shared variable
var _a = 6.28     // global variable only used in current file

// 一旦初始化就不能修改的变量
immutable b = a   // global shared variable
immutable _b = b  // global immutable only used in current file

// 线程存储变量
threadlocal t = 0 // thread local storage variable

struct/class {
  // static变量: 不占用对象空间
  static var sa = 0         // public static variable
  static var _sa = 0        // private static variable, only available to current file
  static immutable sb = sa  // public static immutable
  static immutable _sb = sb // private static immutable, only available to current file
}

局部作用域之函数体内 {
  // static变量
  static var sa = 0
  static immutable sb = 0
}

// 小值转换成大值，可以直接使用后缀；否则必须进行强制转换，使用后缀还是会报错
var a = Test() as Base
var b = int(32.2)
var c = double(32)
var d = 32.2
var e = 23f
var f = 23ull

var color = Color.Red
color = .Blue         // 会自动推导类型
color = .Yellow       // 会自动推导类型
```

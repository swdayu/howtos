
```c
enum PI = 3.14
enum MaxSize = 128
enum Tag = "abcd"
enum GoldenSeq = [1, 3, 5, 7]
enum B1 = byte(23)
enum B2 = 23b

enum Color {
  Red = 3
  Yellow
  Blue
}

var color = Color.Red
color = .Blue         // 会自动推导类型
color = .Yellow       // 会自动推导类型

enum Color2 {
  Red = byte(3)
  Yellow
  Blue
}

enum isGreaterType(T, U, int SIZE) {
  isGreaterType = T.sizeof > U.sizeof
  #if (T.sizeof >= U.sizeof) {
    typedef MaxType = T
  }
  else {
    typedef MaxType = U
  }
  Red = 3
  Yellow
  Blue
}
```

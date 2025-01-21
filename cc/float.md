
浮点标准

```
* https://en.wikipedia.org/wiki/IEEE_754-1985
* https://en.wikipedia.org/wiki/IEEE_floating_point#IEEE_754-2008
* http://steve.hollasch.net/cgindex/coding/ieeefloat.html
* 浮点数包含3个部分：符号位（sign）、指数部分（exponent）、尾数部分（mantissa），尾数由小数部分（fraction）以及隐含的开始比特组成
* 单精度（32-bit）和双精度的浮点数的结构如下，方括号内的数字表示比特位范围
* |                  | Sign   | Exponent  (Bias) | Fraction   | Precision
* | single precision | 1 [31] |  8 [30-23]  127  | 23 [22-00] | approx. ~7.2 decimal digits
* | double precision | 1 [63] | 11 [62-52] 1023  | 52 [51-00] | approx. ~15.9 decimal digits
* 最高位为符号位，0表示正数，1表示负数，翻转这一比特可以翻转数字的符号
* 中间为指数部分（基数2是默认的），它通过减去一个偏差（Bias）来实现正负数的表示，例如单精度浮点指数部分的值为100则实际值为100-127=-27
* 指数部分全0（单精度表示-127，双精度表示-1023）和全1（单精度表示255-127=128，双精度表示2047-1023=1024）是特殊值
* 尾数部分是浮点有效位表示精度，它采用标准形式（将小数点放置在第1个非零比特之后），因此开始比特始终是1无需保存，只需存储小数部分（fraction）
* 正常浮点数：指数部分不为全0也不为全1，以单精度为例它表示的数字是 (-1)^sign × 1.fraction × 2^(exponent-127)
* 非规范化数（denormalized number）：指数部分为0但小数部分不为0，以单精度为例它表示的数字是 (-1)^sign × 0.fraction × 2^(-126)
* 零：指数部分和小数部分都为0，虽然正零（+0）和负零（-0）是相区别的两个数字但它们相等，零是一个特殊的非规范化数
* 无穷大：指数部分全1并且小数部分为0，根据符号位的不同有正无穷（+infinity）和负无穷（-infinity）
* NaN（not a number）：指数部分全1并且小数部分不为0，可用于表示计算结果不是一个数字
* 其中QNaN（Quiet NaN）小数部分最高位为1，表示非法的运算结果；SNaN（Signaling NaN）小数部分最高位为0，用于在运算时引发异常
* 浮点数的特殊操作：任何与NaN进行运算的结果都是NaN，其他的特殊操作如下
* n ÷ ±Infinity = 0， ±Infinity × ±Infinity = ±Infinity， ±Nonzero ÷ 0 = ±Infinity, Infinity + Infinity = Infinity
* ±0 ÷ ±0 = NaN， Infinity - Infinity = NaN， ±Infinity ÷ ±Infinity = NaN， ±Infinity × 0 = NaN
```

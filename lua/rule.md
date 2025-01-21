
- https://developer.apple.com/swift/
- https://onevcat.com/2014/06/walk-in-swift/

## lexical

```lua
Character:
  AnyUtf8Char

EndOfFile:
  PhysicalEndOfTheFile
  '\x00'
  '\x1a'

EndOfLine:
  '\x0d'
  '\x0a'
  '\u000d' '\u000a'
  '\u2028'
  '\u2029'
  EndOfFile

WhiteSpace:
  Space
  Space WhiteSpace

Space:
  '\x20'
  '\x09'
  '\x0b'
  '\x0c'

Comment:       # Comment is replaced using one space after preprocess
  LineComment
  BlockComment

LineComment:
  "//" Characters EndOfLine

BlockComment:
  "/*" Characters "*/"
  
local endOfLine = lpeg.P("\xFE\xBF") + lpeg.P("\x0D\x0A") + lpeg.P("\x0A\x0D") +
    lpeg.S("\x00\x1A\x0D\x0A") + lpeg.P(toUtf8(0x2028)) + lpeg.P(toUtf8(0x2029))
local whiteSpace = lpeg.S("\x20\x09\x0B\x0C")^1
local lineComment = lpeg.P("//") * ((-endOfLine * 1)^0 + endOfLine)

#!/usr/bin/env lua -l "lpeg"
local lpeg = require "lpeg"
local P = lpeg.P
local C = lpeg.C
local Cg = lpeg.Cg
local Cb = lpeg.Cb
local Cs = lpeg.Cs
local Ct = lpeg.Ct
local Cmt = lpeg.Cmt

local function match_time_func(dstr, pos, val)
  local newPos = P(val):match(dstr, pos)
  -- print(dstr, pos, "match " .. val .. " newPos " .. (newPos or "nil"))
  if newPos == nil then
    return nil
  end
  return newPos, val
end

local blockCommentStart = Cg(P("/") * C(P("*")^1), "stars")
local blockCommentEnd = Cb("stars") / "%1/"
local blockComment = blockCommentStart * (Cb("stars") / "/%1") *
    (C("/") + (-Cmt(blockCommentEnd, match_time_func) * 1)^1 * Cmt(blockCommentEnd, match_time_func))
local testpatt = blockCommentStart * (Cb("stars") / "/%1") * 1 * Cmt(blockCommentEnd, match_time_func)

local a, b = 0, 0
a, b = blockComment:match("/*/")
assert(a == "/*" and b == "/")
a, b = blockComment:match("/**/")
assert(a == "/**" and b == "/")
a, b = blockComment:match("/***/")
assert(a == "/***" and b == "/")
a, b = testpatt:match("/* */")
print(a, b)
a, b = blockComment:match("/* */")
print(a, b)
assert(a == "/*" and b == "*/")
a, b = blockComment:match("/** **/")
print(a, b)
assert(a == "/**" and b == "**/")
a, b = blockComment:match("/* ***/")
print(a, b)
assert(a == "/*" and b == "*/")
a, b = blockComment:match("/** */")
print(a, b)
assert(a == nil and b == nil)


Characters:
  Character
  Character Characters

从输入流读取token的规则（每次扫描前首先忽略开头空白）:
1. 单词 - 以下划线或字母开头，后跟零个或多个下划线字母或数字，直到遇到空白或非下划线字母数字为止
2. 数字 - 包括FloatLiteral和IntegerLiteral
3. 字符和字符串 - 程序语言定义的字符和字符串
4. 括号 - 每个括号都是一个单独的token，括号有：() <> [] {}
5. 符号序列 - 由符号~!@#$%^&*-+=|\:;,.?/组成的字符序列，直到遇到空白或非这些符号字符为止
6. 以符号序列开始的特殊序列 - 可定制一些特殊的序列放在符号序列之前解析
7. 不属于以上情况的其他序列 - 其他合法或非法的utf8序列

UTF8字符规则：
- http://www.unicode.org/
- http://www.utf-8.com/
- http://www.ietf.org/rfc/rfc3629.txt
- http://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt
- http://local.joelonsoftware.com/wiki/The_Joel_on_Software_Translation_Project:%E8%90%AC%E5%9C%8B%E7%A2%BC
- http://local.joelonsoftware.com/mediawiki/index.php/Main_Page

   Char. number range  |        UTF-8 octet sequence
      (hexadecimal)    |              (binary)
-----------------------+------------------------------------------------------
07 0000_0000-0000_007F | 0XXXXXXX
                       | 00000000
                       | 01111111 [00->7F]
11 0000_0080-0000_07FF | 110XXXXX_10XXXXXX
                       | 11000010_10000000
                       | 11011111_10111111 [C2->DF] [80->BF]
16 0000_0800-0000_FFFF | 1110XXXX_10XXXXXX_10XXXXXX
                       | 11100000_10100000_10000000 [E0->E0] [A0->BF]
                       | 11101111_10111111_10111111 [E1->EF] [80->BF]
21 0001_0000-001F_FFFF | 11110XXX_10XXXXXX_10XXXXXX_10XXXXXX
                       | 11110000_10010000_10000000_10000000 [F0->F0] [90->BF]
                       | 11110111_10111111_10111111_10111111 [F1->F7] [80->BF]
26 0020_0000-03FF_FFFF | 111110XX_10XXXXXX_10XXXXXX_10XXXXXX_10XXXXXX 
                       | 11111000_10001000_10000000_10000000_10000000 [F8->F8] [88->BF]
                       | 11111011_10111111_10111111_10111111_10111111 [F9->FB] [80->BF]
31 0400_0000-7FFF_FFFF | 1111110X_10XXXXXX_10XXXXXX_10XXXXXX_10XXXXXX_10XXXXXX
                       | 11111100_10000100_10000000_10000000_10000000_10000000 [FC->FC] [84->BF]
                       | 11111101_10111111_10111111_10111111_10111111_10111111 [FD->FD] [80->BF]
-----------------------+------------------------------------------------------

local utf8_t = lpeg.R("\x80\xBF") --> utf8 encoding tail
local utf8_1 = lpeg.R("\x00\x7F")
local utf8_2 = lpeg.R("\xC2\xDF") * utf8_t
local utf8_3 = lpeg.R("\xE1\xEF") * utf8_t * utf8_t + lpeg.P("\xE0") * lpeg.R("\xA0\xBF") * utf8_t 
local utf8_4 = lpeg.R("\xF1\xF7") * utf8_t * utf8_t * utf8_t + lpeg.P("\xF0") * lpeg.R("\x90\xBF") * utf8_t * utf8_t
local utf8_5 = lpeg.R("\xF9\xFB") * utf8_t * utf8_t * utf8_t * utf8_t +
               lpeg.P("\xF8") * lpeg.R("\x88\xBF") * utf8_t * utf8_t * utf8_t
local utf8_6 = lpeg.P("\xFC") * lpeg.R("\x84\xBF") * utf8_t * utf8_t * utf8_t * utf8_t +
               lpeg.P("\xFD") * utf8_t * utf8_t * utf8_t * utf8_t * utf8_t

local utf8_seq_patt = utf8_1 + utf8_2 + utf8_3 + utf8_4 + utf8_5 + utf8_6

local utf8_byte_0 = lpeg.R("\x00\x7F")
local utf8_byte_10 = lpeg.R("\x80\xBF")
local utf8_byte_110 = lpeg.R("\xC0\xDF")
local utf8_byte_1110 = lpeg.R("\xE0\xEF")
local utf8_byte_11110 = lpeg.R("\xF0\xF7")
local utf8_byte_111110 = lpeg.R("\xF8\xFB")
local utf8_byte_1111110 = lpeg.R("\xFC\xFD")

-- error handle when utf8_seq_patt match failed
local skip_error_patt
if b == 0xFE or b == 0xFF then
  --> the byte is not a utf8-style byte
  skip_error_patt = lpeg.P(1)
else
  if utf8_byte_0:match(b) then
    print("[E] should match ok")
    return
  end
  if utf8_byte_10:match(b) then
    skip_error_patt = (#(utf8_byte_0 + utf8_byte_10) * lpeg.P(1))^1
  else
    skip_error_patt = lpeg.P(1) * (#(utf8_byte_0 + utf8_byte_10) * lpeg.P(1))^0
  end
end

-- return a table contain the file data
function readFile(filename)
  local file, err = io.open(filename, "rb")
  if file == nil then
    print("[E] open file '" .. filename .. "' to read failed " .. err)
    return nil
  end
  local str, err = file:read("a")
  if str == nil then
    print("[E] read file '" .. filename .. "' failed " .. err)
    return nil
  end
  return {data = str; start = 1}
end

-- return current utf8 char position [idx1, idx2]
function utf8Pos(infile)
  local idx = utf8_seq_patt:match(infile.data, infile.start)
  if idx == nil then
    return nil, nil
  end
  if idx == infile.start then
    return infile.start, idx
  end
  local start = infile.start
  infile.start = idx
  assert(idx > start)
  return start, idx-1
end

-- return current uft8 char
function utf8Char(infile)
  local i, j = utf8Pos(infile)
  if i == nil then
    return nil
  end
  return infile.data:sub(i, j)
end

-- return utf8 byte sequence string
function toUtf8(code)
end

-- return 64-bit integer
function toUnicode(utf8Char)
end


Token:
  Blank
  Comment
  Keyword
  StringLiteral                      // start with identifier char or " or '
  CharLiteral                        // start with identifier char or '
  SpecialSequenceWithIdnetifierStart // start with _ or letter
  Identifier                         // start with _ or letter
  FloatLiteral                       // start with number
  IntegerLiteral                     // start with number
  SpecialSequenceWithOpearatorStart  // start with operator char
  "." | ".." | "..." | "+" | "+="    // start with operator char
  ... ...

Identifier:
  IdentifierStartChar
  IdentifierStartChar IdnetifierChars

IdentifierStartChar:
  "_"
  Letter
  UniversalAlpha   ## ISO/IEC 9899:1999(E) Appendix D (C99 standard)

IdentifierChars:
  IdentifierChar
  IdentifierChar IdentifierChars

IdentifierChar:
  DecimalDigit
  IdentifierStartChar
```

**interger/float**
```c
void/true/false
bool/char/string     8-bit  /* b/c/s */
int/uint      pointer-size  /* i/u   */
int8/byte            8-bit  /* ib/ub */
short/ushort        16-bit  /* is/us */
medit/umedit        32-bit  /* im/um */
long/ulong          64-bit  /* il/ul */
cent/ucent         128-bit  /* ic/uc */
float               32-bit  /* fl */
freal               64-bit  /* fr */
fcent              128-bit  /* fc */
ffast     32-bit or 64 bit  /* ff */

bool - true false                     bool
rune/char - unsigned byte             rune/char
byte - unsigned byte                  byte ub
int8 - signed byte                    int8 i8
ihalf/uhalf - 16-bit                  half/uh  
ifull/ufull - 32-bit                  full/uf
ilong/ulong - 64-bit                  long/ul
icent/ucent - 128-bit                 cent/uc
iptr/uptr  - machine word size        iptr/up
int/uint - at least 64-bit            int/ui: default int type
float/real - 32/128-bit float point   float/real
double - 64-bit                       double: default float point type

bool rune string    // b/c/s
byte int8           // ub/ib
ihalf uhalf         // ih/uh
ifull ufull         // if/uf
ilong ulong         // il/ul
icent ucent         // ic/uc
int uint uptr       // i/u/up
float double freal  // f/fd/fr
pointer array slice map struct interface func

// integer suffix and user defined suffix
var a = 12int8
var b = 12byte
var len = 100.0km
var len = 100km.toDouble
var a = 12float.toByte

Iteger: // std.conv.octal octal!237_777
  DecimalInteger        "0 1 2 3 4 5 6 7 8 9 _" 只能以数字开头，开头不能有多个0
  BinaryInteger         0b/0B"0 1 _"
  OctalInteger          0o/0O"0 1 2 3 4 5 6 7 _"
  HexadecimalInterger   0x/0X"0 1 2 3 4 5 6 7 8 9 A a B b C c D d E e F f _"
  
Integer default type:
0 -> 2_147_483_647                             int
2_147_483_648 -> 9_223_372_036_854_775_807     int
0x0 -> 0x7FFF_FFFF                             int
0x8000_0000 -> 0xFFFF_FFFF                     int
0x1_0000_0000 -> 0x7FFF_FFFF_FFFF_FFFF         int
0x8000_0000_0000_0000 -> 0xFFFF_FFFF_FFFF_FFFF uint

true.print
'a'.print
23.print
0b01.print
0o77.print
0xFF.print
"str".print
[1,2].print
{343}.print
23.0.print
0.3e5.print

FloatLiteral shall match before IntegerLiteral,
because IntegerLiteral can become the prefix of a FloatLiteral.

BoolLiteral:
  "true"
  "false"

CharLiteral:
  "'" CharacterByte "'"
  "'" CharacterByte "'" IdentifierSuffix

CharacterByte:
  "\" EscapeChar
  "\x" HexDigit HexDigit
  PrintableChar

IntegerLiteral:
  DecimalInteger
  BinaryInteger
  OctalInteger
  HexInteger
  ByteSequence IdentifierSuffix
  DecimalInteger IdentifierSuffix
  BinaryInteger IdentifierSuffix
  OctalInteger IdentifierSuffix
  HexInteger IdentifierSuffix

ByteSequence: // notice byte-order problem
  "'" CharacterBytes "'"

CharacterBytes:
  CharacterByte
  CharacterByte CharacterBytes

DecimalInteger:
  DecimalDigit
  DecimalDigit DecimalTail

DecimalTail:
  DecimalReadableDigit
  DecimalReadableDigit DecimalTail

DecimalReadableDigit:
  "_"
  DecimalDigit

BinaryInteger:
  "0b" BinaryTail

BinaryTail:
  BinaryReadableDigit
  BinaryReadableDigit BinaryTail

BinaryReadableDigit:
  "_"
  BinaryDigit

FloatLiteral:
  DecimalFloat
  DecimalFloat FloatSuffix

DecimalFloat:
  DecimalInteger "." DecimalTail
  DecimalInteger "." DecimalTail DecimalExponent

DecimalExponent:
  DecimalExponetChars DecimalTail

DecimalExponentChars:
  "e"
  "e+"
  "e-"
```

**string**
```c

StringLiteral:
  DoubleQuotedString
  SingleQuotedString
  HexadecimalString
  CurlyBracketString
  DoubleQuotedString IdentifierSuffix
  SingleQuotedString IdentifierSuffix
  HexadecimalString IdentifierSuffix
  CurlyBracketString IdentifierSuffix

DoubleQuotedString:
  `"` CharacterSequence `"`
  `"""` CharacterSequence `"""`

CharacterSequence:
  NormalCharacter
  EscapeSequence
  NormalCharacter CharacterSequence
  EscapeSequence CharacterSequence

SingleQuotedString:
  `'''` CharacterSequence `'''`

HexadecimalString:
  `x"` HexCharSequence `"`

HexCharSequence:
  HexDigit
  BlankChar
  HexDigit HexCharSequence
  BlankChar HexCharSequence

CurlyBracketString:
  CurlyBracketStringHead RawCharSequence CurlyBracketStringTail

CurlyBracketStringHead:
  'q"{'
  'q"' CurlyBracketStringTag "{"
  'q"' CurlyBracketStringTag NumberOfIndentSpaces "{"
  'q"' CurlyBracketStringTag NumberOfIndentSpaces InsertExprQualifierString "{"

RawCharSequence:
  NormalCharacter
  PhysicalNewline
  NormalCharacter RawCharSequence
  PhysicalNewline RawCharSequence

CurlyBracketStringTail:
  "}" CurlyBracketStringTag   // need match CurlyBracketStringTag in CurlyBracketStringHead

CurlyBracketStringTag:
  "_"
  Letter
  "_" CurlyBracketStringTag
  Letter CurlyBracketStringTag

NumberOfIndentSpaces:
  DecimalInteger

InsertExprQualifierString:
  InsertExprQualifierChar
  InsertExprQualifierChar InsertExprQualifierString

InsertExprQualifierChar:
  ~`!@#$%^&*+=-|\:;'"?/

var str = "double = !(a)"
var s2 = "complex calculate !(add(a, b, c))"
// 插入表达式(interpolated expression)
var normalString = "abc\n2nd_line !(str)" ~ """include double quote " in string"""
var nstr2 = '''str"using"double"quote'''
var quoteString = q"{C:\data.txt} ~ q"tag{string here}tag
var qstr2 = q"{
string line 1
string line 2
}
var qstr3 = q"2!!{
  string line 1 
  string line 2 !!(val)
}
var qstr2 = q"tag2{
  string line 1
  string line 2
}tag
var hexstr = x"0A 00 F BCD 32" // "\x0A\x00\xFB\xCD\x32"
var qstr2: q"zzz2{
  string line 1
  string line 2
}zzz

var s = r"2tag\E{
  <html \E(@lang="" or del(1))>
  </html>
}tag"

Q字符串可以跨行书写，换行处会自动插入换行符号，但是在字符串开头或结尾换行不会插入换行符。
相邻的字符串字面量会自动合并。

__date__
__time__
__func__
__line__
__cmpl__
```

## syntax

**expr**
```c
,                                          PriorityComma
= += -= *= /= %= &= |= ^= ~= <<= >>= ^^=   PriorityAssign
?:                                         PriorityCondition
||    or                                   PriorityLogicalOr
&&    and                                  PriorityLogicalAnd
== != < <= > >=                            PriorityComparation
|                                          PriorityBitwiseOr
^ ~                                        PriorityBitwiseXor
&                                          PriorityBitwiseAnd
<< >>                                      PriorityBitwiseShift
+ - ~ ..                                   PrioritySubtract
* / %                                      PriorityDivision
^^                                         PriorityPower
! ~ + - * & #                              PriorityUnary
a.b call(arglist) a[1] s[1..3]             PriorityPostfix
identifer .identifier literals (expr)      PriorityPrimary

P, R, S, V = lpeg.P, lpeg.R, lpeg.S, lepg.V
C, Ct = lpeg.C, lpeg.Ct
Blank = (space + capture_newline)^0
Lparen = C"(" * Blank
Rparen = C")" * Blank
Lbracket = C"[" * Blank
Rbracket = C"]" * Blank
Lcurl = C"{" * Blank
Rcurl = C"}" * Blank

EQU = C(P"=" + S"+-*/%&|^~" * P"=" + P"<<=" + P">>=" + P"^^=") * Blank
LOR = C(P"||" + P"or") * Blank
LAD = C(P"&&" + P"and") * Blank
CMP = C(S"=!><" * P"=" + P"<" + P">") * Blank
BOR = C"|" * Blank
XOR = C"^" * Blank
BAD = C"&" * Blank
SHT = C(P"<<" + P">>") * Blank
ADD = C(S"+-~") * Blank
MUL = C(S"*/%") * Blank
POW = C(P"^^") * Blank
UNA = C(S"!~+=*&#") * Blank
DOT = C"." * Blank
CMA = C"," * Blank
QST = C"?" * Blank
COL = C":" * Blank

CondExpr = V"CondExpr"
BinaryExpr = V"BinaryExpr"
LogicalOr = V"LogicalOr"
LogicalAnd = V"LogicalAnd"
Comparation = V"Comparation"
BitwiseOr = V"BitwiseOr"
BitwiseXor = V"BitwiseXor"
BitwiseAnd = V"BitwiseAnd"
BitwiseShift = V"BitwiseShift"
AddExpr = V"AddExpr"
MulExpr = V"MulExpr"
PowExpr = V"PowExpr"
UnaryExpr = V"UnaryExpr"
PostfixExpr = V"PostfixExpr"
PrimaryExpr = V"PrimaryExpr"

Expr = P{"S";
  S = V"CommaExpr"；
  CommaExpr = Ct(CondExpr * CMA * V"S" + CondExpr);
  CondExpr = Ct(BinaryExpr * QST * V"S" * COL * CondExpr + BinaryExpr);
  BinaryExpr = Ct(LogicalOr * (LOR * LogicalOr)^0);
  LogicalOr = Ct(LogicalAnd * (LAD * LogicalAnd)^0);
  LogicalAnd = Ct(Comparation * (CMP * Comparation)^0);
  Comparation = Ct(BitwiseOr * (BOR * BitwiseOr)^0);
  BitwiseOr = Ct(BitwiseXor * (XOR * BitwiseXor)^0);
  BitwiseXor = Ct(BitwiseAnd * (BAD * BitwiseAnd)^0);
  BitwiseAnd = Ct(BitwiseShift * (SHT * BitwiseShift)^0);
  BitwiseShift = Ct(AddExpr * (ADD * AddExpr)^0);
  AddExpr = Ct(MulExpr * (MUL * MulExpr)^0);
  MulExpr = Ct(PowExpr * (POW * PowExpr)^0);
  PowExpr = Ct(Blank * PostfixExpr + UnaryExpr);
  UnaryExpr = Ct(UNA * UnaryExpr + Blank * PostfixExpr);
  PostfixExpr = Ct(PrimaryExpr * (DOT * PrimaryExpr)^0);
  PrimaryExpr = Idnetifier + Lparen * V"S" * Rparen + Literals +
      DOT * Identifier + BasicTypeX * DOT * Identifier +
      BasicTypeX * Lparen * ArgumentList * Rparen;
}

File file = openFile("a.txt")
return if file == null
var x, y = document.documentElement.scrollLeft, /scrollTop
```

**symbols: enum, var, imm, struct, func**
```c
# Name visible rules
- private names are visible in this package
- public names are visible to anyone
- package scope: enum/var/imm/struct/func
  * a package is a singleton after it is initialized
- interface scope: enum/func static
  * all names are private if interface is private
- struct scope: enum/var/imm/ref static
  * all names are private if struct is private 
- func scope: enum/var/imm/ref static
  * all names in a func are local names 

enum maxSize = 5    // private
enum MaxSize = 3    // public

enum {
  lightBlue = 6  // private
  LightBlue = 4  // public
}

enum color {
  Red = 0        // private
  LightBlue      // private
  numberOfColors // private
}

enum Color {
  Red = 0        // public
  LightBlue      // public
  numberOfColors // private
}

var/imm size // private
var/imm Size // public

var/imm {
  count = 0 // private
  Count = 1 // public
}

var/imm x, y, z = getXyz()
var/imm x, y, z = y, x, y, // need create temp varaible for x and y
var/imm a, b, c = 1, 0, 1
var a, imm b, var c = 1, 0, 1

struct/interface camera // private
struct/interface Camera // public

func getSize() int // private
func GetSize() int // public
func camera.capture() image // private
func camera.Capture() image // private
func Camera.capture() image // private
func Camera.Capture() image // public
func Camera:createCapture() Camera // private
func Camera:CreateCapture() Camera // public

# Variable passing rules

func addOne(int a)          // "const int a"
func addOne(inout int a)    // "int*const a"
func addOne(Person a)       // "const Person*const a"
func addOne(inout Person a) // "Person*const a"
var p1 = Person(1, 2, 3)    // "Person"
ref p2 = Person(2, 3, 4)    // "Person*"
var a = 3
addOne(a)  addOne(&a)
addOne(p1) addOne(&p1)
addOne(p2) addOne(&p2)

var p1, ref p2 = testReturn() // the definition order is not critial in a file
func testReturn() {
  var p1 = Person()
  ref p2 = Person()  // ref can only be used to user defined objects
  return p1, p2      // p1 will make a copy of person, p2 just return the ref
}

class GlobalRefSlots {
  struct Slot {
    void* pmemory;
    uptr refcount;
    Slot(): pmemory(0), refcount(0) {}
  };
  std::vector<Slot> slots;
public:
  void* operator[](uptr index) {
    return slots[index].pmemory;
  }
};
GlobalRefSlots globalRefSlots;
struct Ref { // p2.size => ((Person*)p2.access())->size
  uptr globalIndex;
  Ref(Null n = Null()): globalIndex(0) {}
  void increaseCount() {
    if (index != 0) {
      globalRefSlots.inc(index);
    }
  }
  void decreaseCount() {
    if (index != 0) {
      globalRefSlots.dec(index);
      index = 0;
    }
  }
  Ref(uptr index): globalIndex(index) {
    increaseCount()
  }
  Ref(const Ref& rhs): globalIndex(rhs.globalIndex) {
    increaseCount();
  }
  Ref& operator=(const Ref& rhs) {
    if (&rhs == this) {
      return *this;
    }
    decreaseCount();
    globalIndex = rhs.globalIndex;
    increaseCount();
    return *this;
  }
  Ref& operator=(Null) {
    decreaseCount();
    return *this;
  }
  void* access() {
    return globalRefSlots[index];
  }
  ~Ref() {
    decreaseCount();
  }
};

# Looping reference problem
```

**var/imm/enum**
```c
enum PI = 3.14
enum MaxSize = 128
enum GoldenSeq = [1, 3, 5, 7]

enum {
  Tag = "abcd"
  B1 = byte(23)
  B2 = 23b
}

enum Color {
  Red = 3
  Yellow
  Blue
}

%%enum
Tag = "abcd"
B1 = byte(23)
B2 = 23b

%%enum Color
Red = 3
Yellow
Blue

%%

var color = Color.Red
color = .Blue         // 会自动推导类型
color = .Yellow       // 会自动推导类型

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

var file)a = 3.14
var this)b = 6.28

默认参数的语法
1. 类成员变量
struct Coordinate {
  var minX = 0.0
  var minY = 0.0 
  var widthX = 0.0
  var widthY = 0.0
}
2. 函数普通参数的默认值
func calc(int a, b = 64, double c = 3.14) { // imm int a  // without default value
}                                           // imm int b = 64  imm double c = 3.14
3. 函数显式命名参数的默认值
func calc(int a) {
 @b = 64     // imm b = 64
 @c = 3.14   // imm c = 3.14
 @double d   // without default value
}
4. 普通变量的初始默认值
var a = 0
var b = 0.0
var s = "123"
var hval = 'bm'half
var ival = "12".toInt
var ival ?int  // no default value (var ival ?0, var str ?"")
var ival = int // with default value of int

http://stackoverflow.com/questions/25846561/swift-printing-optional-variable
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

%%var
a = 1
b = 2
c = 3

%%var Camera
x = 0
y = 0
z = 0

%%func calc(int a, b) int
return a + b

%%func html(string title, charset="UTF-8") @string!
<!DOCTYPE html>
<html>
  <head>
    <meta charset="!charset">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <title>!title</title>
    <link rel="stylesheet" href="code-guide.css">
    <script src="code-guide.js"></script>
  </head>
  <body>
  </body>
</html>

%%func cal(int a, b) @int a + b
%%func cal(int a, b) int return a + b
func cal(int a, b) @int { a + b }
func cal(int a, b) int { return a + b }
```

**container**
```c
```

**struct**
```c
```

**class**
```c
```

**function**
```c
```

**constant object**
```c
```

**object define**
```c
var dval = 1.0         // default can be modified
var car = 3.0 frozen   // frozen object is immutable
var str = "abc" frozen
var status, data = requireData() frozen data
func calc(int a, b) int {
  return a + b
}
var calc = { (int a, b) int | frozen
  return a + b
}

imm car = 3.0   // object is immutable
imm str = "abc"
var status, imm data = requireData()
imm calc = { (int a, b) int |
  return a + b
}
```

```c
void
bool - true false
char - unsigned type
byte/int8 - unsigned/signed 8-bit integer
uint/int - unsigned/signed integer at least with pointer-size
uptr      - uint
uint16 int16 - unsigned/signed 16-bit integer
uint32 int32 - unsigned/signed 32-bit integer
uint64 int64 - unsigned/signed 64-bit integer
float/double
string

postfix: 23ub  23b    8-bit
         23ui  23     machine word size
         23us  23s    16-bit
         23ul  23L    32-bit
         23ull 23LL   64-bit 
         23f   23.0   float double

user defined postfix: operator'kg(int a) int      56'kg + 32'pd

int literal: 0b1101 0o775 0xFA 42   0b1101_1100 0xFFBB_FFFE 430_323_1234
char literal: ' ', 'Space', 'Tab', 'Enter', 'a', 'b', 'c', 42c, 0xF3c, \n, \t, \x(FF), \d(255), \o(777), \b(0110_0111)
unicode literal: \u(1F21): utf-16, \u(0000_0A11): utf-32, \utf8(7F) \utf8(0000_0A11) 

// 如果struct中的所有数据成员都是zero init的，且该结构也会zero init，则这个结果也是zero init的
struct HtmlDoc {
  var lang = string
  var title = string
  var body = Content
  var charset = CharsetAttr"utf-8"
  var metaData = [MetaTag]
  var css = [LinkTag]
  var js = [ScriptTag]
}

???如何尽量消除指针

var a = int     // 使用默认值初始化，相当于int()
var b = 3       // 其他值初始化
var c = [int]   // 默认值初始化，相当于[int]()
var d = [0, 2]  // 其他值初始化
var e = [int](.size=8,.value=0)
var f = string  // 相当于""，也相当于string()
var f = "abc"
var charset = CharsetAttr"utf-8"
var r = new RefValue // 引用类型必须使用new分配对象，相当于new RefValue()
var v = RefValue?    // 引用类型也可以使用?表示当前变量是可空变量，它的初始值为nil，使用时必须先判断是否为空

var a, b, c, d = 0
```

## 错误处理

@error返回值的函数必须检查错误，否则会报错

## Standard Container
```c
// @calculate函数中的@参数必须通过显式参数名称传递参数，例如calcluate(3.14, 1.0, .a = 42)
func calculate(double dval, dval2) {
  // @a int 表示a是这个函数的一个int参数，并且没有默认值
  // @b = 3.21 表示b是这个函数的一个double参数，并且有默认值3.21 
  add(@a int, @b = 3.21)
  mul(a, b)
  
  // 也可以这样定义
  @c var int // 参数c是可修改参数
  @d = 3.21
  sum(c, d, dval1, dval2)
}

var a1 = [int]                   // empty array
var a2 = [int](.size=3,.value=0)  // array with 3 elements
var a3 = [1, 2, 3]

var t1 = [int:string]            // empty table
var t2 = [int:string](.size=128) // table with 128 elements space
var t3 = [1:"a", 2:"b"]

var s1 = [|int]               // empty set
var s2 = [|int](.size=4)           // set with 5 elements space
var s3 = [|3, 6, 9]

// call function that has only one argument with string/array/table/set type:
Test.print(string s) void { /* ... */ }
Test.print([|int] a) void { /* ... */ }
Test.print([int] a) void { /* ... */ }
Test.print([int:string] t) void { /* ... */ }

var test = Test()
test.print"abcd"
test.print[|1, 2, 3]
test.print[23, 12,]
test.print[12:"a", 23:"b"]

var obj = new ClassTest()
var obj2 = new Child() as BaseClass
```

## User defined type
```c
1. 真正的值传递 - 只要赋值就会拷贝一份   // 如swift中的struct以及基本类型，struct只能实现接口不能继承
2. 优化的值传递 - 只有在修改时才拷贝     // 如swift中的string, array, table, set
3. 引用传递                              // 如swift中的class

常量不可修改，只能使用常量表达式在初始化时赋值一次；
常量可以赋值给变量，赋值后变量当前的值为这个常量值；
变量可以暂时赋予不可修改属性，在一定范围内限制对它的修改；
常量不应占用struct/class类空间和对象空间；
值类型赋给不可修改变量会发生一次拷贝；
引用类型对象赋给不可修改变量不发送拷贝，不能重新引用一个新的引用对象，也不能对引用对象进行修改
常量/计算属性可以使用在enum/struct/class中，存储属性只能使用在struct/class中
常量使用const和enum定义，变量使用var定义，不可修改变量使用immutable定义，还有两个修饰符是static和threadlocal
@[?]引用类型声明为const无需监控其占用内存，实现是可以将引用类型的内容保存在常量中，不使用保存对象地址的方式
@[?]但如果两个引用类型常量相同，一个常量仅保存指针指向另外一个常量

???自定义类型的默认构造函数都将内容清0不做其他事，如果有init而且在使用之前没有赋值则使用时会先调用init;
// primitive type - bool char byte int double uptr
// compound type - string array table set
// user defined type - struct class
int ival
int[3] iarr // 普通数据只能用在primitive类型上
string sval
[int] aval
[|int] setv
[int:string] tval
ValObj value
RefObj refval

全局作用域 {
  // 常量
  const PI = 3.14
  enum Color {
    Red = 3 Yellow Blue
  }

  // 一般变量
  var a = 3.14      // global shared variable
  var _a = 6.28     // global variable only used in current file

  // 一旦初始化就不能修改的变量
  immutable b = a   // global shared variable
  immutable _b = b  // global immutable only used in current file

  // 线程存储变量
  threadlocal t = 0 // thread local storage variableS
}

struct/class作用域 {
  // 常量：不占用对象空间
  const PI = 3.14

  // 变量
  var a = 0        // public variable
  var _a = 0       // private variable, only available to current file
  var aa = int?    // 不进行初始化的变量，去掉对非初始化变量的支持
  var bb = RefObj? // ???

  // 不可修改变量
  immutable b = a  // public immutable
  immutable _b = b // private immutable, only available to current file

  // static变量: 不占用对象空间
  static var sa = 0         // public static variable
  static var _sa = 0        // private static variable, only available to current file
  static immutable sb = sa  // public static immutable
  static immutable _sb = sb // private static immutable, only available to current file
}

局部作用域之函数参数 {
  // 传引用还是传值由类型决定，不需要额外的关键字说明
  (int a, b, c, var double d) 默认是immutable的，使用var可以指定对应变量可以修改

  // immutable 值类型：不会修改外部传入值，相当于C里面的声明(int a)但a的值不能修改
  // variable 值类型：如 var int a相当于C里面的(int a)或(int* a)
  // immutable引用类型：不会修改外部传入值
  // variable引用类型：可能会修改外部传入值

  func modify(int a) { //在C实现中自动根据对应值类型的大小决定传值还是传const指针
    a = 3 // error
  }

  //在C实现中会定义两个版本：传值和传指针
  //对引用类型都一样，在函数内可能会改变引用对象的值
  //对值类型，如果直接传入参数例如modify(a)不会修改外部的值，如果传入modify(&a)则会修改外部的值
  func modify(var int a) {
    a = 3 // ok, does't affect outside value
  }

  //func modify(var& int a) { //&只能用来修饰值类型，在C实现中传指针
  //  a = 3 // ok, affect outside value
  //}
}

局部作用域之函数体内 {
  // 常量
  const PI = 3.14

  // 变量
  var a = 0

  // 不可修改变量
  immutable b = a
  
  // static变量
  static var sa = 0
  static immutable sb = 0
  
  // size/num/count（同一个参数的别名）是函数的int参数，没有默认值
  // 注意在函数内部只能使用size这个名称
  @size.num.count int

  @d var int    // d是函数的var int参数，没有默认值
  @e = 12f      // e是函数的float参数，默认值为12f
}

// 小值转换成大值，可以直接使用后缀；否则必须进行强制转换，使用后缀还是会报错
var a = Test() as Base
var b = int(32.2)
var c = double(32)
var d = 32.2
var e = 23f
var f = 23ull

var addFunc0 = func (int a, b) int { // { (int a, b) int | return a + b }
  return a + b 
}

var addFunc1 = addFunc

typedef Func = func (int a, b) int // 必须给定参数名称

var addFunc2 = Func { // { Func | return $a + $b }
  return $a + $b
}

var a = 0

var addFunc3 = Func [a] { // 这里[]内的a是传递实参不是参数定义 // { Func [a] |
  return a + $a + $b // 或者 return a + $1 + $2
}

var addFunc4 = Func [&a] { // 这里[]内的a是传递实参不是参数定义 // { Func [&a] |
  a += 1
  return a + $a + $b
}

var addFunc5 = func (int x, y) int { // { (int x, y) int | return x + y }
  return x + y
}

var addFunc6 = func [a](int x, y) int { // { [a] (int x, y) int | return a + x + y }
  return a + x + y
}

// addTwo 的类型为 func (int x) int
var addTwo = addFunc6 as ($y = 2) // 或者($2 = 2)

// 最后一个函数参数的简写
sort([0, 3, 2, 5]){ $1 < $2 }
sort([0, 3, 2, 5], <)
[0, 3, 2, 5].sort(<)
// 相当于
sort([0, 3, 2, 5], func (int x, y) bool { return x < y })
```

## 函数重载规则

```c
1. 参数只区分类型，不区分immutable还是variable
2. 函数还可以通过显式参数名不同来重载，即使类型和其他条件都一样，例如：
   func print(@) void {
      @count int
      // ...
   }
   func print(@) void {
     @size int
     // ...
   }
   print(.size = 1)  // 调用第2个
   print(.count = 2) // 调用第1个
```

## Uniform call syntex
```c
f(x,y) if not found then try x.f(y)
x.f(y) if not found then try f(x,y) 
Test.print(t) will seek Test|print(Test: test)
```

## Data and its method
```c
module lucy.test
import lucy.core.Print, Scanf //只需要导入struct/class名称，文件作用域内的全局变量名、函数名、常量名、函数类型名称
import lucy.base.Fopen as FileOpen, Fclose as FileClose, Fread as BaseFileRead
import lucy.stream.* //提示所有同名标识符，using只能占用一行

package main
// package search: install folder, projects under LANGPATH/src folders
import "lucy/stream" Print Scanf
import lstm "lucy/stream"
import "lucy/stream" {
  lsPrint Print 
  lsScanf Scanf 
  lsFormat Format
}

// possible global prefix, multiple defines can be group in { and }
// - module
// - import
// - typedef
// - var
// - func
// - enum
// - const
// - class

typedef Func = func (int a, b) int

func printTest(int a) byte {
  return byte(a)
}

func _printTest() byte, byte {
  return 1, 1
}

var addFunc = Func {    // var addFunc = { Func |
  return $a + $b
}
var x = 3
var addFunc2 = Func [x] { // var addFunc2 = { Func [x] |
  return x + $a + $b
}
var addFunc3 = addFunc //函数类型可以自动推导出来

var a = 3
var aa = 3s
var bb = 4LL
var cc = 23.0

var f1 = float(23)
var fa = 234f

const PI = 3.1415926
const MaxSize = 128
const Tag = "abcd"
const GoldenSeq = [1, 3, 5, 7]
const B1 = byte(23)
cosnt B2 = 23b

enum Color {
  Red = 3LL
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

//数据成员、参数声明列表使用Type name形式
class _Test {
  var size = 0
  var offset = int? // need init it manually
} 

class DefaultInit: Base {
  var equal = UserEqual // member is private
  var mask = 0xFFFF     // member is private
}

class Point {
  var x = 0.0
  var y = 0.0
}

class Size {
  var width = 0.0
  var height = 0.0
}

class Rect {
  var origin = Point()
  var size = Size()
}

// read-write
func center(Rect) Point {
  get {
    // ...
  }
  set(newCenter) {
    // ...
  }
}

// read-only
func width(Rect) double {
  return self.size.width
}

// const version
func print(Test) void {
  Print(self.size) // 相当于Print(self.size)
}

// mutable version
func print(var Test) void {
  Print(self.size)
}

func @override start(Test) int, Func {
  return 1, func (int x, y) int { return x + y } // return 1, { (int x, y) int | return x + y }
}

func _start(Test, int a) int num, Func sum {
  return 2, func [a](int x, y) int { return a + x + y } // return 2, { [a](int x, y) int | return a + x + y}
}

func _start(var Test, int a, b) {
  return
}

func transform(int) string {
  return "{{%x|self}}"
}

// Class static functions

func Test:create(int a, b) Test {
  return Test(1, 2)
}

func Test:create() Test {
  return Test.create(0, 1)
}
```

## 自定义类型

```c
值类型与引用类型的区别：
1. 值类型的对象都拥有相互独立的值，不相互影响
2. 引用类型的对象是共享的，多个变量可以引用同一个对象

按照通用的准则，当符合一条或多条以下条件时，请考虑构建结构体：
- 该数据结构的主要目的是用来封装少量相关简单数据值。
- 有理由预计该数据结构的实例在被赋值或传递时，封装的数据将会被拷贝而不是被引用。
- 该数据结构中储存的值类型属性，也应该被拷贝，而不是被引用。
- 该数据结构不需要去继承另一个既有类型的属性或者行为。
举例来说，以下情境中适合使用结构体：
- 几何形状的大小，封装一个 width 属性和 height 属性，两者均为 Double 类型。
- 一定范围内的路径，封装一个 start 属性和 length 属性，两者均为 Int 类型。
- 三维坐标系内一点，封装 x ， y 和 z 属性，三者均为 Double 类型。
在所有其它案例中，定义一个类，生成一个它的实例，并通过引用来管理和传递。实际中，这意味着绝大部分的
自定义数据构造都应该是类，而非结构体。


???如果管理引用类型的内存

struct和class继承自定义类型的话，只能将基类作为第一个数据成员的方式进行继承；
只有class才能继承接口；

class Base {
  var a = 0
  var b = 0
}

class Child {
  var Base
  var c = 0
  var d = 0
}

// 接口只能包括常量和函数声明
interface ICar {
  func drive() void
  func stop() void
}

class MyCar: ICar, IBase {
  var BaseClass
  var miles = 0.0
  // 默认构造函数如果有定义且没有手动调用其它构造函数的话会在对象第一次使用前调用
  init() @zero
  // 非默认构造函数
  init(int a, b) {}
  // 析构函数，在对象释放时调用（值类型退出作用域，引用类型正在释放时）
  deinit() {}
}

// 为值类型自动插入析构函数
func getValObj() ValData {
  var a = ValData()
  return a
}
ValData getValObj() {
  ValData_struct a;
  ValData_init(&a);
  ValData_struct tmp = a;
  ValData_deinit(&a);
  return tmp;
}




```

## Member reference 
```c
pobj->m, obj.m => pobj.m, obj.m
```

## 不定长参数
```c
// ... ..< ..=
func sum(int... args) int { 
  var total = 0
  foreach(elem) in args {
    total += args
  }
  return total
}
```

## Meta Programming

```c

struct TupleDemo {
  int ival;
  double dval;
}
static const int TupleDemo_sizeof = sizeof(TupleDemo);
static const int TupleDemo_length = 2;

static const int int_sizeof = sizeof(int)
static const int int_typeid = /* ... */;
static const char* int_type

var args = TupleDemo()
args.sizeof //编译时常量
args.length //编译时常量
args.typeid //编译时常量，但对于多态继承的类会保存到虚拟指针列表中
args.typestr //编译时常量，但对于多态继承的类会保存到虚拟指针列表中
args.typecat //编译时常量，"integer float string array set table function enum const struct class union"
arg[0].stringof //编译时常量
typeof(args[0]) //编译时类型推导


// 在语法上，变量的定义和函数的调用是编译时多态的
// foreach可能的用法：
// - 遍历容器(string, array, set, table)访问元素、索引+元素，键，值，键+值，等等
// - 遍历用户自定义对象的各个数据成员
// - 根据range遍历各种对象，如File的每行，视频的每帧，等等
func print(T, U, double RATE)(T t, U u, #tuple args) void {
  
}

class Table(T, U) {
  
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

// 逻辑上每调用一次print会新定义一个结构体#tuple
// args是这个结构体的实例变量
// foreach可以依次遍历结构体的各个成员 ???
foreach (/* loop variables */ in obj) {
  /* ... exprs inside the foreach block ...*/
} ???
obj.opApply([](/* loop variables */) int { /* ... exprs inside the foreach block ...*/ return hasBeenTerminated })

func print(#tuple args) void {
  foreach(i, arg) in args {
    print("{{i}}: {{arg.typestr}} {{arg.stringof}}") 
  }
}

var t1 = tuple(12, x+y, 3.14, "abc")
t1[0].stringof //"12"
t1[1].stringof //"x+y"
t1[2].stringof //"3.14"
t1[3].stringof //"abc"

var t2 = TupleDemo.tupleof
t2[0].typestr // "int"
t2[0].stringof // "ival"
t2[1].stringof // "dval"

var t3 = tuple(.start = 1, .end = 10)
t3[0].typestr // "int"
t3[0].stringof // "1"
t3.start // "1"
t3.end // "10"
```

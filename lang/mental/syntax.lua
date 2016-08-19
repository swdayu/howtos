
```lua
local lpeg = require "lpeg"

function lpeg.St(t)
  local patt = lpeg.P(false)
  for _,v in ipairs(t) do
    patt = patt + lpeg.P(v)
  end
  return patt
end

function lpeg.Cst(t)
  local patt = lpeg.P(false)
  for i,v in ipairs(t) do
    patt = patt + lpeg.P(v) * lpeg.Cc(i)
  end
  return patt
end

-- P, R, S, St = lpeg.P, lpeg.R, lpeg.S, lpeg.St
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local St = lpeg.St

-- C, Cc, Cg, Cb, Cmt, Cst = lpeg.C, lpeg.Cc, lpeg.Cg, lpeg.Cb, lpeg.Cmt, lpeg.Cst
local C = lpeg.C
local Cc = lpeg.Cc
local Cp = lpeg.Cp
local Cg = lpeg.Cg
local Cb = lpeg.Cb
local Cmt = lpeg.Cmt
local Cst = lpeg.Cst


local y = {lineno = 1; colno = 1; curpos = 1}

local function y.info()
  return "L"..y.lineno.."C"..y.colno.."P"..y.curpos  
end

local function y.reset()
  y.lineno = 1
  y.colno = 1
  y.curpos = 1
end

local keywords = {
  "void", "null",
  "bool", "true", "false",
  "char", "byte", "int8",
  "half", "uhalf",
  "full", "ufull",
  "long", "ulong",
  "cent", "ucent",
  "iptr", "uptr",
  "int", "uint",
  "float", "double", "real",
  "var", "imm", "enum", "class",
  "continue", "fallthrough", "break", "goto", "return"
}

local newlines = {
  "\x0A\x0D",
  "\x0D\x0A",
  "\x0D",
  "\x0A",
  "\x00",
  "\x1A",
  "\xFE\xBF",
  --toUtf8(0x2028),
  --toUtf8(0x2029)
}


-- keyword

local function keyword_matched(i, pos)
  local s = keywords[i]
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info(), "KEYWORD", s)
  return s
end

local function y.match_keyword()
  return (Cst(keywords) * Cp()) / keyword_matched
end


-- space

function space_matched(s, pos)
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info(), "SPACE #"..#s)
  return s
end

local function y.match_space()
  return (C(S"\x20\x09\x0B\x0C"^1) * Cp()) / space_matched
end


-- newline

local function newline_matched(i, pos)
  local s = newlines[i]
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info(), "NEWLINE #"..#s)
  y.lineno = y.lineno + 1
  y.colno = 1
  return s
end

local function match_newline()
  return (Cst(newlines) * Cp()) / newline_matched
end


-- single line comment

local function comment_matched(s, pos)
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info, "COMMENT", s)
  y.lineno = y.lineno + 1
  y.colno = 1
  return s
end

local function y.match_comment()
  return (C(P"//" * (1 - St(newlines))^0 * St(newlines)) * Cp()) / comment_matched
end


-- block (multi-line) comment

local function f_newline_in_blockcomment(i, pos)
  print(pos, "NEWLINE in BLOCKCOMMENT #" .. #newlines[i])
  y.lineno = y.lineno + 1
  y.colno = 1
  y.curpos = pos
  -- return no value to avoid produce capture values
end

local function f_match_blockcomment_tail(subject, pos, val)
  local newpos = P(val):match(subject, pos)
  print(pos, val .. " matched ", newpos or "failure")
  if newpos == nil then
    return false
  end
  return newpos
end

local function f_empty_blockcomment(s, pos)
  print("[" .. (pos - #s) .. "," .. pos ..")", s)
  return s
end

local function f_blockcomment(s, asterisk, pos)
  local levels = #asterisk
  print(pos, "BLOCKCOMMENT"..levels, s)
  return s
end

local function l_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "asterisk")
  local match_newline = (Cst(newlines) * Cp()) / f_newline_in_blockcomment
  local match_tail = Cmt(Cb"asterisk"/"%1/", f_match_blockcomment_tail)
  return (C(start * P"/") * Cp()) / f_empty_blockcomment +
         (C(start * Cb"asterisk" * (match_newline + (1 - match_tail))^1 * match_tail) * Cp()) / f_blockcomment
end



function f_printtoken(s, type)
  local len = #s
  y.colno = y.colno + len
  y.curpos = y.curpos + len
  print(y.curpos, type, s)
  return s
end

local function f_character(s)
  return f_printtoken(s, "CHARACTER")
end

local function f_identifier(s)
  return f_printtoken(s, "IDENTIFIER")
end

local function f_float(s)
  return f_printtoken(s, "FLOAT")
end

local function f_integer(s)
  return f_printtoken(s, "INTEGER")
end

local function f_operator(s)
  return f_printtoken(s, "OPERATOR")
end

local function f_backslash(s)
  return f_printtoken(s, "BACKSLASH")
end

local function f_bracket(s)
  return f_printtoken(s, "BRACKET")
end

local function l_character()
  local l_hex = R("09", "af", "AF")
  local l_char =  P"\\x" * l_hex * l_hex + P"\\x" * l_hex + P"\\" * 1 + (1 - P"'")
  return (P"'" * l_char * P"'" + P"'" * l_char * P"'" * l_identifier()) / f_character
end

local function l_special_identifier()
end

local function l_identifier()
  local letter = R("az", "AZ")
  local number = R("09")
  return ((P"_" + letter) * (P"_" + letter + number)^0) / f_identifier
end

local function l_integertail(...)
  return (P"_" + R(...))^1
end

local l_decimalinteger = R"09" + R"09" * l_integertail("09")

local function l_float()
  local l_exponent = S"eE" + P"e+" + P"E+" + P"e-" + P"E-"
  local l_decimalfloat = l_decimalinteger * P"." * l_integertail("09") +
      l_decimalinteger * P"." * l_integertail("09") * l_exponent * l_integertail("09")
  return (l_decimalfloat + l_decimalfloat * l_identifier()) / f_float
end

local function l_integer()
  local l_binaryinteger = (P"0b" + P"0B") * l_integertail("01")
  local l_octalinteger = (P"0o" + P"0O") * l_integertail("07")
  local l_hexinteger = (P"0x" + P"0X") * l_integertail("09", "af", "AF")
  return (l_binaryinteger + l_binaryinteger * l_identifier() +
      l_decimalinteger + l_decimalinteger * l_identifier() +
      l_octalinteger + l_octalinteger * l_identifier() +
      l_hexinteger + l_hexinteger * l_identifier()) / f_integer
end

local function l_special_operator()
end

local function l_operator()
  return (S"`~!@#$%^&*-+=|'\":;<,>.?/"^1) / f_operator
end

-- backslash can only appear in comment, char and string
local function l_backslash()
  return (P"\\"^1) / f_backslash
end

local function l_bracket()
  return S"(){}[]" / f_bracket
end

```

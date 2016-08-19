
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

local function match_blockcomment_tail(subject, pos, val)
  local newpos = P(val):match(subject, pos)
  print(pos, val .. " matched newpos ", newpos or "nil")
  if newpos == nil then
    return false
  end
  return newpos
end

local function found_newline_in_blockcomment(i, pos)
  y.colno = y.colno + (pos - y.curpos)
  y.curpos = pos
  print(pos, "NEWLINE in BLOCKCOMMENT #" .. #newlines[i])
  y.lineno = y.lineno + 1
  y.colno = 1
  -- return no value to avoid produce capture values
end

local function empty_blockcomment_matched(s, pos)
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info(), "EMPTY BLOCKCOMMENT", s)
  return s
end

local function blockcomment_matched(s, asterisk, matched, pos)
  local levels = #asterisk
  y.colno = y.colno + (pos - y.curpos)
  y.curpos = pos
  print(pos, "BLOCKCOMMENT"..levels, "matched "..matched, s)
  if matched ~= 1 then
    -- match failed, print error message
  end
  return s
end

local function y.match_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "asterisk")
  local match_newline = (Cst(newlines) * Cp()) / found_newline_in_blockcomment
  local match_tail = Cmt(Cb"asterisk"/"%1/", match_blockcomment_tail)
  local capture_tail = match_tail * Cc(1) + (-1) * Cc(0)
  return (C(start * P"/") * Cp()) / empty_blockcomment_matched +
         (C(start * Cb"asterisk" * (match_newline + (1 - match_tail))^1 * capture_tail * Cp()) / f_blockcomment
end


-- special identifier

local function y.match_special_identifier()
end


-- identifier

local function token_matched(s, pos, tstr)
  y.colno = y.colno + #s
  y.curpos = pos
  print(y.info(), tstr, s)
  return s
end

local function identifier_matched(s, pos)
  return token_matched(s, pos, "IDENTIFIER")
end

local function y.match_identifier()
  local letter = R("az", "AZ")
  local number = R("09")
  return (C((P"_" + letter) * (P"_" + letter + number)^0) * Cp()) / identifier_matched
end


-- character

local function character_matched(s, pos)
  return token_matched(s, pos, "CHARACTER")
end

local function y.match_character()
  local hex = R("09", "af", "AF")
  local singlechar =  P"\\x" * hex * hex + P"\\x" * hex + P"\\" * 1 + (1 - P"'")
  return (C(P"'" * singlechar * P"'" + P"'" * singlechar * P"'" * y.match_identifier()) * Cp()) / character_matched
end


-- float

local decimalinteger = R"09" + R"09" * match_integertail("09")

local function match_integertail(...)
  return (P"_" + R(...))^1
end

local function float_matched(s, pos)
  return token_matched(s, pos, "FLOAT")
end

local function y.match_float()
  local exponent = S"eE" + P"e+" + P"E+" + P"e-" + P"E-"
  local decimalfloat = decimalinteger * P"." * match_integertail("09") +
      decimalinteger * P"." * match_integertail("09") * exponent * match_integertail("09")
  return (C(decimalfloat + decimalfloat * y.match_identifier()) + Cp()) / float_matched
end


-- integer

local function integer_matched(s, pos)
  return token_matched(s, pos, "INTEGER")
end

local function y.match_integer()
  local binaryinteger = (P"0b" + P"0B") * match_integertail("01")
  local octalinteger = (P"0o" + P"0O") * match_integertail("07")
  local hexinteger = (P"0x" + P"0X") * match_integertail("09", "af", "AF")
  return (C(binaryinteger + binaryinteger * y.match_identifier() +
      decimalinteger + decimalinteger * y.match_identifier() +
      octalinteger + octalinteger * y.match_identifier() +
      hexinteger + hexinteger * y.match_identifier()) * Cp()) / integer_matched
end


-- special operator

local function y.match_special_operator()
end


-- operator

local function operator_matched(s, pos)
  return token_matched(s, pos, "OPERATOR")
end

local function y.match_operator()
  return (C(S"`~!@#$%^&*-+=|'\":;<,>.?/"^1) * Cp()) / operator_matched
end


-- backslash can only appear in comment, char and string

local function backslash_matched(s, pos)
  return token_matched(s, pos, "BACKSLASH")
end

local function y.match_backslash()
  return (C(P"\\"^1) * Cp()) / backslash_matched
end


-- bracket

local function bracket_matched(s, pos)
  return token_matched(s, pos, "BRACKET")
end

local function y.match_bracket()
  return (C(S"(){}[]") * Cp()) / bracket_matched
end

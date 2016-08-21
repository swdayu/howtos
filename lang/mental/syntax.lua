
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



local y = {
  KEYWORD = {n = 1, s = "KEYWORD", h = "KW"};
  SPACE = {n = 2, s = "SPACE", h = "SP"};
  NEWLINE = {n = 3, s = "NEWLINE", h = "NL"};
  COMMENT = {n = 4, s = "COMMENT", h = "CM"};
  BLOCKCOMMENT = {n = 5, s = "BLOCKCOMMENT", h = "BC"};
  STRING = {n = 6, s = "STRING", h = "ST"};
  CHARACTER = {n = 7, s = "CHARACTER", h = "CH"};
  SPECIALIDENTIFIER = {n = 8, s = "SPECIALIDENTIFIER", h = "SI"};
  IDENTIFIER = {n = 9, s = "IDENTIFIER", h = "ID"};
  FLOAT = {n = 10, s = "FLOAT", h = "FL"};
  INTEGER = {n = 11, s = "INTEGER", h = "IN"};
  SPECIALOPERATOR = {n = 12, s = "SPECIALOPERATOR", h = "SO"};
  OPERATOR = {n = 13, s = "OPERATOR", h = "OP"};
  BLACKSLASH = {n = 14, s = "BLACKSLASH", h = "BS"};
  BRACKET = {n = 15, s = "BRACKET", h = "BR"};
  INVALIDTOKEN = {n = 16, s = "INVALIDTOKEN", h = "IV"};

  line_no = 1;
  column_no = 1;
  position = 1;
  token_string = "";
  token_type = INVALIDTOKEN
}

function y.reset()
  y.line_no = 1
  y.column_no = 1
  y.position = 1
  y.token_string = ""
  y.token_type = y.INVALIDTOKEN
end

function y.print_out()
  print("L"..y.line_no.."C"..y.column_no.."P"..y.position,
      y.token_type.s, "#"..#y.token_string..":"..y.token_string)
end

local function token_matched(s, p, t)
  y.token_string = s
  y.token_type = t
  y.column_no = y.column_no + #s
  y.position = p

  y.print_out()

  if t == y.NEWLINE or t == y.COMMENT then
    y.line_no = y.line_no + 1
    y.column_no = 1
  end
  return y.token_type, y.token_string
end


-- keyword

local function keyword_matched(i, pos)
  return token_matched(keywords[i], pos, y.KEYWORD)
end

function y.match_keyword()
  return (Cst(keywords) * Cp()) / keyword_matched
end

-- space

function space_matched(s, pos)
  return token_matched(s, pos, y.SPACE)
end

function y.match_space()
  return (C(S"\x20\x09\x0B\x0C"^1) * Cp()) / space_matched
end


-- newline

local function newline_matched(i, pos)
  return token_matched(newlines[i], pos, y.NEWLINE)
end

function y.match_newline()
  return (Cst(newlines) * Cp()) / newline_matched
end


-- single line comment

local function comment_matched(s, matched, pos)
  if matched ~= 1 then
    -- match failed
  end
  return token_matched(s, pos, y.COMMENT)
end

function y.match_comment()
  local match_end = St(newlines) * Cc(1) + (-1) * Cc(0)
  return (C(P"//" * (1 - St(newlines))^0 * match_end) * Cp()) / comment_matched
end


-- block (multi-line) comment

local function match_blockcomment_tail(subject, pos, tail)
  -- check if the subject string match the tail at the pos
  local newpos = P(tail):match(subject, pos)
  --print(pos, tail .. " matched newpos ", newpos or "nil")
  if newpos == nil then
    return false
  end
  return newpos
end

local function found_newline_in_blockcomment(i, pos)
  y.column_no = y.column_no + (pos - y.position)
  y.position = pos
  print("L"..y.line_no.."C"..y.column_no.."P"..y.position,
      "NEWLINE in BLOCKCOMMENT #" .. #newlines[i])
  y.line_no = y.line_no + 1
  y.column_no = 1
  -- return no value to avoid produce capture values
end

local function empty_blockcomment_matched(s, pos)
  return token_matched(s, pos, y.BLOCKCOMMENT)
end

local function blockcomment_matched(s, asterisk, matched, pos)
  local levels = #asterisk
  y.column_no = y.column_no + (pos - y.position)
  y.position = pos
  print(pos, "BLOCKCOMMENT"..levels, "matched "..matched, s)
  if matched ~= 1 then
    -- match failed, print error message
  end
  return y.BLOCKCOMMENT, s
end

function y.match_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "asterisk")
  local match_newline = (Cst(newlines) * Cp()) / found_newline_in_blockcomment
  local match_tail = Cmt(Cb"asterisk" / "%1/", match_blockcomment_tail)
  local capture_tail = match_tail * Cc(1) + (-1) * Cc(0)
  return (C(start * P"/") * Cp()) / empty_blockcomment_matched +
         (C(start * Cb"asterisk" * (match_newline + (1 - match_tail))^1 * capture_tail) * Cp()) / blockcomment_matched
end


-- special identifier

function y.match_special_identifier()
  return P(false)
end


-- identifier

local function identifier_matched(s, pos)
  return token_matched(s, pos, y.IDENTIFIER)
end

local function identifier()
  local letter = R("az", "AZ")
  local number = R("09")
  return (P"_" + letter) * (P"_" + letter + number)^0
end

function y.match_identifier()
  local letter = R("az", "AZ")
  local number = R("09")
  return (C(identifier()) * Cp()) / identifier_matched
end


-- string

function y.match_string()
  return P(false)
end


-- character

local function character_matched(s, pos)
  return token_matched(s, pos, y.CHARACTER)
end

function y.match_character()
  local hex = R("09", "af", "AF")
  local singlechar =  P"\\x" * hex * hex + P"\\x" * hex + P"\\" * 1 + (1 - P"'")
  return (C(P"'" * singlechar * P"'" * identifier() + P"'" * singlechar * P"'") * Cp()) / character_matched
end


-- float

local function integertail(...)
  return (P"_" + R(...))^1
end

local decimalinteger = R"09" * integertail("09") + R"09"

local function float_matched(s, pos)
  return token_matched(s, pos, y.FLOAT)
end

function y.match_float()
  local exponent = P"e+" + P"E+" + P"e-" + P"E-" + S"eE"
  local decimalfloat = decimalinteger * P"." * integertail("09") * exponent * integertail("09") +
      decimalinteger * P"." * integertail("09")
  return (C(decimalfloat * identifier() + decimalfloat) * Cp()) / float_matched
end


-- integer

local function integer_matched(s, pos)
  return token_matched(s, pos, y.INTEGER)
end

function y.match_integer()
  local binaryinteger = (P"0b" + P"0B") * integertail("01")
  local octalinteger = (P"0o" + P"0O") * integertail("07")
  local hexinteger = (P"0x" + P"0X") * integertail("09", "af", "AF")
  return (C(binaryinteger * identifier() + binaryinteger +
      decimalinteger * identifier() + decimalinteger +
      octalinteger * identifier() + octalinteger +
      hexinteger * identifier() + hexinteger) * Cp()) / integer_matched
end


-- special operator

function y.match_special_operator()
  return P(false)
end


-- operator

local function operator_matched(s, pos)
  return token_matched(s, pos, y.OPERATOR)
end

function y.match_operator()
  return (C(S"`~!@#$%^&*-+=|'\":;<,>.?/"^1) * Cp()) / operator_matched
end


-- backslash can only appear in comment, char and string

local function backslash_matched(s, pos)
  return token_matched(s, pos, y.BACKSLASH)
end

function y.match_backslash()
  return (C(P"\\"^1) * Cp()) / backslash_matched
end


-- bracket

local function bracket_matched(s, pos)
  return token_matched(s, pos, y.BRACKET)
end

function y.match_bracket()
  return (C(S"(){}[]") * Cp()) / bracket_matched
end


-- test

local function ltest(expr, value)
  if expr == value then
    return true
  end
  print("ltest failure: " .. tostring(expr) .. " not equal to " .. tostring(value))
  return false
end

do
  local patt = y.match_keyword() + y.match_space() + y.match_newline() + y.match_comment() +
      y.match_blockcomment() + y.match_string() + y.match_character() + y.match_special_identifier() +
      y.match_identifier() + y.match_float() + y.match_integer() + y.match_special_operator() +
      y.match_operator() + y.match_backslash() + y.match_bracket()
  local subject =
      "[SP] \t  [NL]\r\n[NL]\n\r[NL]\r[NL]\n" ..
      "[KW]bool[SP]  [KW]char[KW]int[SP] " ..
      "[ID]adbed[ID]_ade[ID]_01d[ID]a0__[ID]adf_00[SP] " ..
      "[CM]//\n[SP]  [CM]//adbcd\n" ..
      "[BC]/*/[BC]/**/[BC]/***/[BC]/** ***/[BC]/*** ***/[BC]/** ad\nbc \n**/[BC]/*\n\n**/[BC]/**abc***/" ..
      "[CH]'a'[CH]'\\b'[CH]'\\x0'[CH]'\\xFF'[CH]'a'_0a[CH]'\\b'_0b[CH]'\\x0'_0c[CH]'\\xFF'_0d"

  local hint, t, s
  y.reset()

  while true do
    t, s = patt:match(subject, y.position)
    if t == nil then break end
    assert(ltest(s,"["))
    t, s = patt:match(subject, y.position)
    if t == nil then print"no hint" break end
    hint = s
    t, s = patt:match(subject, y.position)
    if t == nil then print"no ]" break end
    assert(ltest(s, "]"))
    t, s = patt:match(subject, y.position)
    if t == nil then print"no value" break end
    assert(ltest(t.h, hint))
  end
end

return y

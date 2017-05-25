
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
  token_type = INVALIDTOKEN;
}

function y.reset()
  y.line_no = 1
  y.column_no = 1
  y.position = 1
  y.token_string = ""
  y.token_type = y.INVALIDTOKEN
end

function y.print_out()
  print("L"..y.line_no.." C"..y.column_no.." P"..y.position,
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

local Lcontext = {
  tkstring = ""
  startpos = 1
  nextpos = 1
  
  tokenlineno = 1;
  tokencolumn = 1;
  lineno = 1;
  column = 1;
  blanklist = nil;
  blanktail = nil;
}

local Pstartmatch = P(function () {
  Lcontext.tokenlineno = Lcontext.lineno
  Lcontext.tokencolumn = Lcontext.column
})

--[[token:
  type = Lcontext.KEYWORD;
  tokenstr = "";
  startpos = 1;
  lineno = 1;
  column = 1;
  occupiedlines = 1;
  tailingblank = nil; -- will pointer to SPACE or NEWLINE
]]

local function LfuncNewToken(tokentype, str, start)
  local tbl = {
    type = tokentype;
    tokenstr = str;
    startpos = start;
    lineno = Lcontext.tokenlineno;
    column = Lcontext.tokencolumn;
    occupiedlines = 1;
    tailingblank = nil;
  }
  if tokentype ~= Lcontext.SPACE and tokentype ~= Lcontext.NEWLINE then
    tbl.tailingblank = Lcontext.blanklist
    Lcontext.blanklist = nil
    Lcontext.blanktail = nil
    return tbl
  end
  if Lcontext.blanklist == nil then
    Lcontext.blanklist = tbl
    Lcontext.blanktail = tbl
  else
    Lcontext.blanktail.tailingblank = tbl
    Lcontext.blanktail = tbl
  end
  return tbl
end


-- space

function space_matched(s, pos)
  return token_matched(s, pos, y.SPACE)
end

local space = S"\x20\x09\x0B\x0C"

function y.match_space()
  return (C(space^1) * Cp()) / space_matched
end

local Cspace = C(S"\x20\x09\x0B\x0C"^1)

local Pspace = (Pstartmatch * Cp() * Cspace) / function (startpos, tokenstr)
  LfuncNewToken(Lcontext.SPACE, startpos, tokenstr) -- space token is stored in the blanklist
  return nil                                        -- return no capture value for space
end

-- newline

local function mtfunc_capture_newline(subject, pos, i)
  y.column_no = y.column_no + (pos - y.position)
  y.position = pos
  print("L"..y.line_no.." C"..y.column_no.." P"..y.position, "\tCAPTURE NEWLINE #" .. #newlines[i])
  y.line_no = y.line_no + 1
  y.column_no = 1
  return pos
end

local capture_newline = Cmt(Cst(newlines), mtfunc_capture_newline)

local function newline_matched(i, pos)
  return token_matched(newlines[i], pos, y.NEWLINE)
end

function y.match_newline()
  return (Cst(newlines) * Cp()) / newline_matched
end

local Cnewline = Cmt(Cst(newlines), function (subject, curpos, i)
  Lcontext.lineno = Lcontext.lineno + 1
  Lcontext.column = 1
  return curpos, newlines[i]
end) 

local Pnewline = (Pstartmatch * Cp() * Cnewline) / function (startpos, tokenstr)
  LfuncNewToken(Lcontext.NEWLINE, startpos, tokenstr) -- newline token is stored in the blanklist
  return nil                                          -- return no capture value for newline
end

local Pblankopt = (Pnewline + Pspace)^1 + P""

-- keyword

local function keyword_matched(i, pos)
  return token_matched(keywords[i], pos, y.KEYWORD)
end

function y.match_keyword()
  return (Cst(keywords) * Cp()) / keyword_matched
end

local Ckeyword = Cst(keywords) / function (i) return keywords[i] end

local LKeyword = (Pstartmatch * Cp() * Ckeyword * Pblankopt) / function (startpos, tokenstr, blank)
  return LfuncNewToken(Lcontext.KEYWORD, startpos, tokenstr)
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

local function mtfunc_simplematch(subject, pos, str)
  local newpos = P(str):match(subject, pos)
  --print(pos, str .. " matched newpos ", newpos or "nil")
  if newpos == nil then
    return false
  end
  return newpos
end

local function empty_blockcomment_matched(s, pos)
  return token_matched(s, pos, y.BLOCKCOMMENT)
end

local function blockcomment_matched(s, asterisk, matched, pos)
  local levels = #asterisk
  y.column_no = y.column_no + (pos - y.position)
  y.position = pos
  print("L"..y.line_no.." C"..y.column_no.." P"..y.position,
      "BLOCKCOMMENT"..levels, "matched "..matched, "#"..#s..":"..s)
  if matched ~= 1 then
    -- match failed, print error message
  end
  return y.BLOCKCOMMENT, s
end

function y.match_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "asterisk")
  local match_tail = Cmt(Cb"asterisk" / "%1/", mtfunc_simplematch)
  local capture_tail = match_tail * Cc(1) + (-1) * Cc(0)
  return (C(start * P"/") * Cp()) / empty_blockcomment_matched +
         (C(start * Cb"asterisk" * (capture_newline + (1 - match_tail))^1 * capture_tail) * Cp()) / blockcomment_matched
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
  return (C(identifier()) * Cp()) / identifier_matched
end


-- string

local function integertail(...)
  return (P"_" + R(...))^1
end

local decimalinteger = R"09" * integertail("09") + R"09"

local punct = R("\x21\x2F", "\x3A\x40", "\x5B\x60", "\x7B\x7E")

local hexdigit = R("09", "af", "AF")

local escape_char = P"\\x" * hexdigit * hexdigit + P"\\x" * hexdigit + P"\\" * 1

local function string_matched(s, success, pos)
  if success ~= 1 then
    -- match failed
  end
  return token_matched(s, pos, y.STRING)
end

local function hexstr_matched(s, success, pos)
  if success ~= 1 then
    -- match failed
    print("\t\t\tINVALID HEX STRING")
  end
  return token_matched(s, pos, y.STRING)
end

function y.match_string()
  local tag = Cg(P"'"^3 + P'"'^3, "strtag")
  local match_tag = Cmt(Cb"strtag", mtfunc_simplematch)
  local emptystr = P'""' + P"''"

  local function normalquotetail(t)
    return (escape_char + (1 - t))^1 * ((t * identifier() + t) * Cc(1) + (-1) * Cc(0))
  end

  local multiquote = (S"sS" * tag + tag) * normalquotetail(match_tag)
  local emptyquote = ((S"sS" * emptystr + emptystr) * (identifier() + P"")) * Cc(1)
  local squote, dquote = P"'", P'"'
  local singlequote = S"sS" * squote * normalquotetail(squote)
  local doublequote = (S"sS" * dquote + dquote) * normalquotetail(dquote)
  local normalstr = (C(multiquote + emptyquote + singlequote + doublequote) * Cp()) / string_matched

  local hexstrchar = space + punct + hexdigit
  local function hexquotetail(t)
    return (hexstrchar - t)^1 * ((t * identifier() + t) * Cc(1) + ((1 - t)^1 * (t + (-1))) * Cc(0))
  end
  multiquote = tag * hexquotetail(match_tag)
  emptyquote = (emptystr * identifier() + emptystr) * Cc(1)
  singlequote = squote * hexquotetail(squote)
  doublequote = dquote * hexquotetail(dquote)
  return normalstr + (C(S"xX" * (multiquote + emptyquote + singlequote + doublequote)) * Cp()) / hexstr_matched
end

local function rawstring_matched(s, success, pos)
  if success ~= 1 then
    -- match failed
    print("\t\t\tINVALID RAW STRING")
  end
  return token_matched(s, pos, y.STRING)
end

-- Example - r"{}" r''2{a}'' r'tag{a}tag'int r""$${a}""bool r"2tag!!{a\nb}tag" R'zz{}zz'bool r""a"" R''b''int
-- Invalid - r"<NL> r'abc<NL> R'<NL> R"abc<NL> r""<NL> R''a<NL>
function y.match_rawstring()
  local function mtfunc_match2endtag(subject, pos, quotes, num, tag, op)
    print("\t\t\tQUOTES "..quotes.."\n\t\t\tNUM "..num.."\n\t\t\tTAG "..tag.."\n\t\t\tOP "..op)
    local endtag = P("}"..tag..quotes)
    local patt = (capture_newline + (1 - endtag))^0 * (endtag * (identifier() + P"") * Cp() * Cc(1) + (-1) * Cp() * Cc(0))
    return patt:match(subject, pos)
  end

  local function mtfunc_match2quotes(subject, pos, quotes)
    print("\t\t\tQUOTES "..quotes)
    local ending = St(newlines) + P(quotes)
    local patt = (1 - ending)^0 * (P(quotes) * (identifier() + P"") * Cp() * Cc(1) + (capture_newline + (-1)) * Cp() * Cc(0))
    return patt:match(subject, pos)
  end

  local quotes = C(P'"' + P"'")
  local num, tag, op = decimalinteger, identifier(), (punct - "{")^1
  local ntagop = C(num + P"") * C(tag + P"") * C(op + P"") * "{"
  local match2endtag = Cg(quotes * ntagop, "qntagop") * Cmt(Cb"qntagop", mtfunc_match2endtag)
  local match2quotes = Cg(quotes, "quotes") * Cmt(Cb"quotes", mtfunc_match2quotes)
  local patt = S"rR" * (match2endtag + match2quotes)
  return (C(patt) * Cp()) / rawstring_matched
end


-- character

local function character_matched(s, success, pos)
  if success ~= 1 then
    print("\t\t\tINVALID CHARACTER")
  end
  return token_matched(s, pos, y.CHARACTER)
end

-- Special - '' is not a character, it is a empty string
-- Example - '\n' 'a' '\xF' '\xFF' 'a'int 'a'bool
-- Invalid - '<NL> 'a<NL> 'ab<NL> 'ab' 'abc' 'abc'int
function y.match_character()
  local endchar = St(newlines) + P"'"
  local char = escape_char + (1 - endchar)
  local succ = char * P"'" * (identifier() + P"")
  local fail = char^1 * P"'" * (identifier() + P"") + char^0 * (capture_newline + (-1))
  local patt = P"'" * (succ * Cc(1) + fail * Cc(0))
  return (C(patt) * Cp()) / character_matched
end


-- float

local function float_matched(s, pos)
  return token_matched(s, pos, y.FLOAT)
end

local identifier_tail = P"'" * identifier() + identifier()

function y.match_float()
  local exponent = P"e+" + P"E+" + P"e-" + P"E-" + S"eE"
  local decimalfloat = decimalinteger * P"." * integertail("09") * exponent * integertail("09") +
      decimalinteger * P"." * integertail("09")
  return (C(decimalfloat * identifier_tail + decimalfloat) * Cp()) / float_matched
end


-- integer

local function integer_matched(s, identifier_tail, pos)
  if y.invalid_integer == 1 then
    print("\t\t\tTAIL:"..identifier_tail.."\tINVALID INTEGER")
  else
    print("\t\t\tTAIL:"..identifier_tail)
  end
  y.invalid_integer = 0
  return token_matched(s, pos, y.INTEGER)
end

local function match_integerdigit(subject, pos, value)
  if value == 0 then
    y.invalid_integer = 1
  end
  return pos
end

function y.match_integer()
  local binarytail = Cmt(P"_" * Cc(1) + R"01" * Cc(2) + R"29" * Cc(0), match_integerdigit)^1
  local octaltail = Cmt(P"_" * Cc(1) + R"07" * Cc(2) + R"89" * Cc(0), match_integerdigit)^1
  local binaryinteger = (P"0b" + P"0B") * binarytail
  local octalinteger = (P"0o" + P"0O") * octaltail
  local hexinteger = (P"0x" + P"0X") * integertail("09", "af", "AF")
  return (C(binaryinteger * C(identifier_tail) + binaryinteger * Cc("") +
      octalinteger * C(identifier_tail) + octalinteger * Cc("") +
      hexinteger * C(identifier_tail) + hexinteger * Cc("") +
      decimalinteger * C(identifier_tail) + decimalinteger * Cc("")) * Cp()) / integer_matched
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
      y.match_blockcomment() + y.match_string() + y.match_rawstring() + y.match_character() +
      y.match_special_identifier() + y.match_identifier() + y.match_float() + y.match_integer() +
      y.match_special_operator() + y.match_operator() + y.match_backslash() + y.match_bracket()
  local subject =
      "[SP] \t  [SP]\x20 \t[SP]\x09 \t[SP]\x0B \t[SP]\x0C \t" ..
      "[NL]\r\n[NL]\n\r[NL]\r[NL]\n[NL]\x00[NL]\x1A" ..
      "[KW]bool[SP]  [KW]char[KW]int[SP] " ..
      "[ID]adbed[ID]_ade[ID]_01d[ID]a0__[ID]adf_00[SP] " ..
      "[CM]//\n[SP]  [CM]//adbcd\n[CM]/////\n[CM]////\n" ..
      "[BC]/*/[BC]/**/[BC]/***/[BC]/** ***/[BC]/*** ***/[BC]/** ad\nbc \n**/[BC]/*\n\n**/[BC]/**abc***/" ..
      "[CH]'a'[CH]'\\b'[CH]'\\x0'[CH]'\\xFF'[CH]'a'_0a[CH]'\\b'_0b[CH]'\\x0'_0c[CH]'\\xFF'_0d" ..
      "[CH]'\\n'[CH]'a'int[CH]'b'bool[CH]'\n[CH]'a\n[CH]'ab\n[CH]'ab'[CH]'abc'[CH]'ab'int[CH]'abc'bool" ..
      "[FL]0._[FL]1_000.0_[FL]1_._byte[FL]0.0_int[FL]3.14e_[FL]3.14e_1_int[FL]3.14E-_int[FL]3.14E+10_000_abc" ..
      "[IN]0012[IN]00_001_[IN]0_0_123_[IN]0[IN]0_[IN]0__[IN]0__1[IN]0__1_" ..
      "[IN]0x_[IN]0x__[IN]0x_0[IN]0x_0_[IN]0x0A_FB_[IN]0X_[IN]0X0_FBAC_ABCD_" ..
      "[IN]0b_[IN]0b__[IN]0b__0[IN]0b__0_[IN]0b1101_1101_[IN]0B11_01_[IN]0b12_39_87_10" ..
      "[IN]0o_[IN]0o_0[IN]0o_0_[IN]0o473_324_[IN]0O_[IN]0O_0[IN]0O111_222__[IN]0o789_887_777" ..
      "[IN]0012abc[IN]00_001_abc[IN]0abc[IN]0_abc[IN]0b_a[IN]0b__0a[IN]0b00_01b[IN]0o_b[IN]0O777_abc" ..
      "[IN]0x__aint[IN]0X0F_abcbool[IN]0xFF01km[IN]0xFF0A'alpha[IN]0x1101'double" ..
      "[ST]\"\"[ST]''[ST]\"s\"[ST]\"\"\"a\"\"\"[ST]'''b'''[ST]''''c''''[ST]s'\"'[ST]\"'\"[ST]'''\"'''" ..
      "[ST]S\"\"[ST]s''[ST]s\"s\"[ST]s\"\"\"a\"\"\"[ST]S'''b'''[ST]S''''c''''[ST]s'a'[ST]S'b'[ST]S\"'\"[ST]s'''\"'''" ..
      "[ST]x''[ST]x\"\"[ST]X\"012345678 9ABC DE F\"[ST]x'''a'''[ST]X''''b''''[ST]\"\"\"'\"\"\"[ST]S\"\"\"'\"\"\"" ..
      "[ST]x''[ST]x'a'[ST]X'012345678 9ABC DE F'[ST]x'\"'[ST]X\"'\"[ST]x'''\"'''[ST]X\"\"\"'\"\"\"" ..
      "[ST]x'AB CD Z EF'[ST]x'0113 AEFC ghaf'[ST]r''[ST]r\"\"[ST]R''[ST]R\"\"[ST]r'{}'[ST]R\"{}\"" ..
      "[ST]r'{}'[ST]R\"{}\"[ST]R'2zzz!!{abc}zzz'[ST]r'tag{b}tag'[ST]r'tag@{c}tag'[ST]R'aaa!!{}aaa'" ..
      "[ST]r\"{}\"[ST]r'2{a}'[ST]r'tag{a}tag'int[ST]r\"$${a}\"bool[ST]r\"2tag!!{a\nb}tag\"[ST]R'zz{}zz'bool[ST]r\"a\"[ST]R'b'int" ..
      "[ST]r\"\n[ST]r'abc\n[ST]R'\n[ST]R\"abc\n[ST]r\"\n[ST]R'a\n"


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

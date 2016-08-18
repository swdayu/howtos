
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

local y = {lineno = 1; colno = 1; curpos = 1}

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

local keyword = {
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

local newline = {
  "\x0D",
  "\x0A",
  "\x0A\x0D",
  "\x0D\x0A",
  "\x00",
  "\x1A",
  "\xFE\xBF",
  --toUtf8(0x2028),
  --toUtf8(0x2029)
}

local KEYWORD = 1
local SPACE = 2
local NEWLINE = 3
local COMMENT = 4
local BLOCKCOMMENT = 5

local function f_keyword(i)
  --token(KEYWORD, i)
  local kw = keyword[i]
  y.colno = y.colno + #kw
  y.curpos = y.curpos + #kw
  print(y.lineno .. ":" .. y.colno, "KEYWORD", kw)
  return kw
end

local function f_space(s)
  --token(SPACE, s)
  y.colno = y.colno + #s
  y.curpos = y.curpos + #s
  print(y.lineno .. ":" .. y.colno, "SPACE")
  return s
end

local function f_newline(i)
  --token(NEWLINE, i)
  local nl = newline[i]
  y.colno = y.colno + #nl
  y.curpos = y.curpos + #nl
  print(y.lineno .. ":" .. y.colno, "NEWLINE")
  y.lineno = y.lineno + 1
  y.colno = 1
  return nl
end

local function f_comment(s)
  --token(COMMENT, s)
  y.colno = y.colno + #s
  y.curpos = y.curpos + #s
  print(y.lineno .. ":" .. y.colno, "COMMENT")
  y.lineno = y.lineno + 1
  y.colno = 1
  return s
end


local function l_keyword()
  return Cst(keyword) / f_keyword
end

local function l_space()
  return S"\x20\x09\x0B\x0C"^1 / f_space
end

local function l_newline()
  return Cst(newline) / f_newline
end

local function l_comment()
  return (P"//" * (1-St(newline))^0 * St(newline)) / f_comment
end

local function f_matchtime(deststr, pos, val)
  local newpos = P(val.."/"):match(deststr, pos)
  -- print(deststr, pos, "match " .. val .. " newpos " .. (newpos or "nil"))
  if newpos == nil then
    return nil
  end
  return newpos
end

local function f_blockcomment(s)
  --token(BLOCKCOMMENT, stars, content)
  local i, len = 1, #s
  local tableidx, pos_after_newline = 1, 1
  local has_newline = false
  while i <= len do
    if lpeg.match(#St(newline), s, i) == nil then
      i = i + 1
    else
      tableidx, pos_after_newline = lpeg.match(Cst(newline)*Cp(), s, i)
      assert(tableidx ~= nil and pos_after_newline ~= nil)
      i = i + tableidx
      y.lineno = y.lineno + 1
      y.colno = 1
      has_newline = true
    end 
  end
  if has_newline then
    y.colno = y.colno + (len + 1 - pos_after_newline)
  else
    y.colno = y.colno + len
  end
  print(y.lineno .. ":" .. y.colno, "BLOCKCOMMENT", s)
  y.curpos = y.curpos + len
  return s
end

local function l_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "commentstart")
  local tail = Cb"commentstart"
  return (start * P"/" + start * (1 - Cmt(tail, f_matchtime))^1 * Cmt(tail, f_matchtime)) / f_blockcomment
end


```

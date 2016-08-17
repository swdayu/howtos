
```lua
local lpeg = require "lpeg"

function lpeg.St(t)
  local patt = lpeg.P("")
  for _,v in ipairs(t) do
    patt = patt + lpeg.P(v)
  end
  return patt
end

function lpeg.Cst(t)
  local patt = lpeg.P("")
  for i,v in ipairs(t) do
    patt = patt + lpeg.P(v) * lpeg.Cc(i)
  end
  return patt
end

local y = {}

local keyword = {
  "void", "null",
  "bool", "true", "false",
  "byte", "int8",
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
  toUtf8(0x2028),
  toUtf8(0x2029)
}

local KEYWORD = 1
local SPACE = 2
local NEWLINE = 3
local COMMENT = 4
local BLOCKCOMMENT = 5

local function f_keyword(i)
  token(KEYWORD, i)
  return keyword[i]
end

local function f_space(s)
  token(SPACE, s)
  return s
end

local function f_newline(i)
  token(NEWLINE, i)
  return newline[i]
end

local function f_comment(s)
  token(COMMENT, s)
  return s
end


local function l_keyword()
  return Cst(keyword) / f_keyword
end

local function l_space()
  return S("\x20\x09\x0B\x0C")^1 / f_space
end

local function l_newline()
  return Cst(newline) / f_newline
end

local function l_comment()
  return (P("//") * (1-St(eof))^0 * St(eof)) / f_comment
end

local function f_matchtime(deststr, pos, val)
  local newpos = P(val):match(deststr, pos)
  -- print(deststr, pos, "match " .. val .. " newpos " .. (newpos or "nil"))
  if newpos == nil then
    return nil
  end
  return newpos
end

local function f_blockcomment(stars, content)
  token(BLOCKCOMMENT, starts, content)
  if content == "/" then
    return "/" .. starts .. "/"
  end
  return "/" .. starts .. content .. starts .. "/"
end

local function l_blockcomment()
  local start = Cg(P"/" * C(P"*"^1), "commentstart")
  local tail = Cb("commentstart") / "%1/"
  return (start * (Cb("commentstart")/1) * (C"/" + C((1-Cmt(tail, f_matchtime))^1) * Cmt(tail, f_matchtime))) / f_blockcomment
end

```

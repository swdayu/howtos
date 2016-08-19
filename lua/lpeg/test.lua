local lpeg = require "lpeg"

local function ltest(expr, value)
  if expr == value then
    return true
  end
  print("ltest failure: " .. tostring(expr) .. " not equal to " .. tostring(value))
  return false
end


-- Basic Match

matchString = lpeg.P("abc")
matchFourCharacters = lpeg.P(4) -- positive number
matchZeroCharacters = lpeg.P(0) -- always success
matchSuccess = lpeg.P(true)
matchFail = lpeg.P(false)

result = lpeg.match(matchString, "")
assert(ltest(result, nil))
result = lpeg.match(matchString, "ab")
assert(ltest(result, nil))
result = lpeg.match(matchString, "abc")
assert(ltest(result, 4))
result = lpeg.match(matchString, "abcd")
assert(ltest(result, 4))
result = lpeg.match(matchString, "xabc")
assert(ltest(result, nil))
result = lpeg.match(matchString, "xabc", 2)
assert(ltest(result, 5))
result = lpeg.match(matchString, "xabcd", 2)
assert(ltest(result, 5))
result = lpeg.match(matchString, "xabcd", 6)
assert(ltest(result, nil))
result = lpeg.match(matchString, "xabcd", 7)
assert(ltest(result, nil))

result = lpeg.match(matchFourCharacters, "")
assert(ltest(result, nil))
result = lpeg.match(matchFourCharacters, "abc")
assert(ltest(result, nil))
result = lpeg.match(matchFourCharacters, "abcd")
assert(ltest(result, 5))
result = lpeg.match(matchFourCharacters, "abcde")
assert(ltest(result, 5))
result = lpeg.match(matchFourCharacters, "abcdef")
assert(ltest(result, 5))
result = lpeg.match(matchFourCharacters, "abcdefg", 2)
assert(ltest(result, 6))
result = lpeg.match(matchFourCharacters, "abcdefg", 8)
assert(ltest(result, nil))
result = lpeg.match(matchFourCharacters, "abcdefg", 9)
assert(ltest(result, nil))

result = lpeg.match(matchZeroCharacters, "")
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharacters, "a")
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharacters, "ab")
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharacters, "abcd", 3)
assert(ltest(result, 3))
result = lpeg.match(matchZeroCharacters, "abcd", 5)
assert(ltest(result, 5))
result = lpeg.match(matchZeroCharacters, "abcd", 6)
assert(ltest(result, 5))

result = lpeg.match(matchSuccess, "")
assert(ltest(result, 1))
result = lpeg.match(matchSuccess, "a")
assert(ltest(result, 1))
result = lpeg.match(matchSuccess, "ab", 2)
assert(ltest(result, 2))
result = lpeg.match(matchSuccess, "ab", 3)
assert(ltest(result, 3))
result = lpeg.match(matchSuccess, "ab", 4)
assert(ltest(result, 3))

result = lpeg.match(matchFail, "")
assert(ltest(result, nil))
result = lpeg.match(matchFail, "a")
assert(ltest(result, nil))
result = lpeg.match(matchFail, "a", 2)
assert(ltest(result, nil))
result = lpeg.match(matchFail, "a", 3)
assert(ltest(result, nil))


-- Matched Before Or Not

matchStringBefore = lpeg.B(matchString)
matchFourCharactersBefore = lpeg.B(matchFourCharacters)
matchZeroCharactersBefore = lpeg.B(matchZeroCharacters)

result = lpeg.match(matchStringBefore, "abc", 3)
assert(ltest(result, nil))
result = lpeg.match(matchStringBefore, "abc", 4)
assert(ltest(result, 4))
result = lpeg.match(matchStringBefore, "abc", 5)
assert(ltest(result, 4))
result = lpeg.match(matchStringBefore, "zabc", 4)
assert(ltest(result, nil))
result = lpeg.match(matchStringBefore, "zabc", 5)
assert(ltest(result, 5))

result = lpeg.match(matchFourCharactersBefore, "abc", 4)
assert(ltest(result, nil))
result = lpeg.match(matchFourCharactersBefore, "abcd", 4)
assert(ltest(result, nil))
result = lpeg.match(matchFourCharactersBefore, "abcd", 5)
assert(ltest(result, 5))

result = lpeg.match(matchZeroCharactersBefore, "")
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharactersBefore, "", 2)
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharactersBefore, "abc", 1)
assert(ltest(result, 1))
result = lpeg.match(matchZeroCharactersBefore, "abc", 2) -- at pos 2 can match zero characters
assert(ltest(result, 2))
result = lpeg.match(matchZeroCharactersBefore, "abc", 3)
assert(ltest(result, 3))


-- Match Predicate (Positive)

result = lpeg.match(#matchString, "zzabc")
assert(ltest(result, nil))
result = lpeg.match(#matchString, "zzabc", 3)
assert(ltest(result, 3))
result = lpeg.match(#matchString, "zzabc", 4)
assert(ltest(result, nil))

result = lpeg.match(#matchFourCharacters, "abcde")
assert(ltest(result, 1))
result = lpeg.match(#matchFourCharacters, "abcde", 2)
assert(ltest(result, 2))
result = lpeg.match(#matchFourCharacters, "abcde", 3)
assert(ltest(result, nil))

result = lpeg.match(#matchZeroCharacters, "")
assert(ltest(result, 1))
result = lpeg.match(#matchZeroCharacters, "a")
assert(ltest(result, 1))
result = lpeg.match(#matchZeroCharacters, "a", 2)
assert(ltest(result, 2))
result = lpeg.match(#matchZeroCharacters, "a", 3)
assert(ltest(result, 2))


-- Match Predicate (Negative)

result = lpeg.match(-matchString, "zzabc")
assert(ltest(result, 1))
result = lpeg.match(-matchString, "zzabc", 3)
assert(ltest(result, nil))
result = lpeg.match(-matchString, "zzabc", 4)
assert(ltest(result, 4))

result = lpeg.match(-matchFourCharacters, "abcde")
assert(ltest(result, nil))
result = lpeg.match(-matchFourCharacters, "abcde", 2)
assert(ltest(result, nil))
result = lpeg.match(-matchFourCharacters, "abcde", 3)
assert(ltest(result, 3))

result = lpeg.match(-matchZeroCharacters, "")
assert(ltest(result, nil))
result = lpeg.match(-matchZeroCharacters, "a")
assert(ltest(result, nil))
result = lpeg.match(-matchZeroCharacters, "a", 2)
assert(ltest(result, nil))
result = lpeg.match(-matchZeroCharacters, "a", 3)
assert(ltest(result, nil))


-- Match a Character in a Character Range

matchAtoZ = lpeg.R("AZ")
result = lpeg.match(matchAtoZ, "")
assert(ltest(result, nil))
result = lpeg.match(matchAtoZ, "A")
assert(ltest(result, 2))
result = lpeg.match(matchAtoZ, "Xaa")
assert(ltest(result, 2))


-- Match a Character in a Character Set

matchOperators = lpeg.S("+-*/")
result = lpeg.match(matchOperators, "+")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "-")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "*")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "/zzz")
assert(ltest(result, 2))


-- Ordered Choice

matchAB = lpeg.P("ab")
matchCD = lpeg.P("cd")
matchABC = lpeg.P("abc")

result = lpeg.match(matchAB + matchCD, "zabcd") -- match "ab" first, if failed then re-match "cd" again
assert(ltest(result, nil))
result = lpeg.match(matchAB + matchCD, "zabcd", 2)
assert(ltest(result, 4))
result = lpeg.match(matchAB + matchCD, "zabcd", 4)
assert(ltest(result, 6))
result = lpeg.match(matchAB + matchCD, "cd")
assert(ltest(result, 3))

result = lpeg.match(matchABC + matchAB, "abcd")
assert(ltest(result, 4))
result = lpeg.match(matchAB + matchABC, "abcd")
assert(ltest(result, 3))


-- Continue Match

result = lpeg.match(matchAB * matchCD, "abcde")  -- match "ab" and then match "cd"
assert(ltest(result, 5))
result = lpeg.match(-matchABC * matchAB, "abcd") -- current doesn't match "abc" and then match "ab"
assert(ltest(result, nil))
result = lpeg.match(-matchABC * matchAB, "abzz")
assert(ltest(result, 3))


-- Repetition

matchZeroOrMore = lpeg.P(matchAB^0)
matchOneOrMore = lpeg.P(matchAB^1)
matchTwoOrMore = lpeg.P(matchAB^2)
matchZeroOrOne = lpeg.P(matchAB^-1)
matchThreeAtMost = lpeg.P(matchAB^-3)

result = matchZeroOrMore:match("")
assert(ltest(result, 1))
result = matchZeroOrMore:match("acc")  -- zero time matched
assert(ltest(result, 1))
result = matchZeroOrMore:match("zab")  -- zero time matched
assert(ltest(result, 1))
result = matchZeroOrMore:match("abzz")
assert(ltest(result, 3))
result = matchZeroOrMore:match("ababz")
assert(ltest(result, 5))
result = matchZeroOrMore:match("zab")
assert(ltest(result, 1))

result = matchOneOrMore:match("")
assert(ltest(result, nil))
result = matchOneOrMore:match("zzz")
assert(ltest(result, nil))
result = matchOneOrMore:match("zab")
assert(ltest(result, nil))
result = matchOneOrMore:match("abz")
assert(ltest(result, 3))
result = matchOneOrMore:match("abababz")
assert(ltest(result, 7))

result = matchTwoOrMore:match("")
assert(ltest(result, nil))
result = matchTwoOrMore:match("aaa")
assert(ltest(result, nil))
result = matchTwoOrMore:match("ab")
assert(ltest(result, nil))
result = matchTwoOrMore:match("ababz")
assert(ltest(result, 5))
result = matchTwoOrMore:match("abababab")
assert(ltest(result, 9))

result = matchZeroOrOne:match("")   -- zero time matched
assert(ltest(result, 1))
result = matchZeroOrOne:match("az") -- zero time matched
assert(ltest(result, 1))
result = matchZeroOrOne:match("ab")
assert(ltest(result, 3))
result = matchZeroOrOne:match("abab")
assert(ltest(result, 3))

result = matchThreeAtMost:match("")   -- zero time matched
assert(ltest(result, 1))
result = matchThreeAtMost:match("az") -- zero time matched
assert(ltest(result, 1))
result = matchThreeAtMost:match("ab")
assert(ltest(result, 3))
result = matchThreeAtMost:match("abab")
assert(ltest(result, 5))
result = matchThreeAtMost:match("ababab")
assert(ltest(result, 7))
result = matchThreeAtMost:match("abababab")
assert(ltest(result, 7))


-- Grammar

matchBalancedParenthesizedExpr = lpeg.P{
  "S",                                               -- this is initial symbol
  S = "(" * ((-lpeg.S"()" * 1) + lpeg.V"S")^0 * ")"  -- if "(" then need recursively match a "()" next
}                                                    -- if ")" lpeg.V"S" will match failed, but next will match ")" success

result = matchBalancedParenthesizedExpr:match("(")
assert(ltest(result, nil))
result = matchBalancedParenthesizedExpr:match(")")
assert(ltest(result, nil))
result = matchBalancedParenthesizedExpr:match("()")
assert(ltest(result, 3))
result = matchBalancedParenthesizedExpr:match("(()")
assert(ltest(result, nil))
result = matchBalancedParenthesizedExpr:match("()))")
assert(ltest(result, 3))
result = matchBalancedParenthesizedExpr:match("(())))")
assert(ltest(result, 5))


-- Simple Capture

-- the rule of values returned:
-- if the pattern matched failed then
--   return nil
-- end
-- if no captures in the pattern || no values captured then
--   return the position after the matched substring
-- end
-- return captured values
captureZeroOrOneA = lpeg.C(lpeg.P"a"^-1)
result = captureZeroOrOneA:match""
assert(ltest(result, ""))
result = captureZeroOrOneA:match"az"
assert(ltest(result, "a"))
result = captureZeroOrOneA:match"aa"
assert(ltest(result, "a"))
result = captureZeroOrOneA:match("za")
assert(ltest(result, ""))

captureAinPatt = lpeg.C("a")^-1
result = captureAinPatt:match("")
assert(ltest(result, 1))             -- if capture failed will return normal match result
result = captureAinPatt:match("aaa")
assert(ltest(result, "a"))


-- Argument Capture

captureFirstExtraArg = lpeg.Carg(1)                         -- related pattern match empty string
result = captureFirstExtraArg:match("", 1, 213, "arg2")
assert(ltest(result, 213))
result = captureFirstExtraArg:match("a", 1, "arg1")
assert(ltest(result, "arg1"))
result = captureFirstExtraArg:match("a", 4, 3.14)           -- must have at least 1 extra argument
assert(ltest(result, 3.14))

captureSecondExtraArg = lpeg.Carg(2)
result = captureSecondExtraArg:match("", 1, "arg1", "arg2")
assert(ltest(result, "arg2"))
result = captureSecondExtraArg:match("", 1, "arg1", 6.28)   -- must have at least 2 extra arguments
assert(ltest(result, 6.28))


-- Constant Capture


constantCapture = lpeg.Cc("value1", 2, 3)                   -- related pattern match empty string
res1, res2 = constantCapture:match("")
assert(ltest(res1, "value1"))
assert(ltest(res2, 2))
result = constantCapture:match("abc")
assert(ltest(result, "value1"))


-- Position Capture

positionCapture = lpeg.Cp() * lpeg.P("abc") * lpeg.Cp()     -- related pattern match empty string
res1, res2 = positionCapture:match"abcdefghij"
assert(ltest(res1, 1))
assert(ltest(res2, 4))
res1, res2 = positionCapture:match"zzabc"                   -- return number only when the entire pattern success
assert(ltest(res1, nil))
assert(ltest(res2, nil))
res1, res2 = positionCapture:match"abzzz"
assert(ltest(res1, nil))
assert(ltest(res2, nil))


-- String Capture

normalCapture = lpeg.C("ab") * lpeg.P("z") * lpeg.C("c") * lpeg.P("x")
stringCapture = normalCapture / "%% 1st %1 2nd %2: %0"
result = stringCapture:match("")
assert(ltest(result, nil))
result = stringCapture:match("abzcccc")
assert(ltest(result, nil))
result = stringCapture:match("abzcxxx")
assert(ltest(result, "% 1st ab 2nd c: abzcx"))  -- %% stands for %, %0 stands for whole match, %1~%9 n-th capture


-- Number Capture

numberCaptureNoValue = normalCapture / 0
result = numberCaptureNoValue:match("")
assert(ltest(result, nil))
result = numberCaptureNoValue:match("aaa")
assert(ltest(result, nil))
result = numberCaptureNoValue:match("abzcxx")
assert(ltest(result, 6))                        -- if capture nothing then return normal match result

numberCapture1st = normalCapture / 1
result = numberCapture1st:match("")
assert(ltest(result, nil))
result = numberCapture1st:match("abzcx")
assert(ltest(result, "ab"))

numberCapture2nd = normalCapture / 2
result = numberCapture2nd:match("")
assert(ltest(result, nil))
result = numberCapture2nd:match("abzcx")
assert(ltest(result, "c"))
-- numberCapture3rd = normalCapture / 3         -- there is no 3rd capture, so will be report error


-- Query Capture

local tbl = {}
tbl["k1"] = "val1"
tbl["k2"] = "val2"

queryCaptureK1 = (lpeg.P("a") * lpeg.C("k1") * lpeg.P("z")) / tbl
result = queryCaptureK1:match("")
assert(ltest(result, nil))
result = queryCaptureK1:match("ak1zz")
assert(ltest(result, "val1"))

queryCaptureK2 = (lpeg.P"k" * lpeg.P"2") / tbl
result = queryCaptureK2:match("a")
assert(ltest(result, nil))
result = queryCaptureK2:match("k222")
assert(ltest(result, "val2"))


queryCaptureK3 = (lpeg.P("a") * lpeg.C("k3") * lpeg.P("z")) / tbl
result = queryCaptureK3:match("akaa")
assert(ltest(result, nil))
result = queryCaptureK3:match("ak3zz")
assert(ltest(result, 5))


-- Function Capture

local function func(str1, str2)
  if str1 == "str1" then
    return "result1"
  end
  if str2 == "str2" then
    return "result2"
  end
  return
end

functionCapture = (lpeg.P"a" * lpeg.C"str1" * lpeg.P"z") / func
result = functionCapture:match("astr1zz")
assert(ltest(result, "result1"))

functionCapture = (lpeg.P"a" * lpeg.C"s" * lpeg.P"z" * lpeg.C"str2") / func
result = functionCapture:match("aszstr222")
assert(ltest(result, "result2"))

functionCapture = (lpeg.P"st" * lpeg.P("r1")) / func
result = functionCapture:match("str111")
assert(ltest(result, "result1"))


functionCapture = (lpeg.P"a" * lpeg.C"11" * lpeg.P"z" * lpeg.C"22") / func
result = functionCapture:match("aaa")
assert(ltest(result, nil))
result = functionCapture:match("a11z22")
assert(ltest(result, 7))


-- Substitution Capture

subCapture = lpeg.Cs(((lpeg.P"a" * lpeg.C"b" * lpeg.P"c") / "zzz %1") * lpeg.P"z")
result = subCapture:match("abcz")
assert(ltest(result, "zzz bz"))    -- each capture replaced by its value (should be a string)


-- Fold Capture

local function concate(str1, str2)
  return str1 .. str1 .. str2 .. str2
end

foldCapture = lpeg.Cf(lpeg.Cc("12"), concate)
result = foldCapture:match("")
assert(ltest(result, "12"))                 -- if only one capture returned, just return this capture value

foldCapture = lpeg.Cf(lpeg.Cc"1" * lpeg.Cc"2", concate)
result = foldCapture:match("")
assert(ltest(result, "1122"))

foldCapture = lpeg.Cf(lpeg.Cc"0" * lpeg.P"a" * lpeg.C("1") * lpeg.P"b" * lpeg.C"2", concate)
result = foldCapture:match("a1b2z")         -- if more than one capture values returned, function will be called like:
assert(ltest(result, "0011001122"))         -- func(func(func(val1, val2), val3), val4)

foldCapture = lpeg.Cf(lpeg.P"aa", concate)
result = foldCapture:match("")
assert(ltest(result, nil))
-- result = foldCapture:match("aa")         -- fold capture need at least one caputure, otherwise will report error

foldCapture = lpeg.Cf(lpeg.P"a" * lpeg.C"1324", concate)
result = foldCapture:match("zzz")
assert(ltest(result, nil))
result = foldCapture:match("a1324zzz")      -- if has only one capture, just return this capture value
assert(ltest(result, "1324"))


-- Group Capture

anonymousGroupCapture = lpeg.Cg(lpeg.C"ab" * lpeg.P"x" * lpeg.C"cd")
result = anonymousGroupCapture:match""
assert(ltest(result, nil))
result = anonymousGroupCapture:match"abxz"
assert(ltest(result, nil))
result = anonymousGroupCapture:match"abxcd"
assert(ltest(result, "ab"))               -- group capture groups all captureis inside into a single capture

anonymousGroupCapture = lpeg.Cg(lpeg.Cc(3.12) * lpeg.Cc(3) * lpeg.Cc(false) * lpeg.Cc(nil) * lpeg.Cc"abc")
result = anonymousGroupCapture:match""
assert(ltest(result, 3.12))               -- anonymous group capture only return the first capture's value in group

namedGroupCapture = lpeg.Cg(lpeg.C"a" * lpeg.P"z" * lpeg.C"b", "GroupName")
res1 = lpeg.match(lpeg.P"11" * namedGroupCapture * lpeg.P"22", "11azb22")
assert(ltest(res1, 8))                    -- named group capture doesn't reutrn any value, unless it is in back/table capture
res1, res2 = lpeg.match(lpeg.P"11" * namedGroupCapture * lpeg.P"22" * namedGroupCapture, "11azb22azb")
assert(ltest(res1, 11))
assert(ltest(res2, nil))


-- Back Capture

namedGroupCapture = lpeg.Cg(lpeg.C"a" * lpeg.P"z" * lpeg.C"b" * lpeg.P"z" * lpeg.C"c", "GroupThreeCapture")
backCapture = lpeg.Cb("GroupThreeCapture")  -- back capture matches the empty string itself
res1, res2, res3 = lpeg.match(lpeg.P"11" * namedGroupCapture * lpeg.P"22" * backCapture, "11azbzc22--")
assert(ltest(res1, "a"))                    -- but back capture get all values from the named group capture
assert(ltest(res2, "b"))
assert(ltest(res3, "c"))
res1, res2, res3 = lpeg.match(lpeg.P"11" * namedGroupCapture * lpeg.P"22" * backCapture, "11azbzc==")
assert(ltest(res1, nil))
assert(ltest(res2, nil))
assert(ltest(res3, nil))
-- back capture can only be appeared after the named group capture
-- res1, res2, res3 = lpeg.match(lpeg.P"11" * backCapture * namedGroupCapture * lpeg.P"22", "11azbzc22")


-- Table Capture

namedGroup1 = lpeg.Cg(lpeg.Cc(3.14) * lpeg.Cc(13), "Group1")
namedGroup2 = lpeg.Cg(lpeg.C"a" * lpeg.P"x" * lpeg.C"b", "Group2")
tableCapture = lpeg.Ct(lpeg.C"i" * lpeg.P"z" * lpeg.C"j" * namedGroup1 * namedGroup2)

result = tableCapture:match("")
assert(ltest(result, nil))
result = tableCapture:match("izjaxb---")
assert(ltest(result[1], "i"))
assert(ltest(result[2], "j"))
assert(ltest(result.Group1, 3.14))  -- group capture only put the first value into table
assert(ltest(result.Group2, "a"))


-- Match-time Capture

function f_matchtime_return_fail(subject, curpos, ...)
  print(subject, curpos, ...)
end

function f_matchtime(subject, curpos, ...)
  print(subject, curpos, ...)
  return curpos
end

function f_matchtime_return_capture_value(subject, curpos, ...)
 print(subject, curpos, ...)
 return curpos, "capture value"
end

function f_call_function_in_the_middle_of_match(subject, curpos, s)
  print(subject, curpos, '"' .. s .. '"')
  return true
end

result = lpeg.Cmt(lpeg.P"abc", f_matchtime_return_fail):match("abcdefg")
assert(result == nil)
result = lpeg.Cmt(lpeg.P"abc", f_matchtime):match("abcdefg")
assert(result == 4)
result = lpeg.Cmt(lpeg.P"abc", f_matchtime_return_capture_value):match("abcdefg")
assert(result == "capture value")
result = lpeg.Cmt(lpeg.P"abc" * lpeg.C"de" * lpeg.P"f" * lpeg.C"g", f_matchtime):match("abcdefg")
assert(result == 8)
result = lpeg.C(lpeg.P"ab" * lpeg.P(f_call_function_in_the_middle_of_match) * lpeg.P"cd"):match("abcd")
assert(result == "abcd")

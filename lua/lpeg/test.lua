local lpeg = require "lpeg"

local function ltest(expr, value)
  if expr == value then
    return true
  end
  print("ltest failure: " .. tostring(expr) .. " not equal to " .. tostring(value))
  return false
end

--> Basic Match

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


--> Matched Before Or Not

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
result = lpeg.match(matchZeroCharactersBefore, "abc", 2) --> at pos 2 can match zero characters
assert(ltest(result, 2))
result = lpeg.match(matchZeroCharactersBefore, "abc", 3)
assert(ltest(result, 3))


--> Match Predicate (Positive)

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


--> Match Predicate (Negative)

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


--> Match a Character in a Character Range

matchAtoZ = lpeg.R("AZ")
result = lpeg.match(matchAtoZ, "")
assert(ltest(result, nil))
result = lpeg.match(matchAtoZ, "A")
assert(ltest(result, 2))
result = lpeg.match(matchAtoZ, "Xaa")
assert(ltest(result, 2))


--> Match a Character in a Character Set

matchOperators = lpeg.S("+-*/")
result = lpeg.match(matchOperators, "+")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "-")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "*")
assert(ltest(result, 2))
result = lpeg.match(matchOperators, "/zzz")
assert(ltest(result, 2))

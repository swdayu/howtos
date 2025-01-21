
Lpeg
- http://www.inf.puc-rio.br/~roberto/lpeg/
- http://www.inf.puc-rio.br/~roberto/docs/peg.pdf
- http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
- http://bford.info/packrat/
- http://lua-users.org/wiki/LpegTutorial
- https://en.wikipedia.org/wiki/Parsing_expression_grammar

Group capture
- group capture (lpeg.Cg) groups all captures inside into a single capture
- anonymous group capture return all capture values in the group for most cases
- named group capture doesn't return any value, unless it is used in the back or table capture
- back capture (lpeg.Cb) matches the empty string, it doesn't comsume characters
- back capture can get all values from a already matched named group capture, so
- back capture can only appeared after the named group capture

Table capture
- table capture (lpeg.Ct) insert all captured values into a table as a sequence from 1 to n
- the named group capture can also be used in the table capture, and only
- the first value of the named group capture is inserted into the table, and
- the group name is stored as the key to index the value, and note that
- the named group must be a direct child of the table, otherwise it will be ignored, for example
- Ct(C("a" * Cg(1,"foo"))):match"ab" only reproduce {"ab"}, foo="b" is not created
- note that annoymous group capture can also be contained in the table capture, and
- it will return all capture values in the group and insterted as values in the sequence, for example
- Ct(C("a" * Cg(C(1) * C(1)))):match"abc" will reproduce {"abc", "b", "c"}

Function capture
- function capture (patt / func) will call the func with all captured values or the whole match of patt
- the values returned by the function are the final values of the capture
- if the function doesn't return any value, then there is no captured value

Match-time capture
- normally, a capture is only evaluated after the entire pattern matched success, but
- the match-time capture Cmt(patt, function) is different, it can be evaluated when a part of pattern matched
- the above parameter patt is a part of pattern, its values are evaluated immediately when matched, and then
- the function is called with subject_string, current_position_after_match_patt, capture_values or whole_match
- the function return false, nil, or no value indicates match failed, match failed pattern will return nil
- return true or current_position_after_match_patt indicates the match success and can continue to match next
- return a new current position indicates match success and can continue to match at the new position
- if the function return values more than one, the extra values will become final captured values of patt

Pattern match returns
- if match failed, the pattern returns nil
- if match success and the pattern has no capture values, it return the position after the match
- if match success and the pattern has capture values, it return all these capture values, and
- the nested caputre values also returned: (C(C"a" * P"b") * C"c"):match("abc") will return ab, a, c
- if the pattern has captures but no capture values produced in the match, then
- it will also just return the position after the match: (P"a" + C"b"):match"a" will return 2


- http://lua-users.org/wiki/LpegTutorial

Group capture
- group capture (lpeg.Cg) groups all captures inside into a single capture
- anonymous group capture only return the first capture's value in group
- named group capture doesn't return any value, unless it is used in the back or table capture
- back capture (lpeg.Cb) matches the empty string, it doesn't comsume characters
- back capture can get all values from a already matched named group capture
- so back capture can only appeared after the named group capture

Table capture
- table capture (lpeg.Ct) insert all captured values into a table as a sequence from 1 to n
- the named group capture can be used in the table capture
- but only the first value of the named group capture is inserted into the table
- and the group name is stored as the key to index the value


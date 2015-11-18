# Lua
- http://www.lua.org/manual/5.3/manual.html
- http://www.lua.org/cgi-bin/demo

## Install
```
$ tar zxf lua-5.3.1.tar.gz
$ cd lua-5.3.1
$ make linux test # make macosx test
$ sudo make install

# if fatal error: readline/readline.h: No such file or directory
# install this library first
$ sudo apt-get install libreadline-dev 
```

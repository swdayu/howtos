
# Basic

Execute next command only if the previous command success
```
$ apt-get update && apt-get upgrade
```

Execute the second command only if the first one failed
```
$ ping -c 1 -w 15 -n 72.14.203.104 || echo "Server down"
```

Use another command's result in current command line
```
$ date "+%Y-%m-%d"
2015-11-17
$ mkdir $(date "+%Y-%m-%d") # same as `$ mkdir 2015-11-17`
```

Use one command's output as another command's input
```
$ ls -al | less
```


# git remote

Add a name for remote repo
```
$ cd howtos
$ git remote add https-howtos https://github.com/xijkn/howtos.git
$ git remote add ssh-howtos git@github.com:xijkn/howtos.git
```

Check added names in local repo
```
$ git remote -v
https-howtos    https://github.com/xijkn/howtos.git (fetch)
https-howtos    https://github.com/xijkn/howtos.git (push)
origin  https://github.com/xijkn/howtos.git (fetch)
origin  https://github.com/xijkn/howtos.git (push)
ssh-howtos      git@github.com:xijkn/howtos.git (fetch)
ssh-howtos      git@github.com:xijkn/howtos.git (push)
```


# GIT

GIT CONFIG
```shell
$ git config --list
$ git config user.name
$ git config user.email
$ vim ~/.gitconfig
[user]
        name = Connectivity_BT) Your Name
        email = yourname@example.com
[commit]
        template = /home/folder/.gitmsg.template
[color]
        ui = auto
[core]
        editor = vim
[url "ssh://company_yourname@xxx.xx.xx.xx:port"]
        pushInsteadOf = ssh://yourname@xxx.xx.x.xxx:port
[push]
        default = current
```

GIT BRANCH
```shell
$ git branch -a
```

GIT SUBMIT
```shell
$ vim modify_files
$ git status && git diff
$ git add . && git status
$ git commit
    Submit for XXX issue:
    PROJN-TASK-PHASE-23
CTRL+O
CTRL+X
$ git branch -a # show branch info -> remote/MM/name/public/develop
$ git push remote HEAD:refs/for/MM/name/public/develop
$ git log -2 # last two commits with (commit id, comment)
$ git show commit_id # show commit detail info by commit id
$ vim modify_files
$ git status && git diff
$ git add . && git status
$ git commit --amend
$ git push remote HEAD:refs/for/MM/name/public/develop
```

SUBMIT USING REPO
```shell
$ repo sync .
$ repo upload .
```

GIT LOG
```shell
$ git log --stat -2 # last two commits with (commit id, comment, changed files)
```

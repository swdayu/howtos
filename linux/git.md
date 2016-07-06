## git
- http://git-scm.com/

**git config**
```shell
$ vi ~/.gitconfig   # editor your git config file
[user]
  name = Connectivity_BT) Your Name
  email = yourname@example.com
[core]
  editor = vi
[color]
  ui = auto
[url "ssh://company_yourname@xxx.xx.xx.xx:port"]
  pushInsteadOf = ssh://yourname@xxx.xx.xx.xx:port
  pushInsteadOf = ssh://yourname@xxx.xx.xx.xx:port
[push]
  default = current
$ git config --list

git config -e --global           # edit .gitconfig under user folder
git config -e --system           # edit /etc/gitconfig for system
cd repo
git config -e                    # edit .git/config
git config user.name             # show value of repository level
git config a.b value             # set value of repository level
git config --global a.b          # show value of user level
git config --global a.b value    # set value of user level
git config --system x.y.z        # show value of system level
git config --system x.x.z value  # set value of system level

git rev-parse --git-dir   # show the path of current repository
```

**git grep**
```shell
git grep -n "pattern"                         # search workspace files' content and list line number
git grep -n -w "pattern"                      # search only at word boundary
git grep -E "patt1|patt2"                     # search lines that match "patt1" or "patt2"
git grep --all_match -e "p1" -e "p2"          # search lines that match "p1" or "p2"
git grep -e "p1" --or -e "p2"                 # search lines that match "p1" or "p2"
git grep --not -e "patt" -- test.txt          # search lines that not contain "patt" in the file of test.txt
git grep -e "patt1" --and -e "patt2"          # search lines that match "patt1" and "patt2"
git grep -e "p1" --and \( -e "p2" -e "p3" \)  # search lines that match "p1" and match "p2" or "p3"
git grep "time_t" -- "*.[ch]"                 # search "timet_t" in .c and .h files
git grep -n --context 3 "pattern"             # show context lines: -3 -C --context -A --after-context -B --before-context
git grep -n --function-context "pattern"      # show function context, or use -W for short
```

**git format-patch**
```shell
git init
git add --all
git commit -m "initialized"
git tag v1
git add
git commit
git format-patch v1..HEAD
git send-email *.patch
```
**git add**
```shell
git add -u   # --update, add modified file to stage
git add -A   # --all, add all files (including new files and deleted files) to stage
```

**git diff**
```shell
git diff            # diff workspace with stage
git diff --cached   # diff stage with repository
git diff HEAD~1     # diff repository HEAD~1 with previous commit
```

**git stash**
```shell
git stash
git checkout new_branch
...
git checkout original_branch
git stash pop
```

**git clone**
```shell
$ git clone remote_repo local_dir   # without local_dir will use current directory
$ mkdir -p repo/.git                # bare clone only copy repo database not files
$ git clone --bare remote repo/.git  
$ mkdir -p mirror/.git              # clone a mirror database can be easily synced
$ git clone --mirror remote mirror/.git
```

**git remote**
```shell
$ git remote update
$ git remote -v
$ git remote add https_remote https://example.com/user/demo.git
$ git remote add ssh_remote git@example.com:user/demo.git

$ git push remote_repo branch
$ git pull remote_repo branch
```

**git branch**
```shell
$ git branch -a
```

**git commit**
```shell
$ vim modify_files
$ git status && git diff
$ git add . && git status
$ git commit
    Submit for XXX issue:
    PROJN-TASK-PHASE-23
CTRL+O
CTRL+X
$ git branch -a        # show branch info -> remote/MM/name/public/develop
$ git push remote HEAD:refs/for/MM/name/public/develop
$ git log -2           # last two commits with: commit id, comment
$ git show commit_id   # show commit detail info by commit id
$ vim modify_files
$ git status && git diff
$ git add . && git status
$ git commit --amend
$ git push remote HEAD:refs/for/MM/name/public/develop

# git add --all
# git commit -m "Update files for some purpose"
```

**git log**
```shell
$ git log --stat -2   # last two commits with: commit id, comment, changed files
```

**git blame**
```shell
$ git blame file  # display each line's latest modify info: commit_id, author, date, line_no, content
^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   31) #include <string.h>
^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   32) #include "bt_target.h"
5cd8bff2 (Mike J. Chen                    2014-01-31 18:16:59 -0800   33) #include "bt_utils.h"
^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   34) #include "l2cdefs.h"
^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   35) #include "l2c_int.h"
```

git

* http://git-scm.com/

git config ::

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
    git config core.editor "vi"

    git rev-parse --git-dir   # show the path of current repository

git grep ::

    git grep -n "pattern"                         # search workspace files' content and list line number
    git grep -n -w "pattern"                      # search only at word boundary
    git grep -E "patt1|patt2"                     # search lines that match "patt1" or "patt2"
    git grep --all_match -e "p1" -e "p2"          # search lines that match "p1" or "p2"
    git grep -e "p1" --or -e "p2"                 # search lines that match "p1" or "p2"
    git grep --not -e "patt" -- test.txt          # search lines that not contain "patt" in test.txt
    git grep -e "patt1" --and -e "patt2"          # search lines that match "patt1" and "patt2"
    git grep -e "p1" --and \( -e "p2" -e "p3" \)  # search lines that match "p1" and match "p2" or "p3"
    git grep "time_t" -- "*.[ch]"                 # search "timet_t" in .c and .h files
    git grep -n --context 3 "pattern"             # show context: -3 -C/A/B --context --after/before-context
    git grep -n --function-context "pattern"      # show function context, or use -W for short

git format-patch ::

    git init
    git add --all
    git commit -m "initialized"
    git tag v1
    git add
    git commit
    git format-patch v1..HEAD
    git send-email *.patch

git init ::

    $ git init       # init a git repository in current directory
    $ git init repo  # create a directory of "repo" and init a git repository under "repo"

git add ::

    $ git add -u     # --update, add modified file to stage
    $ git add --all  # --all -A, add all files (including new files and deleted files) to stage

git status ::

    $ git status -s     # show status using short format
    M  core/java/android/bluetooth/BluetoothA2dp.java        # green: staged
    M core/java/android/bluetooth/BluetoothGatt.java        # red: modified in workspace
    MM core/java/android/bluetooth/BluetoothGattServer.java  # both modified and staged
    $ git status -s -b  # -b: show current branch
    ## master
    MM hello.txt

git diff ::

    # workspace -> cached area (or stage/index) -> repository
    $ git diff            # diff workspace with stage
    $ git diff HEAD       # diff workspace with repository
    $ git diff HEAD~1     # diff workspace with previous repository
    $ git diff --cached   # diff stage with repository, same as `git diff --staged`

git checkout ::

    $ git checkout -- files    # workspace files replaced by staged files
    $ git checkout HEAD files  # workspace files replaced by repository files

git reset ::

    # reset files
    $ git reset HEAD files     # staged files replaced by repository files, workspace remain unchanged
    $ git reset HEAD~1 files   # staged files replaced by previous repository files
    $ git reset HEAD -- files  # add `--` to avoid name conflict between commit/reference and file path
    $ git reset -- files       # same as `git reset HEAD -- files`

    # reset HEAD reference
    $ git reset HEAD           # same as `git reset` and `git reset --mixed HEAD`
    $ git reset HEAD~1         # same as `git reset --mixed HEAD~1`
    $ git reset --soft HEAD~1
    $ git reset --hard HEAD~1

git rm ::

    $ git rm --cached files    # delete staged files

git clean ::

    $ git clean -df            # remove untracked directories and files

git stash ::

    $ git stash
    $ git checkout new_branch
    $ ...
    $ git checkout original_branch
    $ git stash pop

git clone ::

    $ git clone remote_repo local_dir   # without local_dir will use current directory
    $ mkdir -p repo/.git                # bare clone only copy repo database not files
    $ git clone --bare remote repo/.git  
    $ mkdir -p mirror/.git              # clone a mirror database can be easily synced
    $ git clone --mirror remote mirror/.git
    git clone git@github.com:user/repo.git
    git clone --progress --branch name -v "git.host.com:gitolite3/repo.git" "folder/path"
    git clone --progress --branch name -v "gitolite3@git.host.com:repo" "folder/path"

git remote ::

    $ git remote update
    $ git remote -v
    origin  git@github.com:<username>/<reponame>.git (fetch)
    origin  git@github.com:<username>/<reponame>.git (push)
    origin  https://github.com/<username>/<reponame>.git (fetch)
    origin  https://github.com/<username>/<reponame>.git (push)
    remote  https://github.com/<username>/<reponame>.git (fetch)
    remote  https://github.com/<username>/<reponame>.git (push)

    $ git remote remove <name>
    $ git remote rename <oldname> <newname>
    $ git remote add https_remote https://example.com/user/demo.git
    $ git remote add ssh_remote git@example.com:user/demo.git

    $ git push remote_repo branch
    $ git pull remote_repo branch

git branch ::

    $ git branch      # show current branch
    $ git branch -a

git commit ::

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

    $ git commit --amend --date=now # 更新上次提交的提交时间
    $ git add --all
    $ git commit -m "Update files for some purpose"

    git push origin HEAD:refs/for/master
    git push origin refs/heads/ibrt_rc_0.2
    如果要删除，git push origin :refs/tags/ibrt_rc_0.2

git log ::

    $ git log --stat -2             # show last 2-commit with: commit id, comment, changed files
    $ git log --pretty=oneline -2   # show last 2-commit with each one line
    $ git log --oneline -2          # similar to `--pretty=oneline`, but with shorten commit id
    $ git log --graph -2            # print out relationship graph for commits

git reflog ::

    $ git reflog | head -5          # show local changes of HEAD pointer

git blame ::

    $ git blame file  # display each line's latest modify info: commit_id, author, date, line_no, content
    ^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   31) #include <string.h>
    ^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   32) #include "bt_target.h"
    5cd8bff2 (Mike J. Chen                    2014-01-31 18:16:59 -0800   33) #include "bt_utils.h"
    ^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   34) #include "l2cdefs.h"
    ^5738f83 (The Android Open Source Project 2012-12-12 16:00:35 -0800   35) #include "l2c_int.h"

保留内容删除所有提交记录 ::

    git checkout --orphan new_branch
    git add .
    git commit -m "your_comment"
    git branch -D master # 删除 master 分支
    git branch -m master # 将当前分支命名为 master 分支
    git push -f origin master # 推到远程代码库

提交代码之前 rebase ::

    git fetch origin
    git rebase origin your_current_branch_name

新建远程分支 ::

    git checkout -b new_remote_branch
    git branch     # can see local branch *new_remote_branch
    modify your files
    git push origin new_remote_branch:new_remote_branch
    git branch -a  # can see remotes/origin/new_remote_branch

    1.将本地分支进行改名:
    git branch -m old_branch new_branch
    2.将本地分支的远程分支删除:
    git push origin :old_branch
    3.将改名后的分支push到远程，并让本地分支关联远程分支：
    git push --set-upstream origin new_branch

拉远程分支的一个子目录 ::

    rm -rf bt_if
    git init bt_if
    cd bt_if
    git remote add -f origin remote-git-repo
    git config core.sparseCheckout true
    echo "services/bt_if/" >> .git/info/sparse-checkout
    git pull origin master_new_profile
    mv services/bt_if/* .
    rm -rf services
    git add --all .
    git commit -m "adjust folder"
    cd ..

git tag ::

    git tag ver_1031 # make a tag on latest commit
    git tag -d ver_1031 # delete the tag
    git push origin <branch_name> --tags # push local tags

将另一个分支的代码合到当前分支 ::

    git checkout master         # switch to master branch
    git pull origin master      # get code
    git checkout your_branch    # switch to your branch
    git merge master            # merge master code to your branch
    git push origin your_branch # submit

git revert ::

    git revert commit_id



# GitHub Easy Access

**Clone a remote repo to local**
```
$ cd local_repo_directory

# clone remote repo to current directory
$ git clone https://github.com/[user]/demo-repo.git
```

**Add names for remote repo**
```
$ cd demo-repo

# add short name for HTTPs URL
$ git remote add https-demo-repo https://github.com/[user]/demo-repo.git

# add short name for SSH URL
$ git remote add ssh-demo-repo git@github.com:[user]/demo-repo.git 

# check added names in current repo
$ git remote -v
https-howtos    https://github.com/xijkn/howtos.git (fetch)
https-howtos    https://github.com/xijkn/howtos.git (push)
origin  https://github.com/xijkn/howtos.git (fetch)
origin  https://github.com/xijkn/howtos.git (push)
ssh-howtos      git@github.com:xijkn/howtos.git (fetch)
ssh-howtos      git@github.com:xijkn/howtos.git (push)
```

**Modify local files and commit the changes**
```
# 1. Modify local files ...

# 2. Add all modified file into stage
$ git add .

# 3. You can check current status
$ git status

# 4. Commit the chagnes
$ git commit -m "Update files for some purpose"
```

**Push the local modified repo to remote**
```
# Using SSH URL when SSH key has configured
$ git push ssh-demo-repo master # push into remote master branch

# HTTPs URL can also be used
$ git push https-demo-repo master
```

**Pull remote updated repo to local**

If remote repo has modified with GitHub online editor or has updated when at work,
when you go home, you can pull updated repo to local.
```
$ git pull ssh-demo-repo master # pull remote master branch down
$ git pull https-demo-repo master # https style way

# you can check recently commits using
$ git log
```

After you pull down the latest repo, you can modify and commit and push up as previous steps.


# git clone

Clone a remote repo to local directory
```
$ cd repo-directory
$ git clone https://github.com/xijkn/howtos.git
Cloning into 'howtos' ...
$ git clone https://github.com/xijkn/howtos.git   
fatal: destination path 'howtos' already exists and is not an empty directory.
```

Regular clone command format
```
$ git clone original-repo [local-directory]
# if local directory is not given, then current directory will be used
```

Bare clone only copy repo database not workspace files
```
$ mkdir -p repo-bare/.git
$ git clone --bare repo repo-bare/.git
```

Mirror clone is much like bare clone, but can sync easily with original repo
```
$ mkdir -p repo-mirror/.git
$ git clone --mirror repo repo-mirror/.git
```
`--mirror` set up a mirror of the source repository. This implies `--bare`. 
Compared to `--bare`, `--mirror` not only maps local branches of the source to local branches of the target, 
it maps all refs (including remote branches, notes etc.) and sets up a refspec configuration 
such that all these refs are overwritten by a `git remote update` in the target repository.


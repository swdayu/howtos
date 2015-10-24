
# References
- https://help.github.com/articles/which-remote-url-should-i-use/
- http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes

# Pull down

Clone a repo into a new directory, or if there is a same name in this directory, it will be fatal.
```
$ cd github-repo
$ git clone https://github.com/xijkn/howtos.git
Cloning into 'howtos' ...
$ git clone https://github.com/xijkn/howtos.git   
fatal: destination path 'howtos' already exists and is not an empty directory.
```

Adds a name for the repository at remote url.
```
$ cd howtos
$ git remote add https-howtos https://github.com/xijkn/howtos.git
$ git remote add ssh-howtos git@github.com:xijkn/howtos.git
```

Check current short names in the repo. 
```
$ git remote -v
https-howtos    https://github.com/xijkn/howtos.git (fetch)
https-howtos    https://github.com/xijkn/howtos.git (push)
origin  https://github.com/xijkn/howtos.git (fetch)
origin  https://github.com/xijkn/howtos.git (push)
ssh-howtos      git@github.com:xijkn/howtos.git (fetch)
ssh-howtos      git@github.com:xijkn/howtos.git (push)
```

[[draft]]

The recommended way is cloning with HTTPS. 
The `https://` clone URLs are available on all repositories, public and private.
They are smart, so they will provide you with either read-only or read/write access,
depending on your permissions to the repository.

These URLs work everywhere - even if you are behind a firewell or proxy.
In certain cases, if you'd rather use SSH, you might be able to use SSH over the HTTPS port.

When you `git fetch`, `git pull`, or `git push` to the remote repository using HTTPS,
you'll be asked for your GitHub username and password.
* If you have two-factor authentication enabled, 
  you must create a personal access token to use instead of your GitHub password.
* You can use a credential helper so Git will remember your GitHub username and password every time it talks to GitHub.







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
Clone using HTTPS is recommended.
The `https://` clone URLs are available on all repositories, public and private.
They are smart, so they will provide you with either read-only or read/write access,
depending on your permissions to the repository.
These URLs work everywhere - even if you are behind a firewell or proxy.
In certain cases, if you'd rather use SSH, you might be able to use SSH over the HTTPS port.

When you `git fetch`, `git pull`, or `git push` to the remote repository using HTTPS,
you'll be asked for your GitHub username and password. You can use a *credential helper* 
so Git will remember your GitHub username and password every time it talks to GitHub.
The *credential helper* can tell Git to remember your GitHub username and password every time it talks to GitHub.
You need Git 1.7.10 or newer to use the credential helper.

Git will save your password in memory for some time when *credential helper* is turn on.
By default, Git will cache your password for 15 minutes. 
You can set to use cache and to change the default password cache timeout.
```
$ git config --global credential.helper cache # set to use memory cache
$ git config --global credential.helper 'cache --timeout=3600' # set timeout to 3600s
```

If you have two-factor authentication enabled, 
you must create a personal access token to use instead of your GitHub password.

# Clone using SSH

If you clone GitHub repositories using SSH, then you authenticate using SSH keys instead of a username and password.
For help

## Using SSH over HTTPS port
Sometimes, firewalls refuse to allow SSH connections entirely.
If using HTTPS cloning with credential caching is not an option,
you can attempt to clone using an SSH connection made over the HTTPS port.

To test if SSH over the HTTPS port is possible, run following SSH command.
If that worked, great! If not, you may need to follow troubleshooting guide.
```
$ ssh -T -p 443 git@ssh.github.com
```



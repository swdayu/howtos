
# References
- https://help.github.com/articles/which-remote-url-should-i-use/
- http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes

# Clone using HTTPS (recommended)

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

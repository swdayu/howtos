
# References
- https://help.github.com/articles/which-remote-url-should-i-use/
- http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes

# Clone Repo From GitHub
```
$ git clone https://github.com/xijkn/howtos.git
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






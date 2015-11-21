
# ENV

Show environment variables.
```
$ env
$ echo $PATH
$ echo $HOME
$ echo $USER
```

Show process's environment variables.
```
$ pgrep -l ssh
3190 sshd
$ cat /proc/3190/environ
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/binTERM=linuxSSH_SIGSTOP=1
$ cat /proc/3190/environ | tr '\0' '\n' # replace '\0' by '\n'
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
TERM=linux
SSH_SIGSTOP=1
```

Envrionment files.
```
$ cat /etc/environment
$ cat /etc/profile
$ cat ~/.bashrc
```



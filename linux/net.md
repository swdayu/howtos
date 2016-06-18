
**ssh**
```shell
$ ls -al ~/.ssh                                      # check ssh key exist or not
$ ssh-keygen -t rsa -b 4096 -C "your_github_email"   # gen a new ssh key (rsa key pair) with the email as a label
$ ls -al ~/.ssh                                      # list generated key files
-rw-------  1 usrname ... id_rsa
-rw-r--r--  1 usrname ... id_rsa.pub
$ eval "$(ssh-agent -s)"                             # start ssh agent
$ ssh-add ~/.ssh/id_rsa                              # add your private key to ssh agent
$ cat ~/.ssh/id_rsa.pub                              # copy your public key file content to github ssh key list
$ ssh -T git@github.com                              # test the connection
```

**curl**
```shell
# write output to a file with remote time and remote name
$ curl -R -O http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
```

**axel - mutithread download**
- http://www.vpser.net/manage/axel.html

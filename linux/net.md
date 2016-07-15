
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

**shadowsocks/proxychains**
```shell
# install shadowsocks on both remote machine and local
$ git clone https://github.com/shadowsocks/shadowsocks-libev.git
$ cd shadowsocks-libev
$ sudo apt-get install build-essential autoconf libtool libssl-dev asciidoc
$ ./configure && make
$ sudo make install

# start server as a daemon on remote machine
$ ss-server -p 4400 -k <password> -m aes-256-cfb -t 120 -f ~/ss-server.pid
$ kill $(pgrep ss-server | tr "\n" " ")  # stop server

# start a client as a daemon on local
$ ss-local -s <server_host> -p 4400 -l 7070 -k <password> -m aes-256-cfb -f ~/ss-local.pid
$ kill $(pgrep ss-local | tr "\n" " ")   # stop client

# using proxychains on local
$ sudo apt-get install proxychains
$ sudo vi /etc/proxychains.conf
socks5 127.0.0.1 7070
$ curl ip.gs
$ proxychains curl ip.gs
```

**scp**
```shell
$ scp -r user@example.com:~/docs/ .                  # copy remote docs under to local current directory
$ scp /home/a.mp3 user@example.com:~/music/          # copy to remote
$ scp /home/a.mp3 user@example.com:~/music/001.mp3   # copy from remote
```

**curl**
```shell
# write output to a file with remote time and remote name
$ curl -R -O http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
```

**axel - mutithread download**
- http://www.vpser.net/manage/axel.html

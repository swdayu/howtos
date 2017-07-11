
**ipv6**
```shell
$ adb shell ifconfig
bt-pan    Link encap:Ethernet  HWaddr 22:22:4d:06:45:8d
          inet addr:192.168.44.141  Bcast:192.168.44.255  Mask:255.255.255.0 
          inet6 addr: fe80::2022:4dff:fe06:458d/64 Scope: Link

$ adb shell ip -4 route
192.168.44.0/24 dev bt-pan  proto kernel  scope link  src 192.168.44.141

$ adb shell ping -I 192.168.44.141 -c 10 baidu.com
PING baidu.com (180.149.132.47) from 192.168.44.141 : 56(84) bytes of data.
64 bytes from 180.149.132.47: icmp_seq=1 ttl=52 time=300 ms
64 bytes from 180.149.132.47: icmp_seq=2 ttl=52 time=213 ms
64 bytes from 180.149.132.47: icmp_seq=3 ttl=52 time=498 ms
64 bytes from 180.149.132.47: icmp_seq=4 ttl=52 time=127 ms
64 bytes from 180.149.132.47: icmp_seq=5 ttl=52 time=163 ms
64 bytes from 180.149.132.47: icmp_seq=6 ttl=52 time=157 ms
64 bytes from 180.149.132.47: icmp_seq=7 ttl=52 time=138 ms
64 bytes from 180.149.132.47: icmp_seq=8 ttl=52 time=323 ms
64 bytes from 180.149.132.47: icmp_seq=9 ttl=52 time=166 ms
64 bytes from 180.149.132.47: icmp_seq=10 ttl=52 time=260 ms

--- baidu.com ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9033ms
rtt min/avg/max/mdev = 127.877/235.019/498.876/109.345 ms

$ adb shell route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.44.0    0.0.0.0         255.255.255.0   U     0      0        0 bt-pan

$ adb shell netstat -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
192.168.44.0    *               255.255.255.0   U         0 0          0 bt-pan

$ host -t AAAA www.qq.com
www.qq.com has IPv6 address 240e:e1:8100:28::2:16

$ adb shell [ -f /proc/net/if_inet6 ] && echo 'IPv6 ready system!' || echo 'No IPv6 support found! Compile the kernel!!'
IPv6 ready system!

$ adb shell lsmod | grep -qw ipv6 && echo "IPv6 kernel driver loaded and configured." || echo "IPv6 not configured and/or driver loaded on the system."
IPv6 not configured and/or driver loaded on the system.

$ ipv6 local address (fe80::), public address (2xxx:: or 3xxx::)
```

**ssh**
```shell
# ssh key generation (take github for example)
$ ls -al ~/.ssh                                     # check ssh key exist or not
$ ssh-keygen -t rsa -b 4096 -C "your_github_email"  # gen a new rsa key pair with the email as a label
$ ls -al ~/.ssh                                     # list generated key files
-rw-------  1 usrname ... id_rsa
-rw-r--r--  1 usrname ... id_rsa.pub
$ eval "$(ssh-agent -s)"                            # start ssh agent
$ ssh-add ~/.ssh/id_rsa                             # add your private key to ssh agent
$ cat ~/.ssh/id_rsa.pub                             # show and copy public key to github ssh key list
$ ssh -T git@github.com                             # test the connection

# ssh proxy (take firefox for example)
$ ssh -fND 7070 user@example.com
# configure firefox
Preferences | Advanced | Network | Connection | Settings ...
- Manual proxy configuration [check]
- SOCKS Host: [127.0.0.1]  Port: [7070]
- SOCKS v5 [check]
```

**shadowsocks, proxychains**
```shell
# install shadowsocks on both remote machine and local
$ git clone https://github.com/shadowsocks/shadowsocks-libev.git
$ cd shadowsocks-libev
$ sudo apt-get install build-essential autoconf libtool libssl-dev asciidoc
$ ./configure && make
$ sudo make install

# start server as a daemon on remote machine
$ ss-server -p 4400 -k <password> -m aes-256-cfb -t 120 -f ~/ss-server.pid
$ kill $(pgrep ss-server | tr "\n" " ")  # stop server if you dont use anymore

# start a client as a daemon on local
$ ss-local -s <server_host> -p 4400 -l 7070 -k <password> -m aes-256-cfb -f ~/ss-local.pid
$ kill $(pgrep ss-local | tr "\n" " ")   # stop client if you dont use anymore

# using proxychains on local
$ sudo apt-get install proxychains
$ sudo vi /etc/proxychains.conf
socks5 127.0.0.1 7070
$ curl ip.gs
$ proxychains curl ip.gs

# configure proxy for git
# repository level: .git/config
$ git config http.proxy 'socks5://127.0.0.1:7070' 
$ git config https.proxy 'socks5://127.0.0.1:7070'
# user level: ~/.gitconfig
$ git config --global http.proxy 'socks5://127.0.0.1:7070' 
$ git config --global https.proxy 'socks5://127.0.0.1:7070'
```

**scp**
```shell
$ scp -r user@example.com:~/docs/ .                  # copy remote docs to local current directory
$ scp /home/a.mp3 user@example.com:~/music/          # copy to remote
$ scp /home/a.mp3 user@example.com:~/music/001.mp3   # copy from remote
```

**curl**
```shell
# write output to a file with remote time and remote name
$ curl -R -O http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
```

**download**
```shell
$ axel url # http://www.vpser.net/manage/axel.html
$ wget url
```

**w3m**
```shell
# command line text broswer: http://wiki.ubuntu.org.cn/W3m
$ sudo apt-get install w3m w3m-img
# usages:
- Space/B: next/prev page
- J/K: scroll one line forward/backward
- w/W: next/prev word
- g/G: go to first/last line
- Tab/C-u: next/prev hyperlink
- u/c: show current hyperlink url, show current page url
- i/I: show image url, open image
- Enter: open hyperlink
```

**linode**
```shell
# node speed test: https://www.linode.com/speedtest
# https://manager.linode.com/linodes/weblish/linode1414078
```

**name.com**
```
Annual Renewal: $10.99 - Renew Domain   Auto Renew: Enabled
年度费用：$10.99 - 续费                 自动续费：已开启
Domain Expires: 00 Nov 20XX             Whois Privacy: Private
域名到期时间：00 Nov 20XX               Whois隐私：私密的
Domain name: example.com             (域名)  
Domain lock: Transfer Lock           (转移已锁定)  
Transfer Auth Code: [Show Code]      (用于域名转移的授权代码)  
Nameservers: [Edit Nameservers]      (域名解析服务器 [编辑域名服务器])  
DNS hosted: Yes [Update DNS records] (域名服务已开启 [更新域名服务记录])  
  | Type | Host          | Answer            | TTL
  |  A   | example.com   | your_ip_address   | 300
  |  A   | *.example.com | your_ip_address   | 300
```

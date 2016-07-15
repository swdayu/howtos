
**basic**
```shell
# prompt character
root@localhost:~#
user@localhost:~$

# shebang line of shell script
#!/bin/bash

# edit and execute shell script
$ cat << EOF >> a.sh
> #!/bin/bash
> ...
> EOF
$ chmod u+x a.sh
$ a.sh   # same as `/bin/bash a.sh`

# some config files
$ cat ~/.bashrc
$ cat /etc/profile
$ cat /etc/environment
$ cat /etc/hosts

# stdin: code 0, <, <<
# stdout: code 1, >, >>
# stderr: code 2, 2>, 2>>
$ find folder -name pattern > stdout_log 2> stderror_log
$ find folder -name pattern 2> /dev/null     # discard error log
$ find folder -name pattern > logfile 2>&1   # log to the same file

# combine commands 
$ apt-get update && apt-get upgrade                        # execute next only if current success
$ ping -c 1 -w 15 -n 72.14.203.104 || echo "server down"   # execute next only if current failed
$ echo first cmd; echo second cmd                          # these two commands are not logical related
$ mkdir $(date "+%Y-%m-%d")                                # use another command's result as parameters
$ mkdir `data "+%Y-%m-%d`
```

**multi-screen terminal**
```shell
$ sudo apt-get install terminator
# modified settings
Terminator Preferences | Global
- Terminal separator size: [2]
- Hide size from title: [check]
- Unfocused terminal font brightness: [1.0]
Terminator Preferences | Profiles | General
- Font: [Ubuntu Mono | 13]
- Show titilebar: [uncheck]
Terminator Preferences | Profiles | Colors
- Foreground and Background -> Built-in schemes: [Ambience]
- Palette -> Build-in schemes: [Ambience]
Terminator Preferences | Profiles | Scrolling
- Srollback: [1000000] lines
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

**send later for thunderbird**
```shell
# install
Tools | Add-ons | Get Add-ons | Search "Send Later" and install
# check whether there are scheduled mails need to be send for every <n> minutes
Tools | Add-ons | Extensions | Send Later x.x.x | Preferences | General
- Check every: [3] minutes
# trigger "Send Later" when click "Send" button
Tools | Add-ons | Extensions | Send Later x.x.x | Preferences | General
- "Send" does "Send Later"
## configure a button for sending 3 minutes later
Tools | Add-ons | Extensions | Send Later x.x.x | Preferences | Shortcut1
- Button Label: [3 min later] Minutes: [3]
```

**echo**
```shell
# echo text with specified color
$ /bin/echo -e "\033[30m Black \033[0m"
$ /bin/echo -e "\033[31m Red \033[0m"
$ /bin/echo -e "\033[32m Green \033[0m"
$ /bin/echo -e "\033[33m Yellow \033[0m"
$ /bin/echo -e "\033[34m Blue \033[0m"
$ /bin/echo -e "\033[35m Purple \033[0m"
$ /bin/echo -e "\033[36m Light Blue \033[0m"
$ /bin/echo -e "\033[37m White \033[0m"
$ /bin/echo -e "\033[40;37m Black Background \033[0m"
$ /bin/echo -e "\033[41;37m Red Background \033[0m"
$ /bin/echo -e "\033[42;37m Green Background \033[0m"
$ /bin/echo -e "\033[43;37m Yellow Background \033[0m"
$ /bin/echo -e "\033[44;37m Blue Background \033[0m"
$ /bin/echo -e "\033[45;37m Purple Background \033[0m"
$ /bin/echo -e "\033[46;37m Light Blue Background \033[0m"
$ /bin/echo -e "\033[47;31m White Background \033[0m"
```

**apt-cache**
```shell
# apt - Ubuntu's Advanced Packaging Tool

$ apt-cache pkgnames name    # list the names of all packages in the system
$ apt-cache search pkgpatt   # search the package list for a regex pattern
$ apt-cache show pkgname     # show a readable record for the package
$ apt-cache showsrc pkgname  # show source records of the package
$ apt-cache depends pkgname  # show raw dependency info for a package
$ apt-cache rdepends pkgname # show reverse dependency for the package
$ apt-cache policy pkgname   # show policy settings of a package
```

**apt-get**
```shell
# The APT package index is essentially a database of available packages from the repositories
# defined in the `/etc/apt/sources.list` file and in the `/etc/apt/sources.list.d` directory.
# Use `apt-get update` to update the local package index with the latest changes made in the repositories.

$ apt-get update             # retrieve new lists of packages
$ apt-get upgrade            # perform an upgrade
$ apt-get install pkg1 pkg2  # install new packages
$ apt-get remove pkg1 pkg2   # remove packages
$ apt-get purge pkg1 pkg2    # remove packages and config files
$ apt-get clean              # erase downloaded archive files
$ apt-get autoclean          # erase old downloaded archive files
```

**hostname**
```shell
$ hostname  # show current hostname
$ sudo vi /etc/hostname
$ sudo vi /etc/hosts

# After physically reboot your device, the hostname will be updated permanently.
# Check the name display in [System Settings | Details | Overview | Device name], 
# and the name on the Terminal [username@hostname:~$].
```

**env**
```shell
$ env
$ echo $PATH
$ echo $HOME
$ echo $USER

# show environment variables of a process
$ pgrep -l ssh
3190 sshd
$ sudo cat /proc/3190/environ

$ vi ~/.bashrc  # user level
export VULKAN_SDK=~/vulkan/VulkanSDK/1.0.17.0/x86_64/
export PATH=$PATH:$VULKAN_SDK/bin
export LD_LIBRARY_PATH=$VULKAN_SDK/lib
export VK_LAYER_PATH=$VULKAN_SDK/etc/explicit_layer.d
$ source ~/.bashrc
```

**virtualbox**
```shell
# Default window size
  File | Preferences | Display
  - Maximum Guest Screen Size: Hint
  - Width: input wanted default window width
  - Height: input wanted default window height
  
# Share clipboard
  Machine | Settings | General | Advanced
  - Shared Clipboard: Bidirectional
  Machine | Settings | Storage
  - Controller: SATA    => check "Use Host I/O Cache"
    - YourVirtualOS.vdi => check "Solid-state Drive"

# Share folders
  Machine | Settings | Shared Folders
  - add folders wanted to share to Machine Folders
  - all shared folders will mounted under `/media/`

# Add your username to vboxsf group to require the access permission
$ ls -al /media/
drwxrwx---   1 root vboxsf 12288 6月  12 11:49 sf_E_DRIVE
drwxrwx---   1 root vboxsf 16384 6月  12 01:14 sf_F_DRIVE
drwxrwx---   1 root vboxsf  4096 6月  12 11:48 sf_G_DRIVE
$ sudo usermod -a -G vboxsf yourusername
$ reboot
```

**wine**

Wine (wine is not an emulator) is a free and open source compatibility layer software application that aims to allow applications designed for Microsoft Windows to run on Unix-like operating systems.

System disk `~/.wine/drive_c`
- `/Program Files`
- `/Program Files(x86)`
- `/users`
- `/windows`

```shell
$ sudo add-apt-repository ppa:ubuntu-wine/ppa
$ sudo apt-get update
$ sudo apt-get install wine
$ wine --version
$ winecfg  # config wine
$ cd folder
$ wine ./program.exe
```

**chromium**
```shell
$ sudo add-apt-repository ppa:chromium-daily/stable
$ sudo apt-get update
$ sudo apt-get install chromium-browser
```

**skype**
```shell
# Users of 64-bit Ubuntu, should enable MultiArch if it isn't already enabled by running the command:
$ sudo dpkg --add-architecture i386

# Since Ubuntu 10.04 (Lucid Lynx), Skype is part of the Canonical partner repository.
# You can do this by running the command to add the Canonical Partner Repository:
$ sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"

$ sudo apt-get update
$ sudo apt-get install skype
```

**sogoupinyin**
```shell
# download linux version install package from "http://pinyin.sogou.com/linux/?r=pinyin"
# click it to install
# select "fcitx" in "System Settings|Language Support|Keyboard input method system"
# reboot system, and choose "sogoupinyin" for input
```

**monitor**
```shell
$ gnome-system-monitor
$ top
```

**subversion**
```shell
$ sudo apt-get install subversion

# export files to local folder
$ svn export http://192.168.7.3/svn/ --username <user>
```

**vpn server**
```shell
$ sudo apt-get install pptpd
$ sudo vim /etc/pptpd.conf
  # uncomment these lines
  localip 192.168.0.1
  remoteip 192.168.0.234-238,192.168.0.245
$ sudo vim /etc/ppp/chap-secrets
  # add account, * accept connection from all ip addresses
  username pptpd "password" *
$ sudo vim /etc/ppp/pptpd-options
  # modify this line
  ms-dns 8.8.8.8
$ sudo vim /etc/sysctl.conf
  # uncomment this line
  net.ipv4.ip_forward=1
$ sudo sysctl -p
$ sudo apt-get install iptables
$ sudo iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
$ sudo iptables-save > /etc/iptables-rules
$ sudo vim /etc/network/interface
  # add this line in eth0 section
  pre-up iptables-restore < /etc/iptables-rules
$ sudo service pptpd restart
```

**java**
```shell
# openjdk
$ sudo add-apt-repository ppa:openjdk-r/ppa
$ sudo apt-get update
$ apt-cache pkgnames openjdk
openjdk-8-jdk
openjdk-8-jre
...
$ sudo apt-get install openjdk-8-jdk
$ sudo update-alternatives --list java

# if multiple java exist, use following commands to set current java
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
$ java -version

# oracle jdk
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ apt-cache pkgnames oracle-java
```

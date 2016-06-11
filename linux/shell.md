
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

**monitor**
```shell
$ gnome-system-monitor
$ top
```

**zip**
```shell
$ zip dest.zip file1 file2 file3  # compress specified files
$ zip dest.zip -r folder/         # compress all files in folder
$ unzip dest.zip                  # extract to current folder
$ unzip dest.zip -d folder/       # extract to specified folder
```

**subversion**
```shell
$ sudo apt-get install subversion

# export files to local folder
$ svn export http://192.168.7.3/svn/ --username <user>
```

**axel - mutithread download**
- http://www.vpser.net/manage/axel.html

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
```shell 1
# openjdk
$ sudo add-apt-repository ppa:openjdk-r/ppa
$ sudo apt-get update
$ apt-cache pkgnames openjkd
openjdk-8-jdk
openjdk-8-jre
...
$ sudo apt-get install openjdk-8-jdk
$ sudo update-alternatives --list java

# if multiple java exist, use following commands to set current java
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac

# oracle jdk
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ apt-cache pkgnames oracle-java
```

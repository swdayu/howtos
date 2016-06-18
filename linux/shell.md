
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

**monitor**
```shell
$ gnome-system-monitor
$ top
```

**curl**
```shell
# write output to a file with remote time and remote name
$ curl -R -O http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.0.tar.gz
```

**tar**
```shell
$ tar zxf lpeg-1.0.0.tar.gz
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
```shell
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
$ java -version

# oracle jdk
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ apt-cache pkgnames oracle-java
```

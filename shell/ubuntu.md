
## Modify Device Name

Steps
- $ sudo hostname # display current hostname
- $ sudo gedit /etc/hostname
- $ sudo gedit /etc/hosts

After physically reboot your device, the hostname will be updated permanently. 
Check the name display in [System Settings | Details | Overview | **Device name**], 
and the name on the Terminal [username@**hostname**:~$].

## Package Tool

The `apt-get` command is a powerful command-line tool, which works with Ubuntu's *Advanced Packaging Tool (APT)*
performing such functions as installation of new software packages, upgreade of existing software, 
updating of the package list index, and even upgrading the entire Ubuntu system.

Install and remove packages.
```
sudo apt-get install pkg-one pkg-two
sudo apt-get remove pkg-one pkg-two
```

Update the package index: The APT package index is essentially a database of available packages from the repositories
defined in the `/etc/apt/sources.list` file and in the `/etc/apt/sources.list.d` directory.
To update the local package index with the latest changes made in the repositories, type the following:
```
sudo apt-get update
```

Upgrade packages: Over time, updated versions of packages currently installed on your computer may become available
from the package repositories . To upgrade your system, first update your package index, and then type:
```
sudo apt-get upgrade
```

Actions of the `apt-get` command, such as installation and removal of packages, 
are logged in the `/var/log/dpkg.log` log file.

apt-get --help
- update - Retrieve new lists of packages
- upgrade - Perform an upgrade
- install - Install new packages
- remove - Remove packages
- clean - Erase downloaded archive files
- autoclean - Erase old download archive files

Search package
```
sudo apt-cache search pkgname
```

## Wine

Wine (Wine Is Not an Emulator) is a free and open source compatibility layer software application
that aims to allow applications designed for Microsoft Windows to run on Unix-like operating systems.

Install and run on Ubuntu:
```
$ sudo apt-get install wine
$ wine --version
wine-1.4
$ sudo add-apt-repository ppa:ubuntu-wine/ppa
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install wine1.7
$ wine --version
wine-1.7.18
$ winecfg # config wine
$ cd folder
$ wine ./program.exe
```

System disk
- ~/.wine/drive_c
  - /Program Files
  - /Program Files(x86)
  - /users
  - /windows

## Notepadqq

For Ubuntu 14.10, Ubuntu 14.04 and derivatives, Notepadqq 0.46.0 is available via PPA, so installing it is easy. All you have to do is add the ppa to your system, update the local repository index and install the notepadqq package. Like this:
```
$ sudo add-apt-repository ppa:notepadqq-team/notepadqq
$ sudo apt-get update
$ sudo apt-get install notepadqq
```

## Skype

[Ubuntu Skype](https://help.ubuntu.com/community/Skype)

Users of 64-bit Ubuntu, should enable MultiArch if it isn't already enabled by running the command
```
sudo dpkg --add-architecture i386
```
Since Ubuntu 10.04 (Lucid Lynx), Skype is part of the Canonical partner repository. To install Skype add the Canonical Partner Repository. You can do this by running the command
```
sudo add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
```
Then install Skype via the Software-Center or via the Terminal.
```
sudo apt-get update && sudo apt-get install skype
```
It is highly recommended to use the package provided in the Canonical partner repository, not the one distributed from the Skype website. This is how installing via a Ubuntu repository guarantees that the file downloaded and installed is the same one distributed from a Ubuntu repository. However, downloading the file via http doesn't guarantee this outcome. 

## VMWare
```
sudo ./VMware-Workstation-6.5.0-118166.i386.bundle
```

## Chromium
```
sudo add-apt-repository  ppa:chromium-daily/stable
sudo apt-get update
sudo apt-get install chromium-browser
```


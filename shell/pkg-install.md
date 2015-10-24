
# References
- https://help.ubuntu.com/12.04/serverguide/apt-get.html

# Ubuntu

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

## apt-get --help
- update - Retrieve new lists of packages
- upgrade - Perform an upgrade
- install - Install new packages
- remove - Remove packages
- clean - Erase downloaded archive files
- autoclean - Erase old download archive files


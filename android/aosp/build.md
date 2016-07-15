
## Environment

- A 64-bit environment is required for Gingerbread (2.3.x) and newer versions
- At least 100GB of free disk space for a checkout, 150GB for a single build, and 200GB or more for multiple builds
- If you employ ccache, you will need even more space
- If you are running Linux in a virtual machine, you need at least 16GB of RAM/swap
- Android is typically built with a GNU/Linux or Mac OS operating system
- It is also possible to build Android in a virtual machine on unsupported systems such as Windows
- GNU/Linux: Android 6.0 (Marshmallow) - AOSP master: Ubuntu 14.04 (Trusty)
- Mac OS (Intel/x86): Android 6.0 (Marshmallow) - AOSP master: Mac OS v10.10 (Yosemite) or later with Xcode 4.5.2 and Command Line Tools
- The master branch of Android in AOSP requires: Ubuntu - OpenJDK 8, Mac OS - jdk 8u45 or newer
- Android 5.x (Lollipop) - Android 6.0 (Marshmallow) require: Ubuntu - OpenJDK 7, Mac OS - jdk-7u71-macosx-x64.dmg
- Python 2.6 -- 2.7 from python.org
- GNU Make 3.81 -- 3.82 from gnu.org
- Git 1.7 or newer from git-scm.com
- Under GNU/Linux systems (and specifically under Ubuntu systems), regular users can't directly access USB devices by default. The recommended approach is to create a file at /etc/udev/rules.d/51-android.rules (as the root user). To do this, run the following command to download the 51-android.rules file, modify it to include your username, and place it in the correct location.
```shell
$ wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | \
sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules`
```
- Java8 install:
```shell
$ sudo add-apt-repository ppa:openjdk-r/ppa
$ sudo apt-get update
$ apt-cache pkgnames openjdk
$ sudo apt-get install openjdk-8-jdk
$ sudo update-alternatives --list java
$ sudo update-alternatives --config java
$ sudo update-alternatives --config javac
```
- Addtional installs:
```shell
$ sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip python-networkx
```

Device binaries:
- http://source.android.com/source/building.html#obtaining-proprietary-binaries
- https://developers.google.com/android/nexus/blobs-preview
- https://developers.google.com/android/nexus/images
- https://developers.google.com/android/nexus/drivers
- https://developers.google.com/android/nexus/ota


## Downloading the Source

```shell
$ mkdir ~/bin
$ vi ~/.bashrc
export PATH=~/bin:$PATH
$ source ~/.bashrc
$ echo $PATH
$ curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
$ ls -al ~/bin/
-rwxr-xr-x 1 root root 26223 Jul 14 17:29 repo
$ mkdir -p ~/yourname/code/android-6.0.1_r46
$ cd ~/yourname/code/android-6.0.1_r46
$ git config --global user.name "Your Name"
$ git config --global user.email "you@example.com"
$ repo init -u https://android.googlesource.com/platform/manifest -b android-6.0.1_r46
$ repo sync
```

Downloading using [proxychains](https://github.com/massivesupernova/howtos/blob/master/linux/net.md):
```shell
$ proxychains repo init -u https://android.googlesource.com/platform/manifest -b android-6.0.1_r46
$ proxychains repo sync
```

More rarely, Linux clients experience connectivity issues, getting stuck in the middle of downloads.
It has been reported that tweaking the settings of the TCP/IP stack and using non-parallel commands can improve the situation.
You need root access to modify the TCP setting:
```shell
$ sudo sysctl -w net.ipv4.tcp_window_scaling=0
$ repo sync -j1
```

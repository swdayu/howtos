
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
- Java 8 install:

        $ sudo add-apt-repository ppa:openjdk-r/ppa
        $ sudo apt-get update
        $ apt-cache pkgnames openjdk
        $ sudo apt-get install openjdk-8-jdk
        $ sudo update-alternatives --list java
        $ sudo update-alternatives --config java
        $ sudo update-alternatives --config javac

- Addtional installs:

        $ sudo apt-get install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip python-networkx

## USB configuration

Temporary solution:
```shell
$ adb remount
error: insufficient permissions for device: verify udev rules
$ adb devices
List of devices attached
cf7b6337	no permissions
$ which adb
$ cd /home/shenxin/shenxin/android/Sdk/platform-tools/
$ sudo chown root:root adb
$ sudo chmod +s adb
$ adb kill-server
```

http://source.android.com/source/initializing.html

Under GNU/Linux systems (and specifically under Ubuntu systems), regular users can't directly access USB devices by default. The recommended approach is to create a file at `/etc/udev/rules.d/51-android.rules` (as the root user). To do this, run the following command to download the [51-android.rules](http://source.android.com/source/51-android.rules) file, modify it to include your username, and place it in the correct location.

```shell
$ wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee > /dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules
```

51-android.rules:
```
# adb protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e12", MODE="0600", OWNER="<username>"
# fastboot protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", ATTR{idProduct}=="0fff", MODE="0600", OWNER="<username>"
# adb protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e22", MODE="0600", OWNER="<username>"
# fastboot protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e20", MODE="0600", OWNER="<username>"
# adb protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", ATTR{idProduct}=="70a9", MODE="0600", OWNER="<username>"
# fastboot protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="708c", MODE="0600", OWNER="<username>"
# adb protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", MODE="0600", OWNER="<username>"
# fastboot protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e30", MODE="0600", OWNER="<username>"
# adb protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d101", MODE="0600", OWNER="<username>"
# adb protocol on panda (PandaBoard ES)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="d002", MODE="0600", OWNER="<username>"
# fastboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d022", MODE="0600", OWNER="<username>"
# usbboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d00f", MODE="0600", OWNER="<username>"
# usbboot protocol on panda (PandaBoard ES)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d010", MODE="0600", OWNER="<username>"
# adb protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e42", MODE="0600", OWNER="<username>"
# fastboot protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e40", MODE="0600", OWNER="<username>"
# adb protocol on manta (Nexus 10)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee2", MODE="0600", OWNER="<username>"
# fastboot protocol on manta (Nexus 10)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee0", MODE="0600", OWNER="<username>"
# adb protocol on hammerhead (Nexus 5)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee1", MODE="0600", OWNER="<username>"
```

https://developer.android.com/studio/run/device.html

If you're developing on Ubuntu Linux, you need to add a udev rules file that contains a USB configuration for each type of device you want to use for development. In the rules file, each device manufacturer is identified by a unique vendor ID, as specified by the `ATTR{idVendor}` property.

To set up device detection on Ubuntu Linux:
```shell
$ lsusb  # `lsusb -v` show detail info
$ sudo vi /etc/udev/rules.d/51-android.rules
# use this format to add each vendor to the file ("0bb4" for HTC):
# the MODE assignment specifies read/write permissions,
# and GROUP defines which Unix group owns the device node. 
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"
$ chmod a+r /etc/udev/rules.d/51-android.rules
$ sudo udevadm control --reload-rules
$ adb kill-server
$ adb start-server
```

USB Vendor IDs:
```
Company	USB                 Vendor ID
Acer                        0502
ASUS 	                      0b05
Dell 	                      413c
Foxconn 	                  0489
Fujitsu 	                  04c5
Fujitsu Toshiba 	          04c5
Garmin-Asus 	              091e
Google 	                    18d1
Haier 	                    201E
Hisense 	                  109b
HP 	                        03f0
HTC 	                      0bb4
Huawei 	                    12d1
Intel 	                    8087
K-Touch 	                  24e3
KT Tech 	                  2116
Kyocera 	                  0482
Lenovo 	                    17ef
LG 	                        1004
Motorola 	                  22b8
MTK 	                      0e8d
NEC 	                      0409
Nook 	                      2080
Nvidia 	                    0955
OTGV 	                      2257
Pantech 	                  10a9
Pegatron 	                  1d4d
Philips 	                  0471
PMC-Sierra 	                04da
Qualcomm 	                  05c6
SK Telesys 	                1f53
Samsung 	                  04e8
Sharp 	                    04dd
Sony 	                      054c
Sony Ericsson 	            0fce
Sony Mobile Communications  0fce
Teleepoch 	                2340
Toshiba 	                  0930
ZTE 	                      19d2
```

## Device binaries:
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

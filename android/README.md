# Android
- http://source.android.com/source/index.html
- https://developer.android.com/sdk/index.html
- http://androidxref.com/
- https://android.googlesource.com/platform/
- https://source.codeaurora.org/quic/la/platform/

## adb
```shell
# adb remount error: insufficient permissions for device: verify udev rules.
$ vi /etc/udev/rules.d/51-android.rules # add a line of text below
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0666"
$ sudo chmod a+rx /etc/udev/rules.d/51-android.rules
$ sudo service udev restart
$ adb kill-server
$ adb start-server
$ # unplug and plug the usb device
$ adb remount

# check app meminfo
$ adb shell dumpsys meminfo <package-name>/<pid> -d

$ adb shell dumpsys
$ adb logcat -v threadtime
$ adb shell logcat -v threadtime > /sdcard/logcat.txt &
$ adb shell cat /proc/kmsg  # android kernel log

# force stop everything associated with the package name
$ adb shell am force-stop com.example.user.pkgname
# start an activity
$ adb shell am start -n com.android.settings/com.android.settings.bluetooth.BluetoothSettings

# install a package and replace existing application if already exists
$ adb push ~/pkgname-demo.apk /data/local/tmp/com.example.user.pkgname
$ adb shell pm install -r "/data/local/tmp/com.example.user.pkgname"

# list all packages installed
$ adb shell pm list packages

# start an instrumentation
# -w: wait for instrumentation to finish before returning, required for test runners
# -r: print raw results
# -e <name> <value>: set argument <name> to <value>
$ adb shell am instrument -w -r -e debug false -e class com.example.user.pkgname.ApplicationTest \
com.example.user.pkgname.test/android.support.test.runner.AndroidJUnitRunner
```

## android
```shell
# fatal analysis using addr2line
$ addr2line -f -e out/debug/target/product/name/symbols/system/lib/hw/bluetooth.default.so 00019325

$ android list targets
$ mkdir UiTestExample && cd UiTestExample
$ android create uitest-project --name UiTestExample --path . --target "android-23"
# Out of memory error (version 1.2-rc4 'Carnac' (298900 ... by android-jack-team@google.com)).
# GC overhead limit exceeded.
# Try increasing heap size with java option '-Xmx<size>'.
# 1) offical solution
$ vi ~/.jack  # changing SERVER_NB_COMPILE to a lower value
# 2) stackoverflow solution
$ export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4g"
$ ./prebuilts/sdk/tools/jack-admin kill-server
$ ./prebuilts/sdk/tools/jack-admin start-server
```

## Android Studio
- http://developer.android.com/sdk/index.html
- http://developer.android.com/sdk/installing/index.html?pkg=studio

Before you set up Android Studio, be sure you have installed JDK 6 or higher (the JRE alone is not sufficient), 
JDK 7 is required when developing for Android 5.0 and higher.
To check if you have JDK installed (and which version), open a terminal and type `javac -version`.
If the JDK is not available or the version is lower than version 6, 
download the [Java SE Development Kit 7][].

[Java SE Development Kit 7]: http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html

**To set up Android Studio on Windows:**

1. Launch the `.exe` file you just download.
2. Follow the setup wizard to install Android Studio and any necessary SDK tools.
   On some Windows systems, the launcher script does not find where Java is installed.
   If you encounter this problem, you need to set an environment variable indicating the correct location.
   Select **Environment Variables** and add a new system variable `JAVA_HOME` that points to your JDK folder,
   for example `C:\Program Files\Java\jdk1.7.0_21`.

The individual tools and other SDK packages are saved outside the Android Studio application directory.
If you need to access tools directly, use a terminal to navigate to the location where they are installed.
For example: `\Users\<user>\sdk\`.

**To set up Android Studio on Mac OSX:**

1. Launch the `.dmg` file you just download.
2. Drag and drop Android Studio into the Applications folder.
3. Open Android Studio and follow the setup wizard to install any necessary SDK tolls.
   Depending on your security settings, when you attempt to open Android Studio,
   you might see a warning that says the packages is damaged and shoud be moved to the trash.
   If this happens, go to **System Preferences > Security & Privacy** and 
   under **Allow applications downloaded from**, select **Anywhere**.
   The open Android Studio again.

If you need use the Android SDK tools from a command line, you can access them at:
`/Users/<user>/Library/Android/sdk/`.

**To set up Android Studio on Linux:**

1. Unpack the downloaded ZIP file into an appropriate location for your applications.
2. To launch Android Studio, navigate to the `android-studio/bin/` directory in a terminal
   and execute `studio.sh`. You may want to add `android-studio/bin/` to your PATH environment
   variable so that you can start Android Studio from any directory.
3. If the SDK is not already installed, follow the setup wizard to install the SDK and any necessary SDK tools.
   Note: You may also need to install the ia32-libs, lib32ncurses5-dev, and lib32stdc++6 packages.
   These packages are required to support 32-bit apps on a 64-bit machine.

The Android SDK will be installed at `/home/<user>/Android/Sdk` by default.

Android Studio is now ready and loaded with the Android developer tools,
but there are still a couple packages you should add to make your Android SDK complete.

**Adding SDK Packages**

By default, the Android SDK does not include everything you need to start developing.
The SDK separates tools, platforms, and other components into packages 
you can downloaded as needed using the Android SDK Manager.
So before you can start, there are a few packages you should add to your Android SDK.

To start adding packages, launch the Android SDK Manager in one of the following ways:
- In Android Studio, click **SDK Manager** in the toolbar.
- Windows: Double-click the `SDK Manager.exe` file at the root of the Android SDK directory.
- Mac/Linux: Open a terminal and navigate to the `tools/` directory in the location where
  the Android SDK was installed, then execute `android sdk`.

When you open the SDK Manager for the first time, several packages are selected by default.
Leave these selected, but be sure you have everything you need to get started by following these steps:

1. **Get the latest SDK tools**

   As a minimum when setting up the Android SDK, you should download the latest tools and Android platform.
   
   Open the tools directory and select: Android SDK Tools, Android SDK Platform-tools, 
   Android SDK Build-tools (highest version)
   
   Open the first Android X.X folder (the latest version) and select: SDK Platform,
   A system image for the emulator, such as ARM EABI v7a System Image.
   
2. **Get the support library for additional APIs**

   The Android Support Library provides an extended set of APIs that
   are compatible with most versions of Android.
   
   Open the **Extras** directory and select: Android Support Repository, Android Support Library.
   
3. Build something

   With the above packages now in your Android SDK, you're ready to build apps for Android.
   As new tools and other APIs become available, simply launch the SDK Manager 
   to download the new packages for your SDK.
   


## Factory images
- https://developers.google.com/android/nexus/images
- https://source.android.com/source/running.html#booting-into-fastboot-mode

> The factory binary image file allow you to restore your Nexus device's original factory firmware.  
> It includes scripts that flashes the device, typically named `flash-all.sh` or `flash-all.bat` on Windows.  
> To flash a device, you need the latest `fastboot` tool, it can be found in `platform-tools/` under Android SDK.  
> Once you have the `fastboot` and add it to `PATH`, also be certain that you've set up USB access for your device.  
> Flashing a new system image deletes all user data, be certain to first backup data such as photos.  

Flash a system image
> Download the appropriate system image for your device, then unzip it to a safe directory.  
> Switch on "OEM unlocking" in "Developer options" on your device if it is clickable (bootloader locked).  
> Connect the device to your computer over USB.  
> Start fastboot mode using `adb reboot bootloader` or press [Volume Down + Power](https://source.android.com/source/running.html#booting-into-fastboot-mode) for example when device off.  
> If necessary, unlock the device's bootloader by `fastboot flashing/oem unlock`, later is for older devices.  
> Open a terminal and navigate to the unzipped system image directory.  
> Execute `flash-all` scipt, it installs the necessary bootloader, baseband firmwares, and operating system.  
> Once the script finishes, your device reboots. You should now lock the bootloader for security:  
> Start the device in fastboot mode again and execute `fastboot flashing lock` or `fastboot oem lock`.  

An example for the `flash-all` script
>     fastboot flash bootloader bootloader-bullhead-bhz11f.img
    fastboot reboot-bootloader
    sleep 5
    fastboot flash radio radio-bullhead-m8994f-2.6.33.2.14.img
    fastboot reboot-bootloader
    sleep 5
    # files in this zip: boot.img cache.img recovery.img system.img userdata.img vendor.img
    fastboot -w update image-bullhead-nbd90w.zip

## OTA images
- https://developers.google.com/android/nexus/ota

> The OTA binary image file allow you to manually update your Nexus devices.  
> This has the same effect of flashing the corresponding factory images, but without wiping the device.  
> But for safety, be certain to first backup your data such as photos before applying update.  
> To apply an OTA update image, follow steps shown below:  
> Download the appropriate update image for your device.  
> With the device powered on and USB debugging enabled, execute `adb reboot recovery`.  
> Hold "Power" button and press "Volume Up" once, select "Apply update from ADB" from shown menu.  
> Run the command `adb sideload your_ota_file.zip`.  
> Once the update finishes, you should reboot the phone by choosing `Reboot the system now`.  
> For device security, you should disable USB debugging when it is not being updated.  

## Android versions and builds

| Build | Branch | Version |
| :---- | :----- | :------ |
| NBD90W (Nexus 5X) | android-7.0.0_r12 | Nougat (API level 24) |
| NRD90S (Nexus 5X) | android-7.0.0_r4 | Nougat (API level 24) |
| NRD90R (Nexus 5X) | android-7.0.0_r3 | Nougat (API level 24) |
| NRD90M (Nexus 5X) | android-7.0.0_r1 | Nougat (API level 24) |
| MTC20K (Nexus 5X) | android-6.0.1_r67 | Marshmallow (API level 23) |
| MTC20F (Nexus 5X) | android-6.0.1_r62 | Marshmallow (API level 23) |
| MTC19Z (Nexus 5X) | android-6.0.1_r54 | Marshmallow (API level 23) |
| MTC19V (Nexus 5X) | android-6.0.1_r45 | Marshmallow (API level 23) |
| MTC19T (Nexus 5X) | android-6.0.1_r25 | Marshmallow (API level 23) |
| MHC19Q (Nexus 5X) | android-6.0.1_r24 | Marshmallow (API level 23) |
| MHC19J (Nexus 5X) | android-6.0.1_r22 | Marshmallow (API level 23) |
| MMB29V (Nexus 5X) | android-6.0.1_r17 | Marshmallow (API level 23) |
| MMB29Q (Nexus 5X) | android-6.0.1_r11 | Marshmallow (API level 23) |
| MMB29P (Nexus 5X) | android-6.0.1_r8 | Marshmallow (API level 23) |
| MMB29K (Nexus 5X) | android-6.0.1_r1 | Marshmallow (API level 23) |
| MDB08M (Nexus 5X) | android-6.0.0_r26 | Marshmallow (API level 23) |
| MDB08L (Nexus 5X) | android-6.0.0_r25 | Marshmallow (API level 23) |
| MDB08I (Nexus 5X) | android-6.0.0_r23 | Marshmallow (API level 23) |
| MDA89E (Nexus 5X) | android-6.0.0_r12 | Marshmallow (API level 23) |

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
$ cd android/Sdk/platform-tools/
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

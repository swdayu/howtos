# Android
- https://developer.android.com/sdk/index.html
- http://androidxref.com/

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

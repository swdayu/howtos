# Android
- https://developer.android.com/sdk/index.html
- http://androidxref.com/

## adb
```shell
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
```

# Android
- https://developer.android.com/sdk/index.html
- http://androidxref.com/

## adb
```shell
$ adb shell dumpsys
$ adb logcat -v threadtime
$ adb shell logcat -v threadtime > /sdcard/logcat.txt &
$ adb shell cat /proc/kmsg  # android kernel log
```

## android
```shell
$ android list targets
$ mkdir UiTestExample && cd UiTestExample
$ android create uitest-project --name UiTestExample --path . --target "android-23"
```

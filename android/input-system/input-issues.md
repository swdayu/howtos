
1. Android平板可以与蓝牙键盘连接和输入文体，但少数按键不响应（ESC、锁屏键、搜索键等）

```shell
$ adb shell cat /proc/bus/input/devices  # Vendor_<Vendor>_Product_<Product>.kl
$ adb shell ls -al /system/usr/keylayout
$ adb shell cat /system/usr/keylayout/Generic.kl | grep BACK
key 43    BACKSLASH
key 86    BACKSLASH
key 158   BACK
$ adb pull /system/usr/keylayout/ .
$ echo "key 172   BACK" >> Vendor_05ac_Product_0239.kl  # ESC's scancode is 172, use ESC as BACK
$ adb push Vendor_05ac_Product_0239.kl /system/usr/keylayout/
```

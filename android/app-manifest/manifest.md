
# <manifest>

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.example.BLESettings"
  android:sharedUserId="string"
  android:sharedUserLabel="string_resource" 
  android:versionCode="1.0"
  android:versionName="stable 1.0"
  android:installLocation=["auto"|"internalOnly"|"preferExternal"] >
  ...
</manifest>
```

这个元素是Manifest的根元素，必须包含一个<application>子元素，以及指定xmlns:android和package属性，
它还可以包含的子元素是<compatible-screens>,<instrumentation>, <permission>, <permission-group>, 
<permission-tree>, <supports-gl-texture>, <supports-screens>, <uses-configuration>, <uses-feature>, 
<uses-permission>, <uses-permission-sdk-23>, <uses-sdk>。

**android:sharedUserId**

> The name of a Linux user ID that will be shared with other applications. 
By default, Android assigns each application its own unique user ID. 
However, if this attribute is set to the same value for two or more applications, 
they will all share the same ID - provided that they are also signed by the same certificate. 
Application with the same user ID can access each other's data and, if desired, run in the same process.

默认Android给每个应用赋予一个唯一的user ID。
然而如果指定两个或多个应用相同的该属性，它们就共享同一个ID。
共享同一个ID的应用可以访问每一个应用的数据，如果需要还可以运行在同一个进程中。


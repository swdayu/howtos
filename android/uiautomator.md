
```
UiAutomator有待彻底弄清之问题：
1. 如何在测试过程中优雅地启动其他应用？
2. 如何识别和解析WebView里的内容？
3. 如果脱离PC在设备上自动执行测试？
4. 1.0版和２.0版的区别是什么？

当前线索：
https://developer.android.com/reference/android/support/test/uiautomator/package-summary.html
https://developer.android.com/reference/android/webkit/WebView.html
https://www.reddit.com/r/androiddev/comments/2h92bv/has_anyone_every_used_accessibilitynodeprovider/
https://developer.android.com/reference/android/support/v4/view/accessibility/package-summary.html
https://developer.android.com/training/testing/ui-testing/uiautomator-testing.html
http://bitbar.com/how-to-get-started-with-ui-automator-2-0/
http://tmq.qq.com/2017/03/uizidonghua/
http://tmq.qq.com/page/2/?s=uiautomator
http://tmq.qq.com/2016/06/androidautotestframwork-uiautomator/
https://www.zhihu.com/question/28886583
https://tieba.baidu.com/p/4540154719
https://jingyan.baidu.com/article/ca2d939d2a88b2eb6c31cef3.html
http://www.jb51.net/article/100676.htm

UiAutomator 2.0是基于intrumentation实现的，不像1.0那样可以在uiautomator命令中使用--nohup选项是测试脱离PC运行。
版本1.0一般在Eclipse+ANT环境中编译，生成jar包然后push到手机中进程测试，1.0能否在Android Studio+Gradle中编译呢？
网友的一种尝试是：http://wiliamsouza.github.io/#/2013/10/30/android-uiautomator-gradle-build-system
而2.0是在Gradle中编译的，生成的apk文件，然后使用instrument命令进行测试。instrument命名是否像uiautomator那样支持nohup呢？
网友的说法是可以：adb shell nohup am instrument -w ...
The nohup command ensures that am instrument continues running after the shell session terminates
(e.g. when you disconnect your USB connection).
http://stackoverflow.com/questions/37655167/running-uiautomator-2-0-test-cases-without-usb-connected?noredirect=1
有没有办法脱离adb直接在设备中启动UiAutomator自动测试呢？网友的一种方法是使用system签名写一个的apk，然后去启动自动测试。
http://blog.csdn.net/cxq234843654/article/details/52605441

UiAutomator怎么启动指定应用？用MonkeyRunner的时候可以使用
MonkeyDevice.startActivity(component="com.mediatek.filemanager/.FileManagerOperationActivity")
启动某个应用，但UiAutomator尝试用Runtime.getRuntime().exec("cmd /k start adb shell am start -n 
com.android.contacts/.activities.PeopleActivity")会提示错误，但写在普通的非测试代码里Runtime运行命令有是可行的。
UiAutomator是黑盒测试工具，它的作用就是模拟用户的动作，所以要用uia启动一个应用的正确方法就是用它写一系列的操作步骤将app打开：
点击home键--〉点击应用键--〉点击app的图标。
其他启动的应用的代码：
---
device.wakeUp();
//滑动解锁
device.swipe(device.getDisplayWidth() / 2, device.getDisplayHeight() - 100, device.getDisplayWidth() / 2, device.getDisplayHeight() / 2, 5);
Context context=InstrumentationRegistry.getContext();
Intent launchIntent = new Intent();
launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//启动应用
launchIntent.setComponent(new ComponentName("com.tupo.xuetuan.student", "com.tupo.xuetuan.student.activity.StartActivity"));
context.startActivity(launchIntent);
---
Context context = InstrumentationRegistry.getInstrumentation().getContext();
//sets the intent to start your app
Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageNameOfYourApp);  
intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
//starts the app
context.startActivity(intent);
---
private String getLauncherPackageName() {
// Create launcher Intent
    final Intent intent = new Intent(Intent.ACTION_MAIN);
    intent.addCategory(Intent.CATEGORY_HOME);

    // Use PackageManager to get the launcher package name
    PackageManager pm = InstrumentationRegistry.getContext().getPackageManager();
    ResolveInfo resolveInfo = pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY);
    return resolveInfo.activityInfo.packageName;
}
@Before
public void startMainActivityFromHomeScreen() {
// Initialize UiDevice instance
    mDevice = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());

    // Start from the home screen
    mDevice.pressHome();

    // Wait for launcher
    final String launcherPackage = getLauncherPackageName();

    mDevice.wait(Until.hasObject(By.pkg(launcherPackage).depth(0)), LAUNCH_TIMEOUT);

    // Launch the blueprint app
    Context context = InstrumentationRegistry.getContext();
    final Intent intent = context.getPackageManager().getLaunchIntentForPackage(BASIC_SAMPLE_PACKAGE);
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);    // Clear out any previous instances
    context.startActivity(intent);
    // Wait for the app to appear
    mDevice.wait(Until.hasObject(By.pkg(BASIC_SAMPLE_PACKAGE).depth(0)), LAUNCH_TIMEOUT);
}
```

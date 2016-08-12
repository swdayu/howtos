
## UI Automator
- https://developer.android.com/studio/test/index.html
- https://developer.android.com/topic/libraries/testing-support-library/index.html#Espresso
- https://developer.android.com/topic/libraries/testing-support-library/index.html#UIAutomator
- https://developer.android.com/reference/android/support/test/package-summary.html
- https://developer.android.com/training/testing/ui-testing/uiautomator-testing.html
- https://developer.android.com/training/testing/unit-testing/instrumented-unit-tests.html#build
- https://developer.android.com/training/testing/ui-testing/index.html

The UI Automator testing framework provides a set of APIs to build UI tests that perform interactions on user apps and system apps. The UI Automator APIs allows you to perform operations such as opening the Settings menu or the app launcher in a test device. The UI Automator testing framework is well-suited for writing black box-style automated tests, where the test code does not rely on internal implementation details of the target app.

The key features of the UI Automator testing framework include:
- A viewer to inspect layout hierarchy. For more information, see UI Automator Viewer.
- An API to retrieve state information and perform operations on the target device. For more information, see Access to device state.
- APIs that support cross-app UI testing. For more information, see UI Automator APIs .

The UI Automator APIs let you interact with visible elements on a device, regardless of which Activity is in focus. Your test can look up a UI component by using convenient descriptors such as the text displayed in that component or its content description. UI Automator tests can run on devices running Android 4.3 (API level 18) or higher.

The UI Automator testing framework is an instrumentation-based API and works with the `AndroidJUnitRunner` test runner.


Automate UI tests with Android Studio:

- Android tests are based on [JUnit](http://junit.org/), and you can run them either as local unit tests on the JVM or as instrumented tests on an Android device. [Download and install JUnit4](https://github.com/junit-team/junit4/wiki/Download-and-Install)

- Download [Android Testing Support Library](https://developer.android.com/tools/testing-support-library/index.html) in  Android SDK Manager

- After download, the library is installed under the folder `<android-sdk>/extra/android/m2repository/`, and related classes are located under the `android.support.test` package

- To use the Android Testing Support Library in Gradle project, add these dependencies in your `build.gradle` file

        dependencies {
          androidTestCompile 'com.android.support.test:runner:0.4'
          // Set this dependency to use JUnit 4 rules
          androidTestCompile 'com.android.support.test:rules:0.4'
          // Set this dependency to build and run Espresso tests
          androidTestCompile 'com.android.support.test.espresso:espresso-core:2.2.1'
          // Set this dependency to build and run UI Automator tests
          androidTestCompile 'com.android.support.test.uiautomator:uiautomator-v18:2.1.2'
        }

- To set `AndroidJUnitRunner` as the default test instrumentation runner in Gradle project, specify this dependency in your `build.gradle` file

        android {
          defaultConfig {
            testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
          }
        }

- Inspect the layout hierarchy and view the properties of target app's UI components using `uiautomatorviewer`

  > Generally, app developers get accessibility support for free, courtesy of the `View` and `ViewGroup` classes. However, some apps use custom view elements to provide a richer user experience. Such custom elements won't get the accessibility support that is provided by the standard Android UI elements. If this applies to your app, make sure that it exposes the custom-drawn UI element to Android accessibility services by implementing the `AccessibilityNodeProvider` class.

  > If the custom view element contains a single element, make it accessible by [implementing accessibility API methods](https://developer.android.com/guide/topics/ui/accessibility/apps.html#accessibility-methods). If the custom view contains elements that are not views themselves (for example, a `WebView`, make sure it implements the `AccessibilityNodeProvider` class. For container views that extend an existing container implementation (for example, a `ListView`), implementing `AccessibilityNodeProvider` is not necessary.

  > For more information about implementing and testing accessibility, see [Making Applications Accessible](https://developer.android.com/guide/topics/ui/accessibility/apps.html).

- Implement your test code in a separate Android test folder (`src/androidTest/java`)

  > Your UI Automator test class should be written the same way as a JUnit 4 test class. To learn more about creating JUnit 4 test classes and using JUnit 4 assertions and annotations, see [Create an Instrumented Unit Test Class](https://developer.android.com/training/testing/unit-testing/instrumented-unit-tests.html#build). 
  
  > Add `@RunWith(AndroidJUnit4.class)` annotation at the beginning of your test class definition

  > Get a `UiDevice` object to access the device you want to test, by calling the `getInstance()` method and passing it an `Instrumentation` object as the argument.
  
  > Get a `UiObject` object to access a UI component that is displayed on the device (for example, the current view in the foreground), by calling the `findObject()` method. 
  
  > Simulate a specific user interaction to perform on that UI component, by calling a `UiObject` method; for example, call `performMultiPointerGesture()` to simulate a multi-touch gesture, and `setText()` to edit a text field.
  
  > Check that the UI reflects the expected state or behavior, after these user interactions are performed. 

- To run your UI Automator test, refer to https://github.com/googlesamples/android-testing, https://developer.android.com/training/testing/index.html

In your JUnit 4 test class, you can call out sections in your test code for special processing by using the following annotations:

- @Before: Use this annotation to specify a block of code that contains test setup operations. The test class invokes this code block before each test. You can have multiple @Before methods but the order in which the test class calls these methods is not guaranteed.
  
- @After: This annotation specifies a block of code that contains test tear-down operations. The test class calls this code block after every test method. You can define multiple @After operations in your test code. Use this annotation to release any resources from memory.
  
- @Test: Use this annotation to mark a test method. A single test class can contain multiple test methods, each prefixed with this annotation.
  
- @Rule: Rules allow you to flexibly add or redefine the behavior of each test method in a reusable way. In Android testing, use this annotation together with one of the test rule classes that the Android Testing Support Library provides, such as ActivityTestRule or ServiceTestRule.
  
- @BeforeClass: Use this annotation to specify static methods for each test class to invoke only once. This testing step is useful for expensive operations such as connecting to a database.
  
- @AfterClass: Use this annotation to specify static methods for the test class to invoke only after all tests in the class have run. This testing step is useful for releasing any resources allocated in the @BeforeClass block.
  
- @Test(timeout=): Some annotations support the ability to pass in elements for which you can set values. For example, you can specify a timeout period for the test. If the test starts but does not complete within the given timeout period, it automatically fails. You must specify the timeout period in milliseconds, for example: @Test(timeout=5000).

For more annotations, see the documentation for JUnit annotations and the Android annotations.

Use the JUnit Assert class to verify the correctness of an object's state. The assert methods compare values you expect from a test to the actual results and throw an exception if the comparison fails. Assertion classes describes these methods in more detail.


An example in [Testing UI for Multiple Apps](https://developer.android.com/training/testing/ui-testing/uiautomator-testing.html#build):
```java
import org.junit.Before;
import android.support.test.runner.AndroidJUnit4;
import android.support.test.uiautomator.UiDevice;
import android.support.test.uiautomator.By;
import android.support.test.uiautomator.Until;
...

@RunWith(AndroidJUnit4.class)
@SdkSuppress(minSdkVersion = 18)
public class ChangeTextBehaviorTest {

  private static final String BASIC_SAMPLE_PACKAGE
      = "com.example.android.testing.uiautomator.BasicSample";
  private static final int LAUNCH_TIMEOUT = 5000;
  private static final String STRING_TO_BE_TYPED = "UiAutomator";
  private UiDevice mDevice;

  @Before
  public void startMainActivityFromHomeScreen() {
    // Initialize UiDevice instance
    mDevice = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());

    // Start from the home screen
    mDevice.pressHome();

    // Wait for launcher
    final String launcherPackage = mDevice.getLauncherPackageName();
    assertThat(launcherPackage, notNullValue());
    mDevice.wait(Until.hasObject(By.pkg(launcherPackage).depth(0)), LAUNCH_TIMEOUT);

    // Launch the app
    Context context = InstrumentationRegistry.getContext();
    final Intent intent = context.getPackageManager().getLaunchIntentForPackage(BASIC_SAMPLE_PACKAGE);
    // Clear out any previous instances
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
    context.startActivity(intent);

    // Wait for the app to appear
    mDevice.wait(Until.hasObject(By.pkg(BASIC_SAMPLE_PACKAGE).depth(0)), LAUNCH_TIMEOUT);

    UiObject cancelButton = mDevice.findObject(new UiSelector()
        .text("Cancel"))
        .className("android.widget.Button"));

    UiObject okButton = mDevice.findObject(new UiSelector()
        .text("OK"))
        .className("android.widget.Button"));

    // Simulate a user-click on the OK button, if found.
    if(okButton.exists() && okButton.isEnabled()) {
        okButton.click();
    }
    
    // If more than one matching element is found, the first matching element in the layout hierarchy
    // is returned as the target UiObject. When constructing a UiSelector, you can chain together
    // multiple properties to refine your search. If no matching UI element is found, a
    // UiAutomatorObjectNotFoundException is thrown.

    // You can use the childSelector() method to nest multiple UiSelector instances. For example,
    // the following code example shows how your test might specify a search to find the first
    // ListView in the currently displayed UI, then search within that ListView to find a UI element
    // with the text property Apps.

    // As a best practice, when specifying a selector, you should use a Resource ID (if one is assigned
    // to a UI element) instead of a text element or content-descriptor. Not all elements have a text
    // element (for example, icons in a toolbar). Text selectors are brittle and can lead to test
    // failures if there are minor changes to the UI. They may also not scale across different
    // languages; your text selectors may not match translated strings.

    UiObject appItem = new UiObject(new UiSelector()
        .className("android.widget.ListView")
        .instance(1)
        .childSelector(new UiSelector()
        .text("Apps")));
    
    // The UI Automator testing framework allows you to send an Intent or launch an Activity without
    // using shell commands, by getting a Context object through getContext().

    // The following snippet shows how your test can use an Intent to launch the app under test. This
    // approach is useful when you are only interested in testing the calculator app, and don't care
    // about the launcher.
    
    // Launch a simple calculator app
    Context context = getInstrumentation().getContext();
    Intent intent = context.getPackageManager().getLaunchIntentForPackage(CALC_PACKAGE);
    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK); // Clear out any previous instances
    context.startActivity(intent);
    mDevice.wait(Until.hasObject(By.pkg(CALC_PACKAGE).depth(0)), TIMEOUT);

    // Use the UiCollection class if you want to simulate user interactions on a collection of items
    // (for example, songs in a music album or a list of emails in an Inbox). To create a UiCollection
    // object, specify a UiSelector that searches for a UI container or a wrapper of other child UI
    // elements, such as a layout view that contains child UI elements.

    // The following code snippet shows how your test might construct a UiCollection to represent a
    // video album that is displayed within a FrameLayout.

    UiCollection videos = new UiCollection(new UiSelector()
        .className("android.widget.FrameLayout"));

    // Retrieve the number of videos in this collection:
    int count = videos.getChildCount(new UiSelector()
        .className("android.widget.LinearLayout"));

    // Find a specific video and simulate a user-click on it
    UiObject video = videos.getChildByText(new UiSelector()
        .className("android.widget.LinearLayout"), "Cute Baby Laughing");
    video.click();

    // Simulate selecting a checkbox that is associated with the video
    UiObject checkBox = video.getChild(new UiSelector()
        .className("android.widget.Checkbox"));
    if(!checkBox.isSelected()) checkbox.click();

    // Use the UiScrollable class to simulate vertical or horizontal scrolling across a display.
    // This technique is helpful when a UI element is positioned off-screen and you need to scroll
    // to bring it into view.

    // The following code snippet shows how to simulate scrolling down the Settings menu and
    // clicking on an About tablet option.

    UiScrollable settingsItem = new UiScrollable(new UiSelector()
        .className("android.widget.ListView"));
    UiObject about = settingsItem.getChildByText(new UiSelector()
        .className("android.widget.LinearLayout"), "About tablet");
    about.click();

    // The InstrumentationTestCase extends TestCase, so you can use standard JUnit Assert methods
    // to test that UI components in the app return the expected results.

    // The following snippet shows how your test can locate several buttons in a calculator app,
    // click on them in order, then verify that the correct result is displayed.

    // Enter an equation: 2 + 3 = ?
    mDevice.findObject(new UiSelector()
        .packageName(CALC_PACKAGE).resourceId("two")).click();
    mDevice.findObject(new UiSelector()
        .packageName(CALC_PACKAGE).resourceId("plus")).click();
    mDevice.findObject(new UiSelector()
        .packageName(CALC_PACKAGE).resourceId("three")).click();
    mDevice.findObject(new UiSelector()
        .packageName(CALC_PACKAGE).resourceId("equals")).click();

    // Verify the result = 5
    UiObject result = mDevice.findObject(By.res(CALC_PACKAGE, "result"));
    assertEquals("5", result.getText());
  }
}
```

## 命令行运行Gradle
原文地址：https://developer.android.com/studio/build/building-cmdline.html

使用Gradle编译有两种模式：调试模式和发布模式。
但不管是哪种模式，应用在安装到目标设备上之前必须进行签名。
在调试模式下编译时会使用调试密钥，而发布模式会使用你自己的私有密钥。

1. 下载和安装[Gradle](https://gradle.org/)，并将Gradle加入可执行路径PATH
2. 设置Java SDK环境变量JAVA_HOME，例如`export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/"`
3. 在工程目录下运行`gradle wrapper --gradle-version <version-number>`生成Gradle wrapper，它能保证其他人使用一致的环境来编译你的工程
4. 接下来就可以使用`./gradlew <task>`运行工程中的gradle任务（运行`./gradlew tasks`可以查看所有的Gradle任务）
5. 运行`./gradew assembleDebug`或`./gradew assembleRelease`构建应用

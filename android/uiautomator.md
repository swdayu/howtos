
# UiAutomator
- https://developer.android.com/reference/android/support/test/uiautomator/package-summary.html
- https://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html

> the uiautomator testing framework is an instrumentation-based API and works with the AndroidJUnitRunner test runner

Use resource-id as possible
> when specifying a selector, you should use a Resource ID instead of a text or content-descriptor  
> text selectors are brittle and can lead to test failures if there are minor changes to the UI  
> they may also not scale across different languages; your text selectors may not match translated strings  

Send Intent or launch an Activity
> the uiautomator testing framework allows you to send an Intent or launch an Activity without using shell commands, by getting a Context object through getContext() or getting a Instrumentation object through getInstrumentation()
```java
Context context = InstrumentationRegistry.getContext();
context.startActivity(intent);
context.sendBroadcast(intent);
Instrumentation instrument = InstrumentationRegistry.getInstrumentation();
Activity activity = instrument.startActivitySync(intent);
```

Verifying results
> the InstrumentationTestCase extends TestCase, so you can use standard JUnit Assert methods to test that UI components in the app return the expected results (http://junit.org/junit4/javadoc/latest/org/junit/Assert.html).

## UiDevice (android.support.test.uiautomator.UiDevice)
> it provides access to state information about the device, and also    
> can be used to simulate user actions on the device, such as pressing p-pad or Home and Menu buttons   

UiDevice.getInstance(Instrumentation instrumentation)
> retrieve a singleton instance of UiDevice

String getProductName()
> retrieve the product name of the device

String getLauncherPackageName()
> retrieve default launcher package name  
> Launcher - the default application that running after press HOME button

String getCurrentPackageName()
> retrieve the name of the last package to report accessibility events  

int getDisplayHeight/Width()
> get the height/width of the display, in pixels

Point getDisplaySizeDp()
> return the display size in dp (device-independent pixel)  

int getDisplayRotation()
> return the current ratation of the display   
> Surface.ROTATION_0 (natural orientation), ROTATION_90/180/270

void freezeRotation()
> disable the sensors and freeze the device rotation at its current rotation state  

void unfreezeRotation()
> reenable the sensors and unfreeze the device rotation allowing its contents to rotate with the device physical rotation  
> during a test excution, it is best to keep the device frozen in a specific orientation until the test case execution has completed  

void setOrientationNatural/Left/Right()
> simulate orienting the device into its natural/left/right orientation and also freeze rotation by disabling the sensors  

boolean isNaturalOrientation()
> check if the device is in its natural orientation  

UiObject findObject(UiSelector selector)
> return a UiObject which represents a view that matches the selector

boolean takeScreenshot(File storePath[, float scale, int quality])
> take a screenshot of current window and store it as PNG with scale (1.0f default) and quality (90% default)

void setCompressedLayoutHeirarchy(boolean compressed)
> enable or disable layout hierarchy compression  
> if enabled, the layout hierarchy derived from the Acessibility framework will only contain nodes that are important for uiautomator testing  
> any unnessary surrounding layout nodes that make viewing and searching the hierarchy inefficient are removed  

void dumpWindowHierarchy(File dest/OutputStream out)
> dump the current window hierarchy to a File or an OutputStream

void clearLastTraversedText()
> clear the text from the last UI traversal event

void getLastTraversedText()
> retrieve the text from the last UI traversal event received  
> you can use this method to read the contents in a WebView container because the accessibility framework fires events as each text is highlighted  
> you can write a test to perform directional arrow presses to focus on different elements inside a WebView, and call this method to get the text from each traversed element  
> if you are testing a view container that can return a reference to a DOM object, your test should use the view's DOM instead  

void wakeUp()
> simulate pressing the power button if the screen is OFF else it does nothing

void sleep()
> this method simply presses the power buttom if the screen if ON else it does nothing

boolean isScreenOn()
> check the power manager if the screen is ON

boolean openNotification()
> open the notification column

boolean openQuickSettings()
> open the Quick Settings shade  

boolean pressHome()
> simulate a short press on the HOME button

boolean pressBack()
> simulate a short press on the BACK button

boolean pressKeyCode(int keyCode, int metaState)
> simulate a short press using a key code

boolean pressDelete()
> simulate a short press on the DELETE key

boolean pressEnter()
> simulate a short press on the ENTER key

R wait(SearchCondition<R> condition, long timeout)
> wait for given condition to be met, timeout is the maximum amount of time to wait in ms  
> the return value R is the final result returned by the condition

void waitForIdle([long timeout])
> wait for the current application to idle

boolean waitForWindowUpdate(String packageName, long timeout)
> wait for a window content update event to occur  
> the specified window package name can be null and a window update from any front-end window will end the wait  
> if a package name for the window is specified, but the current window doesn't have the same package name, the function returns immediately   
> return true fi a window update occurred, otherwise timeout has elapsed or the current window does not have the specified package name   


## InstrumentationRegistry (android.support.test.InstrumentationRegistry)
> an exposed registry instance that holds a reference to the instrumentation running in the process and it's arguments  
> also provide an easy way for callers to get a hold of instrumentation, application context and instrumentation arguments Bundle  

InstrumentationRegistry.getContext()
> return the Context of this instrumentation's package

InstrumentationRegistry.getInstrumentation()
> returns the instrumentation currently running

InstrumentationRegistry.getTargetContext()
> return a Context for the target application being instrumented

InstrumentationRegistry.getArguments()
> return a copy of instrumentation arguments Bundle


## Until (android.support.test.uiautomator.Until)
> provide factory methods for constructing common conditions

SearchCondition<Boolean> Until.hasObject(BySelector selector)
> return a SearchCondition that is satisfied when at least one element matching the selector can be found

SearchCondition<Boolean> Until.gone(BySelector selector)
> return a SearchCondition that is satisfied when no elements matching the seletor can be found

EventCondition<Boolean> Until.newWindow()
> return a condition that depends on a new window having appeared

EventCondition<Boolean> Until.scrollFinished(Direction direction)
> return a condition that depends on a scroll having reached the end in the given direction


## By (android.support.test.uiautomator.By)
> By is a utility class which enables the creation of BySelector in a concise manner  
> its primary function is to provide static factory methods for constructing BySelector using a shortened syntax  
> for example, you would use findObject(By.text("foo")) rather than findObject(new BySelector().text("foo")) to select UI elements with the text value "foo"

BySelector By.pkg(String/Pattern applicationPackage)
> select the application package name

BySelector By.depth(int depth)
> select the depth

BySelector By.text(String/Pattern text)
> select the text value

BySelector By.textContains(String substring)
> select the containing text value

BySelector By.textStartsWith(String substring)
> select the starting text value

BySelector By.textEndsWith(String substring)
> select the ending text value


## UiSelector (android.support.test.uiautomator.UiSelector)
> specify the elements in the layout hierachy for tests   
> filtered by properties such as text value, content-description, class name, state info, location  

UiSelector()
> construct the UiSelector object

String toString()
> convert the UiSelector to the string representation

UiSelector childSelector(UiSelector selector)
> add a child UiSelector to this selector  
> use this selector to narrow the search scope to child widgets under a specific parent widget  
```java
//(0) LinearLayout
//    (0) FrameLayout
//    (1) FrameLayout
//        (0) TextView
//        (1) TextView
UiObject textView0 = mDevice.findObject(new UiSelector()
    .className("android.widget.LinearLayout").index(0)
      .childSelector(new UiSelector().className("android.widget.FrameLayout").index(1)
        .childSelector(new UiSelector().className("android.widget.TextView").instance(0))));
```

UiSelector fromParent(UiSelector selector)
> adds a child UiSelector to this selector which is used to start search from the parent widget  
> use this selector to narrow the search scope to sibling widgets as well all child widgets under a parent

UiSelector text/textContains/textMatches/textStartsWith(String text)
> select the element matches the text

UiSelector description() descriptionContains/Matches/StartsWith(String text)
> select the element matches the specified content-description property

UiSelector resourceId(String id) resourceIdMatches(String regex)
> select the element matches the specified resource id

UiSelector className(String className/Class<T> type) classNameMatches(String regex)
> select the element matches the specified class property

UiSelector packageName(String name) packageNameMatches(String regex)
> select the element matches the package name of the application that contains the widget

UiSelector instance(int instance)
> select the element matches the specified instance number  
> the instance value must be 0 or greater, where the first instance is 0  
```java
// select the third image is enabled in a UI screen
new UiSelector().className("android.widget.ImageView") .enabled(true).instance(2); 
```

UiSelector index(int index)
> select the element matches the specified node index in the layout hierarchy  
> the index value must be 0 or greater  
> using the index can be unreliable and should only be used as a last resort for matching  

UiSelector checkable/checked/clickable/enabled/focusable/focused/longClickable/scrollable/selected(boolean value)
> select the element in the specified state


## UiObject (android.support.test.uiautomator.UiObject)
> a UiObject is a representation of a view, it is not in any way directly bound to a view as an object reference    
> it contains information to help it locate a matching view at runtime based on the UiSelector properties specified in its constructor    
> once you create an instance of a UiObject, it can be reused for different views that match the selector criteria   

UiObject UiDevice.findObject(UiSelector selector)  
> create a UiObject that matching the selector

UiObject getChild(UiSelector selector)
> create a new UiObject for a child view that is under the present UiObject

UiObject getFromParent(UiSelector selector)
> create a new UiObject for a sibling view or a child of the sibling view, relative to the present UiObject  

int getChildCount()
> count the child views immediately under the present UiObject

boolean setText(String text)
> set the text in an editable field, it will clear the field's content firstly

void clearTextField()
> clear the existing text contents in an editable field

String getText/ContentDescription/ClassName/PackageName()
> read the text/content_desc/className/package property of the UI element

Rect getBounds()
> return the view's bounds property   

Rect getVisibleBounds()
> return the visible bounds of the view   
> if a portion of the view is visible, only the bounds of the visible portion are reported  

boolean isCheckable/Checked/Clickable/Enabled/Focusable/Focused/LongClickable/Scrollable/Selected()
> check if the UI element's checkable/checked/clickable ... property is currently true

boolean click()
> perform a click at the center of the visible bounds of the UI element represented by this UiObject

boolean clickAndWaitForNewWindow([long timeout])
> perform a click at the center of the visible bounds and wait for window transitions  

boolean clickBottonRight/TopLeft()
> click the bottom-right corner or top-left corner ot the UI element

boolean longClick()
> long clicks the center of the visible bounds of the UI element

boolean longClickBottomRight/TopLeft()
> long click on the bottom-right or top-left corner ot the UI element

boolean dragTo(UiObject destObj, int steps)
> drag this object to destination UiObject, you can increase or decrease the steps (usually 40) to change the speed  
> the number of steps can influence the drag speed, and varying speeds may impact the results   
> consider evaluating different speeds when using this method in your tests  

boolean dragTo(int destX, int destY, int steps)
> drag this object to arbitrary coordinates

boolean swipeDown/Left/Right/Up(int steps)
> perform the swipe down/left/right/up action on the UiObject

boolean performMultiPointerGesture(PointerCoords... touches)
> perform a multi-touch gesture

boolean performTwoPointerGesture(Point startPoint1, startPoint2, endPoint1, endPoint2, int steps)
> generate a two-pointer gesture with arbitrary starting and ending points   
> the number of steps are injected about 5ms apart, so 100 steps may take around 0.5s to complete  

boolean pinchIn(int percent, int steps)
> perform a two-pointer gesture, where each pointer moves diagonally toward the other   
> it will move the percentage of the object's diagonal length for the pinch gesture   
> the number of steps are injected about 5ms apart, so 100 steps may take around 0.5s to complete  

boolean pinchOut(int percent, int steps)
> perform a two-pointer gesture, where each pointer moves diagonally opposite across the other, from the center out towards the edge of this UiObject  

boolean exists()
> check if view exists, this method perform a waitForExists() with zero timeout  
> this basically returns immediately whether the view represented by this UiObject exists or not  

boolean waitForExists(long timeout)
> wait a specified length of time for a view to become visible  
> this method waits until the view becomes visible on the display, or until the timeout has elapsed   
> you can use this method in situations where the content that you want to select is not immediatly displayed  

boolean waitUntilGone(long timeout)
> wait a specified length of time for a view to become undetectable   
> this method waits until a view is no longer matchable, or until the timeout has elapsed  
> a view becomes undetectable when the UiSelector of the object is unable to find a match because the element has either changed its state or is no longer displayed  
> you can use this method when attempting to wait for some long operation to complete, such as downloading a large file or connecting to a remote server   


## UiCollection (android.support.test.uiautomator.UiCollection)
> used to enumerate a container's UI elements for the purpose of counting, or   
> targeting a sub elements by a child's text or description   
> extended from UiObject

UiCollection(UiSelector selector)
> construct an instance as described by the selector

UiObject getChildByText/Description/Instance(UiSelector childPattern, String text/text/int instance)
> search for child UI element, it looks for any child matching the childPattern and   
> has a child UI element anywhere within its subhierarchy that has the text/content-description/instance  
> the returned UiObject that match selector not the child element that matched the specified properity  

int getChildCount(UiSelector childPattern)
> count child UI element instances matching the childPattern argument


## UiScrollable (android.support.test.uiautomator.UiScrollable)
> UiScrollable is a UiCollection and provides support for searching for items in scrollable layout elements   
> this class can be used with horizontally or vertically scrollable controls   

UiScrollable(UiSelector selector)
> construct an UiScrollable object

boolean scrollIntoView(UiSelector selector/UiObject obj)
> perform a scroll forward action to move through the scrollable layout element until a visible item that matches the selector/UiObject is found  

boolean scrollText/DescriptionIntoView(String text)
> pefrom a forward scroll action until the text/content-description is found

boolean scrollBackward/Forward([int steps])
> perform a scroll with the default number of steps (55) or specified steps

UiScrollable setAsHorizontal/VerticalList()
> set the direction of swipes to be horizontal/vertical when performing the scroll ations  

boolean scrollToBeginning/End(int maxSwipes[, int steps])
> scroll to the beginning or end of a scrollable layout element  
> the beginning can be at the top-most edge in the case of vertical controls, or left-most edage for horizontal controls  
> the steps control the scroll speed, so that it may be a scroll, or fling (fast slide)

boolean flingBackward/Forward()
> perform a backward/forward fling action with the default number of fling steps (5)  
> if the swipe direction is set to vertical, then the swipe will be performed from top to bottom, else left to right  

boolean flingToBeginning/End(int maxSwipes)
> perform a fling gesture to reach the beginning/end of a scrollable layout element  

int getMaxSearchSwipes() / UiScorllable setMaxSearchSwipes(int swipes)
> get/set the maximum number of scrolls allowed when performing a scroll action in search of a child element  

double getSwipeDeadZonePercentage() / UiScrollable setSwipeDeadZonePercentage(double swipeDeadZonePercentage)
> get/set the percentage of a widget's size that's considered as a no-touch zone when swiping  

UiObject getChildByText/Description(UiSelector childPattern, String text[, boolean allowScrollSearch])
> search for a child element in the present scrollable container  
> the search first looks for a child element that matches the selector, then looks for the text/content-description in its children elements  
> if fulfilled, it return the UiObject representing the element matching the selector, not the child element in its subhierarchy containing the text/content-description  
> by default, this method performs a scroll search  

UiObject getChildByInstance(UiSelector childPattern, int instance)
> search for a child element in the present scrollable container that matches the selector you provided  
> the search is performed without scrolling and only on visible elements   


## UiWatcher (android.support.test.uiautomator.UiWatcher)

void device.registerWatcher(String name, UiWatcher watcher)
> register a watcher

void device.removeWatcher(String name)
> remove a registered watcher

void device.runWatchers()
> run registered watchers, if a UiWatcher runs and its checkForCondition() call returned true, then the UiWatcher is considered triggered  

boolean device.hasAnyWatcherTriggered()
> check if any registered UiWatcher have triggered

boolean device.hasWatcherTriggered(String name)
> check if a specific registered UiWatcher has triggered  

void device.resetWatcherTriggers()
> reset a watcher that has been triggered  



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

- To run your UI Automator test, refer to https://github.com/googlesamples/android-testing, https://developer.android.com/training/testing/index.html, https://developer.android.com/training/testing/unit-testing/instrumented-unit-tests.html#run

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

Testing Support Library
> https://developer.android.com/topic/libraries/testing-support-library/index.html  
> the android testing support library provides an extensive framework for testing android apps  
> this library provides a set of apis that allow you to quickly build and run test code for your apps,  
> including JUnit4 and functional user interfac (UI) tests  
> you can run tests created using these apis from the android studio IDE or from the command line  
> Esprosso - https://developer.android.com/training/testing/espresso/index.html  
> UI Automator - is a UI testing framework suitable for corss-app functional UI testing across system and installed apps  
> Android JUnit Runner - is a new unbundled test runner for android, it features:  
> * junit4 support
> * instrumentation registry
> * test filters
> * test timeouts
> * sharding of tests
> * RunListener support to hook into the test run life-cycle
> * activity and application life-cycle monitoring
> * intent monitoring and stubbing
>
> Test samples: https://developer.android.com/training/testing/samples.html  
> Test APIs: https://developer.android.com/reference/android/support/test/packages.html  


Instrumentation and InstrumentationRegistry
> instrumentation is the base class for implementing application instrumentation code  
> when running with instrumentation turned on, this class will be instantiated for you before any of the application code,  
> allowing you to monitor all of the interaction the system has with the application.  
> an instrumentation implementation is described to the system through an AndroidManifest.xml's <instrumentation> tag.  


InstrumentationTestRunner and AndroidJUnitRunner
> InstrumentationTestRunner extends Instrumentation implements TestSuiteProvider  
> InstrumentationTestRunner was deprecated in API level 24. Use AndroidJUnitRunner instead  
> new tests should be written using the Android Testing Support Library  
> AndroidJUnitRunner extends MonitoringInstrumentation implements OrchestratedInstrumentationListener.OnConnectListener  
> it based on and replacement for InstrumentationTestRunner. supports a superset of InstrumentationTestRunner features,  
> while maintaining command/output format compatibility with that class.  
> an Instrumentation that runs JUnit3 and JUnit4 tests against an Android package (application)  
> write JUnit3 style TestCases and/or JUnit4 style Tests that perform tests againt the classes in your package,  
> make use of the InstrumentationRegistry if needed  
> in an appropriate AndroidManifest.xml, define an instrumentation with android:name set to AndroidJUnitRunner and  
> the appropriate android:targetPackage set  
> [Execution options] https://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html  
> ```
> # (1) Running all tests
> $ adb shell am instrument -w com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (2) Running all tests in a class
> $ adb shell am instrument -w -e class com.android.foo.FooTest com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (3) Running a single test
> $ adb shell am instrument -w -e class com.android.foo.FooTest#testFoo com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (4) Running all tests in multiple classes
> $ adb shell am instrument -w -e class com.android.foo.FooTest,com.android.foo.TooTest com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (5) Running all tests except those in a particular class
> $ adb shell am instrument -w -e notClass com.android.foo.FooTest com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (6) Running all but a single test
> $ adb shell am instrument -w -e notClass com.android.foo.FooTest#testFoo com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (7) Running all tests listed in a file
> $ adb shell am instrument -w -e testFile /sdcard/tmp/testFile.txt com.android.foo/com.android.test.runner.AndroidJUnitRunner
> # (8) Running all tests not listed in a file
> $ adb shell am instrument -w -e notTestFile /sdcard/tmp/notTestFile.txt
> # (9) Running all tests in a java package
> $ adb shell am instrument -w -e package com.android.foo.bar com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (10) Running all tests except a particular package
> $ adb shell am instrument -w -e notPackage com.android.foo.bar com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (11) To debug your tests, set a break point in your code and pass
> $ -e debug true
> # (12) Running a specific test size i.e. annotated with SmallTest or MediumTest or LargeTest
> $ adb shell am instrument -w -e size [small|medium|large] com.android.foo/android.support.test.runner.AndroidJUnitRunner
> # (13) To specify one or more RunListeners to observe the test run  
> $ -e listener com.foo.Listener,com.foo.Listener2  
> # (14) All arguments can also be specified in the AndroidManifest via a meta-data tag
> <instrumentation
>    android:name="android.support.test.runner.AndroidJUnitRunner"
>    android:targetPackage="com.foo.Bar">
>    <meta-data
>        android:name="listener"
>        android:value="com.foo.Listener,com.foo.Listener2" />
> </instrumentation>
> ```
> Arguments specified via shell will override manifest specified arguments.  

AndroidJUnitRunner and JUnit Rules  
> the android testing support library includes a set of JUnit rules to be used with the AndroidJUnitRunner  
> JUnit rules provide more flexibility and reduce the boilerplate code required in tests  
> TestCase objects like ActivityInstrumentationTestCase2 and ServiceTestCase are deprecated  
> in favor of ActivityTestRule or ServiceTestRule  
> ActivityTestRule provides functional testing of a single activity, the activity under test  
> will be launched before each test annotated with @Test and before any method annotated with @Before  
> it will be terminated after the test is completed and all methods annotated with @After are finished  
> the activity under test can be accessed during your test by calling ActivityTestRule.getActivity()  
> the following code snippet demonstrates how to incorporate this rule into you testing logic:  
> ```
> @RunWith(AndroidJUnit4.class)
> @LargeTest
> public class MyClassTest {
>     @Rule
>     public ActivityTestRule<MyClass> mActivityRule = new ActivityTestRule(MyClass.class);
>     @Test
>     public void myClassMethod_ReturnsTrue() { /* ... */ }
> }
> ```
> ServiceTestRule provides a simplified mechanism to start up and shut down your service before and after the duration of your test  
> it also gurantees that the service is successfully connected when starting a service or binding to one.  
> the service can be started or bound using one of the helper methods  
> it will automatically be stopped or unbound after the test completes and any methods annotated with @After are finished  
> note: this rule doesn't support IntentService. this is because the service is destroyed when IntentService.onHandleIntent(Intent)  
> finishes all outstanding commands, so there is no guarantee to establish a successful connection in a timely manner.  
> ```
> @RunWith(AndroidJUnit4.class)
> @MediumTest
> public class MyServiceTest {
> 　　　　@Rule
>     public final ServiceTestRule mServiceRule = new ServiceTestRule();
>     @Test
>     public void testWithStartedService() {
>         mServiceRule.startService(new Intent(InstrumentationRegistry.getTargetContext(), MyService.class));
>         // add your test code here
>     }
>     @Test
>     public void testWithBoundService() {
>         IBinder binder = mServiceRule.bindService(new Intent(InstrumentationRegistry.getTargetContext(), MyService.class));
>         MyService service = ((MyService.LocalBinder)binder).getService();
>         assertTrue("Service didn't return true", service.doSomethingToReturnTrue());
>     }
> }
> ```


AndroidJUnitRunner
> https://developer.android.com/training/testing/junit-runner.html  
> https://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html  
> This class is a JUnit test runner that lets you run JUnit3 or JUnit4 stype test classes on Android devices,  
> including those using the Espresso and UI Automator testing frameworks  
> the test runner handles loading your test package and the app under test to a device,  
> running your tests, and reporting test results  
> this class replaces the InstrumentationTestRunner class, which only supports JUnit 3 tests.  
> this test runner supports several common testing tasks, including the following:  
> [Writing JUnit tests], Accessing instrumentation information, Filtering tests, Sharding tests.  
> the test runner is compatible with your JUnit 3 and JUnit 4 (up to JUnit 4.10) tests.  
> however, you should avoid mixing JUnit 3 and JUnit 4 test code in the same package, as this might cause unexcepted results  
> if you are creating an instrumented JUnit 4 test class to run on a device or emulator,  
> your test class must be prefixed with the @RunWith(AndroidJUnit4.class) annotation  
> when using AndroidJUnitRunner version 1.0 or higher, you have access to a tool called Android Test Orchestrator,  
> which allow you to run each of your app's tests within its own invocation of Instrumentation.  
> Android Test Orchestrator offers the following benefits for your testing environment:  
> * No shared state - because each test runs in its own Instrumentation instance,  
> any shared state between tests doesn't accumulate on your device's CPU or memory.  
> for completeness, Android Test Orchestrator runs `pm clear` after each test.  
> * Crashes are isolated - even if one test crashes, it takes down only its own instance of Instrumentation,  
> so the other tests in your suite still run. 
> 
> Note: the deprecated test instrumentation runner, InstrumentationTestRunner,  
> isn't compatible with Android Test Orchestator. If you use InstrumentationTestRunner,  
> you might need to sue a different instrumentation runner to use on-device orchestration.  
> Enable Android Test Orchestrator from the command line:  
> ```
> # install the test orchestrator
> $ adb install -r path/to/m2repository/com/android/support/test/orchestrator/1.0.0/orchestrator-1.0.0.apk
> # install test services
> adb install -r path/to/m2repository/com/android/support/test/services/test-services/1.0.0/test-services-1.0.0.apk
> # Replace "com.example.test" with the name of the package containing your tests
> adb shell 'CLASSPATH=$(pm path android.support.test.services) app_process / \
> android.support.test.services.shellexecutor.ShellMain am instrument -w -e \
> targetInstrumentation com.example.test/android.support.test.runner.AndroidJUnitRunner \
> android.support.test.orchestrator/.AndroidTestOrchestrator'
> ```
> If you don't know your target instrumentation, you can look it up by running the following command:
> ```
> adb shell pm list instrumentation  
> ```
> The Orchestrator service APK is stored in a process that's separate from the test APK and the APK of the app under test.  
> Android Test Orchestrator collects JUnit tests at the beginning of your test suite run,  
> but it then execute each test separately, in its own instance of Instrumentation.  
> $ adb install appUnderTest  
> $ adb install testApk  
> $ adb install orchestrator  
> $ adb am instrument  
> [Accessing instrumentation information]  
> you can use the InstrumentationRegistry class to access infromation related to your test run.  
> this class includes the Instrumentation object, the target app Context object, the test app Context object,  
> and the command line arguments passed into your test.  
> this data is useful when you are writing tests using the UI Automator framework or when writing tests  
> that have dependencies on the Intrumentation or Context objects.  
> [Filtering tests]  
> in your JUnit4.x tests, you can use annotations to configure the test run  
> this feature minimizes the need to add boilerplate and conditional code in your tests  
> in addition to the standard annotations supported by JUnit 4, the test runner also supports Android-specific  
> annotations, including the following:  
> * @RequireDevice - specifies that the test should run only on physical devices, not on emulators  
> * @SdkSupress - suppresses the test from running on a lower Android API level then the given level  
> for example, to suppress tests on all API levels lower than 23 from running, use @SdkSupress(minSdkVersion=23)  
> * @SmallTest, @MediumTest, and @LargeTest - classify how long a test should take to run,  
> and consequently, how frequently you can run the test  
>
> [Sharding tests]  
> the test runner supports splitting a single test suite into multiple shards, so you can easily run tests  
> belonging to the same shard together as a group, under the same Instrumentation instance.  
> Each shard is identified by an index number. when running tests, use the `-e numShards` option to  
> specify the number of separate shards to create and the `-e shardIndex` option to specify which shard to run  
> for example, to split the test suite into 10 shards and run only the tests grouped in the second shard, use:  
> adb shell am instrument -w -e numShards 10 -e shardIndex 2   



UI Automator
> https://developer.android.com/training/testing/ui-automator.html    
> UI Automator is a UI testing framework suitable for cross-app functional UI testing across system and installed apps   
> this framework requires Android 4.3 (API level 18) or higher   
> the ui automator testing framework provides a set of apis to build UI tests that   
> perform interactions on user apps and system apps.   
> the ui automator apis allows you to perform operations such as opening the Settings menu or the app launcher in a test device   
> the ui automator testing framework is well-suited for writing black box-style automated tests,   
> where the test code does not rely on internal implementation details of the target app.   
> the ui automator apis allow you to write robust tests without needing to know about   
> the implementation details of the app that you are targeting.   
> you can use these apis to capture and manipulate ui components across multiple apps:   
> UiCollection - enumerates a container's ui elements for the purpose of counting,   
> or targeting sub-elements by their visible text or content-description property   
> UiObject - represents a UI element that is visible on the device   
> UiScrollable - provides support for searching for items in a scrollable UI container   
> UiSelector - represents a query for one or more target ui elements on a device   
> Configurator - allows you to set key parameters for running ui automator tests   
> [Testing UI for Multiple Apps] https://developer.android.com/training/testing/ui-testing/uiautomator-testing.html   
> a user interface (UI) test that involves user interactions across multiple apps lets you   
> verify that your app behaves correctly when the user flow crosses into other apps or into the system UI   
> an example of such a user flow is a messaging app that lets the user enter a text message,   
> launches the Android contact picker so that the users can select recipients to send the message to,   
> and then returns control to the original app for the user to submit the message.   
> this lesson covers how to write such UI tests using the ui aotumator testing framework provided by the android Testing Support Library.   
> the ui automator apis let you interact with visible elements on a device, regardless of which Activity is in focus.   
> your test can look up a ui component by using conveninent descriptors such as the text or content description   
> the ui automator testing framework is an instrumentation-based api and works with the AndroidJUnitRunner test runner   

UiAutomator输入事件的注入详情
```
UiDevice.click(x, y)
=> Tracer.trace(x, y)
=> getAutomatorBridge().getInteractionController().clickNoSync(x, y)
   *** UiAutomatorBridge (public abstract), InteractionController (not public) ***
=> InteractionController.touchDown(x, y)
   => mDownTime = SystemClock.uptimeMillis()
      event = MotionEvent.obtain(mDownTime, mDownTime, MotionEvent.ACTION_DOWN, x, y, 1)
      event.setSource(InputDevice.SOURCE_TOUCHSCREEN)
      injectEventSync(event)
   SystemClock.sleep(REGULAR_CLICK_LENGTH) // 100
   InteractionController.touchUp(x, y)
   => event = MontionEvent.obtain(mDownTime, curTime, MontionEvent.ACTION_UP, x, y, 1)
      event.setSource(InputDevice.SOURCE_TOUCHSCREEN)
      mDownTime = 0
      injectEventSync(event)
=> InteractionController.injectEventSync(event)
=> UiAutomatorBridge.injectInputEvent(event, true)
=> UiAutomation.injectInputEvent(event, true)
=> UiAutomationConnection.injectInputEvent(event, true)
=> InputManager.getInstance().injectInputEvent(event, INJECT_INPUT_EVENT_MODE_WAIT_FOR_FINISH)

UiObject.click()
=> Tracer.trace()
=> getInteractionController().clickAndSync(x, y, timeout)
=> InteractionController.runAndWaitForEvents(clickRunnable(x, y), // => touchDown(x, y); sleep(100); touchUp(x, y)
       new WaitForAnyEventPredicate(TYPE_WINDOW_CONTENT_CHANGED | TYPE_VIEW_SELECTED), timeout) != null
=> UiAutomatorBridge.executeCommandAndWaitForAccessibilityEvent(command, filter, timeout)
=> UiAutomation.executeAndWaitForEvent(command, filter, timeout)

UiObject.clickAndWaitForNewWindow(timeout)
=> Tracer.trace(timeout)
=> getInteractionController().clickAndWaitForNewWindow(x, y, timeout)
=> InteractionController.runAndWaitForEvents(clickRunnable(x, y),
       new WaitForAllEventPredicate(TYPE_WINDOW_CONTENT_CHANGED | TYPE_WINDOW_CONTENT_CHANGED), timeout) != null

UiObject.clickTopLeft()
=> Tracer.trace()
=> getInteractionController().clickNoSync(left + 5, top + 5)
=> InteractionController.touchDown(x, y)
   SystemClock.sleep(100)
   InteractionController.touchUp(x, y)

UiObject.longClick()
=> Tracer.trace()
=> getInteractionController().longTapNoSync(x, y)
=> InteractionController.touchDown(x, y)
   SystemClock.sleep(ms) // DEFAULT_LONG_PRESS_TIMEOUT 500, 
   InteractionController.touchUp(x, y)

UiObject.longClickTopLeft()
=> Tracer.trace()
=> getInteractionController(0.longTapNoSync(left + 5, top + 5)

UiDevice.drag(x, y, x2, y2, steps)
=> getAutomatorBridge().getInteractionController().swipe(x, y, x2, y2, steps, true)
=> InteractionController.touchDown(x, y)
   SystemClock.sleep(longPressTime) ***
   InteractionController.touchMove(toX, toY)
   SystemClock.sleep(MOTION_EVENT_INJECTION_DELAY_MILLIS) // 5ms
   InteractionController.touchMove(toX2, toY2)
   SystemClock.sleep(5)
   InteractionController.touchMove(toX3, toY3)
   SystemClock.sleep(5)
   ... ...
   SystemClock.sleep(REGULAR_CLICK_LENGTH) ***
   InteractionController.touchUp(x2, y2)
=> InteractionController.touchMove(xy, y)
   => event = MotionEvent.obtain(mDownTime, curTime, MotionEvent.ACTION_MOVE, x, y, 1)
      event.setSource(InputDevice.SOURCE_TOUCHSCREEN)
      injectEventSync(event)

UiDevice.swipe(x, y, x2, y2, steps)
=> getAutomatorBridge().getInteractionController().swipe(x, y, x2, y2, steps)
=> InteractionController.swipe(x, y, x2, y2, steps, /* drag */ false)
=> InteractionController.touchDown(x, y)
   InteractionController.touchMove(toX, toY)
   SystemClock.sleep(MOTION_EVENT_INJECTION_DELAY_MILLIS) // 5ms
   InteractionController.touchMove(toX2, toY2)
   SystemClock.sleep(5)
   InteractionController.touchMove(toX3, toY3)
   SystemClock.sleep(5)
   ... ...
   InteractionController.touchUp(x2, y2)

UiObject.dragTo(x, y, steps)
=> getInteractionController().swipe(x, y, x2, y2, steps, true)

UiObject.swipeUp(steps)
=> getInteractionController().swipe(centerX, bottom - 5, centerX, top + 5, steps)

UiObject.pintchIn(percent, steps)
=> performTwoPointerGesture(startPoint1, startPoint2, endPoint1, endPoint2, steps)
=> performMultiPointerGesture(points1, points2)

UiObject.performMultiPointerGesture(touches)
=> getInteractionController().performMultiPointerGesture(touches)
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

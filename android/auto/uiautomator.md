# UiAutomator
- https://developer.android.com/reference/android/support/test/uiautomator/package-summary.html
- https://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html


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

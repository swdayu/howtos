# UiAutomator
- https://developer.android.com/reference/android/support/test/uiautomator/package-summary.html
- https://developer.android.com/reference/android/support/test/runner/AndroidJUnitRunner.html

## UiDevice (android.support.test.uiautomator.UiDevice)
> it provides access to state information about the device, and also    
> can be used to simulate user actions on the device, such as pressing p-pad or Home and Menu buttons   

UiDevice.getInstance(Instrumentation instrumentation)
> retrieve a singleton instance of UiDevice

UiObject findObject(UiSelector selector)
> return a UiObject which represents a view that matches the selector

boolean takeScreenshot(File storePath[, float scale, int quality])
> take a screenshot of current window and store it as PNG with scale (1.0f default) and quality (90% default)

void wakeUp()
> simulate pressing the power button if the screen is OFF else it does nothing

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

String getLauncherPackageName()
> retrieve default launcher package name  
> Launcher - the default application that running after press HOME button

R wait(SearchCondition<R> condition, long timeout)
> wait for given condition to be met, timeout is the maximum amount of time to wait in ms  
> the return value R is the final result returned by the condition

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

## Util (android.support.test.uiautomator.Until)
> provide factory methods for constructing common conditions

SearchCondition<Boolean> Util.hasObject(BySelector selector)
> return a SearchCondition that is satisfied when at least one element matching the selector can be found

SearchCondition<Boolean> Util.gone(BySelector selector)
> return a SearchCondition that is satisfied when no elements matching the seletor can be found

EventCondition<Boolean> Util.newWindow()
> return a condition that depends on a new window having appeared

EventCondition<Boolean> Util.scrollFinished(Direction direction)
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

## UiObject2 (android.support.test.uiautomator.UiObject2)
> represent a UI element, it is bound to a particular view instance and can become stale if the underlying view object is destroyed    
> as a result, it may be necessary to call findObject(BySelector) to obtain a new UiObject2 instance if the UI changes significantly  

void setText(String text)
> set the text content if this object is an editable field

String getText()
> return the text value for this object

## UiSelector (android.support.test.uiautomator.UiSelector)
> specify the elements in the layout hierachy for tests   
> filtered by properties such as text value, content-description, class name, state info, location  

UiSelector()
> construct the UiSelector object

UiSelector text/textContains/textMatches/textStartsWith(String text)
> select the element match the text

UiSelector checkable/checked/clickable/enabled/focusable/focused/longClickable/scrollable/selected(boolean value)
> select the element in the specified state

## UiObject (android.support.test.uiautomator.UiObject)
> a UiObject is a representation of a view, it is not in any way directly bound to a view as an object reference    
> it contains information to help it locate a matching view at runtime based on the UiSelector properties specified in its constructor    
> once you create an instance of a UiObject, it can be reused for different views that match the selector criteria   

UiObject UiDevice.findObject(UiSelector selector)  
> create a UiObject that matching the selector

## UiCollection (android.support.test.uiautomator.UiCollection)
> used to enumerate a container's UI elements for the purpose of counting, or   
> targeting a sub elements by a child's text or description   
> extended from UiObject

UiCollection(UiSelector selector)
> construct an instance as described by the selector

UiObject getChildByText/Description/Instance(UiSelector childPattern, String text/text/int instance)
> search for child UI element

int getChildCount(UiSelector childPattern)
> count child UI element instances matching the childPattern argument

## UiScrollable (android.support.test.uiautomator.UiScrollable)
> UiScrollable is a UiCollection and provides support for searching for items in scrollable layout elements   
> this class can be used with horizontally or vertically scrollable controls   

UiScrollable(UiSelector selector)
> construct an UiScrollable object

boolean scrollBackward/Forward([int steps])
> perform a scroll with the default number of steps (55) or specified steps

boolean scrollToBeginning/End(int maxSwipes[, int steps])
> scroll to the beginning or end of a scrollable layout element  

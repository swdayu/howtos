# UiAutomator
- https://developer.android.com/reference/android/support/test/uiautomator/package-summary.html

## UiDevice (android.support.test.uiautomator.UiDevice)
> provide access to state information about the device  
> can be also for simulating user actions on the device, such as pressing the d-pad or pressing the Home and Menu buttons  

UiDevice.getInstance(Instrumentation instrumentation)
> retrieve a singleton instance of UiDevice

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
> Launcher - the default running application after press HOME button

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

SearchCondition<UiObject2> Util.findObject(BySelector selector)
> return a SearchCondition that is satisfied when at least one element matching the selector can be found  
> the condition will return the first matching element

SearchCondition<List<UiObject2>> Util.findObjects(BySelector selector)
> return a SearchCondition that is satisfied when at least one element matching the selector can be found  
> the condition will return all matching elements

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

## UiObject (android.support.test.uiautomator.UiObject)
> a UiObject is a representation of a view  
> it contains information to help it locate a matching view at runtime based on the UiSelector properties  
> once you create an instance of a UiObject, it can be reused for different views that match the selector criteria   

UiObject UiDevice.findObject(UiSelector selector)  
List<UiObject> UiDevice.findObjects(UiSelector selector)
> create a UiObject or a list of UiObject matching the selector

## UiScrollable (android.support.test.uiautomator.UiScrollable)
## UiCollection (android.support.test.uiautomator.UiCollection)


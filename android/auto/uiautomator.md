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



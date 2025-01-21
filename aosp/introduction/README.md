
# Introduction to Android

Android provides a rich application framework that allows you to build innovative apps 
and games for mobile devices in a Java language environment.

If you're new to Android development, it's important that you understand 
the following fundamental concepts about the Android app framework:

**Apps provide multiple entry points**

Android apps are built as a combination of distinct components that can be invoked individually. 
For instance, an individual *activity* provides a single screen for a user interface, 
and a *service* independently performs work in the background.

From one component you can start another component using an *intent*. 
You can even start a component in a different app, such as an activity in a maps app to show an address. 
This model provides multiple entry points for a single app 
and allows any app to behave as a user's "default" for an action that other apps may invoke.

**Apps adapt to different devices**

Android provides an adaptive app framework that allows you to provide unique resources 
for different device configurations. 
For example, you can create different XML layout files for different screen sizes 
and the system determines which layout to apply based on the current device's screen size.

You can query the availability of device features at runtime 
if any app features require specific hardware such as a camera. 
If necessary, you can also declare features your app requires 
so app markets such as Google Play Store do not allow installation on devices that do not support that feature.


# Application Fundamentals

Android apps are written in the Java programming language. 
The Android SDK tools compile your code - along with any data and resource files - into an APK: 
an *Android package*, which is an archive file with an `.apk` suffix. 
One APK file contains all the contents of an Android app and is the file 
that Android-powered devices use to install the app.

Once installed on a device, each Android app lives in its own security sandbox:
- The Android operating system is a multi-user Linux system in which each app is a different user.
- By default, the system assigns each app a unique Linux user ID 
  (the ID is used only by the system and is unknown to the app). 
  The system sets permissions for all the files in an app 
  so that only the user ID assigned to that app can access them.
- Each process has its own virtual machine (VM), so an app's code runs in isolation from other apps.
- By default, every app runs in its own Linux process. 
  Android starts the process when any of the app's components need to be executed, 
  then shuts down the process when it's no longer needed or when the system must recover memory for other apps.

In this way, the Android system implements the principle of least privilege. 
That is, each app, by default, has access only to the components that it requires to do its work and no more. 
This creates a very secure environment in which an app cannot access parts of the system 
for which it is not given permission.

However, there are ways for an app to share data with other apps and for an app to access system services:
- It's possible to arrange for two apps to share the same Linux user ID, 
  in which case they are able to access each other's files. 
  To conserve system resources, apps with the same user ID can also arrange to run in the same Linux process 
  and share the same VM (the apps must also be signed with the same certificate).
- An app can request permission to access device data such as the user's contacts, SMS messages, 
  the mountable storage (SD card), camera, Bluetooth, and more. 
  All app permissions must be granted by the user at install time.

That covers the basics regarding how an Android app exists within the system. 
The rest of this document introduces you to:
- The core framework components that define your app.
- The manifest file in which you declare components and required device features for your app.
- Resources that are separate from the app code and allow your app to gracefully optimize its behavior 
  for a variety of device configurations.
  
## App Components

App components are the essential building blocks of an Android app. 
Each component is a different point through which the system can enter your app. 
Not all components are actual entry points for the user and some depend on each other, 
but each one exists as its own entity and plays a specific role - 
each one is a unique building block that helps define your app's overall behavior.

There are four different types of app components. 
Each type serves a distinct purpose and has a distinct lifecycle 
that defines how the component is created and destroyed.

Here are the four types of app components:
- **Activities**

    An activity represents a single screen with a user interface. 
    For example, an email app might have one activity that shows a list of new emails, 
    another activity to compose an email, and another activity for reading emails. 
    Although the activities work together to form a cohesive user experience in the email app, 
    each one is independent of the others. 
    As such, a different app can start any one of these activities (if the email app allows it). 
    For example, a camera app can start the activity in the email app that composes new mail, 
    in order for the user to share a picture.

    An activity is implemented as a subclass of `Activity` and 
    you can learn more about it in the `Activities` developer guide.

- **Services**

    A service is a component that runs in the background to perform long-running operations 
    or to perform work for remote processes. A service does not provide a user interface. 
    For example, a service might play music in the background while the user is in a different app, 
    or it might fetch data over the network without blocking user interaction with an activity. 
    Another component, such as an activity, can start the service and let it run or bind to it 
    in order to interact with it.

    A service is implemented as a subclass of `Service` and 
    you can learn more about it in the `Services` developer guide.

- **Content providers**

    A content provider manages a shared set of app data. 
    You can store the data in the file system, an SQLite database, on the web, 
    or any other persistent storage location your app can access. 
    Through the content provider, other apps can query or even modify the data (if the content provider allows it). 
    For example, the Android system provides a content provider that manages the user's contact information. 
    As such, any app with the proper permissions can query part of the content provider 
    (such as `ContactsContract.Data`) to read and write information about a particular person.

    Content providers are also useful for reading and writing data that is private to your app and not shared. 
    For example, the `Note Pad` sample app uses a content provider to save notes.

    A content provider is implemented as a subclass of `ContentProvider` and must implement a standard set of APIs 
    that enable other apps to perform transactions. 
    For more information, see the `Content Providers` developer guide.
    
- **Broadcast receivers**

    A broadcast receiver is a component that responds to system-wide broadcast announcements. 
    Many broadcasts originate from the system - for example, a broadcast announcing that the screen has turned off, 
    the battery is low, or a picture was captured. 
    Apps can also initiate broadcasts - for example, 
    to let other apps know that some data has been downloaded to the device and is available for them to use. 
    Although broadcast receivers don't display a user interface, 
    they may create a status bar notification to alert the user when a broadcast event occurs. 
    More commonly, though, a broadcast receiver is just a "gateway" to other components 
    and is intended to do a very minimal amount of work. 
    For instance, it might initiate a service to perform some work based on the event.

    A broadcast receiver is implemented as a subclass of `BroadcastReceiver` 
    and each broadcast is delivered as an `Intent` object. 
    For more information, see the `BroadcastReceiver` class.

A unique aspect of the Android system design is that any app can start another app’s component. 
For example, if you want the user to capture a photo with the device camera, 
there's probably another app that does that and your app can use it, 
instead of developing an activity to capture a photo yourself. 
You don't need to incorporate or even link to the code from the camera app. 
Instead, you can simply start the activity in the camera app that captures a photo. 
When complete, the photo is even returned to your app so you can use it. 
To the user, it seems as if the camera is actually a part of your app.

When the system starts a component, it starts the process for that app (if it's not already running) 
and instantiates the classes needed for the component. 
For example, if your app starts the activity in the camera app that captures a photo, 
that activity runs in the process that belongs to the camera app, not in your app's process. 
Therefore, unlike apps on most other systems, Android apps don't have a single entry point 
(there's no main() function, for example).

Because the system runs each app in a separate process with file permissions that restrict access to other apps, 
your app cannot directly activate a component from another app. The Android system, however, can. 
So, to activate a component in another app, you must deliver a message to the system 
that specifies your intent to start a particular component. 
The system then activates the component for you.

## Activating Components

Three of the four component types - activities, services, and broadcast receivers - are activated 
by an asynchronous message called an *intent*. 
Intents bind individual components to each other at runtime 
(you can think of them as the messengers that request an action from other components), 
whether the component belongs to your app or another.

An intent is created with an `Intent` object, which defines a message to activate either a specific component 
or a specific type of component - an intent can be either explicit or implicit, respectively.

For activities and services, an intent defines the action to perform (for example, to "view" or "send" something) 
and may specify the URI of the data to act on (among other things that the component being started 
might need to know). 
For example, an intent might convey a request for an activity to show an image or to open a web page. 
In some cases, you can start an activity to receive a result, in which case, 
the activity also returns the result in an Intent (for example, you can issue an intent to let the user 
pick a personal contact and have it returned to you - the return intent includes a URI 
pointing to the chosen contact).

For broadcast receivers, the intent simply defines the announcement being broadcast 
(for example, a broadcast to indicate the device battery is low includes only a known action string 
that indicates "battery is low").

The other component type, content provider, is not activated by intents. 
Rather, it is activated when targeted by a request from a `ContentResolver`. 
The content resolver handles all direct transactions with the content provider 
so that the component that's performing transactions with the provider 
doesn't need to and instead calls methods on the `ContentResolver` object. 
This leaves a layer of abstraction between the content provider 
and the component requesting information (for security).

There are separate methods for activating each type of component:
- You can start an activity (or give it something new to do) by passing an `Intent` to `startActivity()` 
  or `startActivityForResult()` (when you want the activity to return a result).
- You can start a service (or give new instructions to an ongoing service) by passing 
  an `Intent` to `startService()`. Or you can bind to the service by passing an `Intent` to `bindService()`.
- You can initiate a broadcast by passing an `Intent` to methods like `sendBroadcast()`, 
  `sendOrderedBroadcast()`, or `sendStickyBroadcast()`.
- You can perform a query to a content provider by calling `query()` on a `ContentResolver`.

For more information about using intents, see the `Intents and Intent Filters` document. 
More information about activating specific components is also provided in the following documents: 
`Activities`, `Services`, `BroadcastReceiver` and `Content Providers`.

## The Manifest File

Before the Android system can start an app component, 
the system must know that the component exists by 
reading the app's `AndroidManifest.xml` file (the "manifest" file). 
Your app must declare all its components in this file, which must be at the root of the app project directory.

The manifest does a number of things in addition to declaring the app's components, such as:
- Identify any user permissions the app requires, such as Internet access or read-access to the user's contacts.
- Declare the minimum `API Level` required by the app, based on which APIs the app uses.
- Declare hardware and software features used or required by the app, such as a camera, bluetooth services, 
  or a multitouch screen.
- API libraries the app needs to be linked against (other than the Android framework APIs), 
  such as the Google Maps library.
- And more

### Declaring components

The primary task of the manifest is to inform the system about the app's components. 
For example, a manifest file can declare an activity as follows:
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest ... >
  <application android:icon="@drawable/app_icon.png" ... >
    <activity android:name="com.example.project.ExampleActivity"
              android:label="@string/example_label" ... >
    </activity>
    ...
  </application>
</manifest>
```

In the `<application>` element, the `android:icon` attribute points to resources for an icon 
that identifies the app.

In the `<activity>` element, the `android:name` attribute specifies the fully qualified class name 
of the `Activity` subclass and the `android:label` attributes specifies a string 
to use as the user-visible label for the activity.

You must declare all app components this way:
- `<activity>` elements for activities
- `<service>` elements for services
- `<receiver>` elements for broadcast receivers
- `<provider>` elements for content providers

Activities, services, and content providers that you include in your source 
but do not declare in the manifest are not visible to the system and, consequently, can never run. 
However, broadcast receivers can be either declared in the manifest or created dynamically in code 
(as `BroadcastReceiver` objects) and registered with the system by calling `registerReceiver()`.

For more about how to structure the manifest file for your app, see `The AndroidManifest.xml File` documentation. 

### Declaring component capabilities

As discussed above, in `Activating Components`, you can use an `Intent` to start activities, 
services, and broadcast receivers. 
You can do so by explicitly naming the target component (using the component class name) in the intent. 
However, the real power of intents lies in the concept of *implicit intents*. 
An implicit intent simply describes the type of action to perform 
(and, optionally, the data upon which you’d like to perform the action) 
and allows the system to find a component on the device that can perform the action and start it. 
If there are multiple components that can perform the action described by the intent, 
then the user selects which one to use.

The way the system identifies the components that can respond to an intent is by comparing the intent received 
to the intent filters provided in the manifest file of other apps on the device.

When you declare an activity in your app's manifest, you can optionally include intent filters 
that declare the capabilities of the activity so it can respond to intents from other apps. 
You can declare an intent filter for your component by adding an `<intent-filter>` element 
as a child of the component's declaration element.

For example, if you've built an email app with an activity for composing a new email, 
you can declare an intent filter to respond to "send" intents (in order to send a new email) like this:
```xml
<manifest ... >
  ...
  <application ... >
    <activity android:name="com.example.project.ComposeEmailActivity">
      <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <data android:type="*/*" />
        <category android:name="android.intent.category.DEFAULT" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

Then, if another app creates an intent with the `ACTION_SEND` action and pass it to `startActivity()`, 
the system may start your activity so the user can draft and send an email.

For more about creating intent filters, see the `Intents and Intent Filters` document. 

### Declaring app requirements

There are a variety of devices powered by Android and not all of them provide the same features and capabilities. 
In order to prevent your app from being installed on devices that lack features needed by your app, 
it's important that you clearly define a profile for the types of devices your app supports 
by declaring device and software requirements in your manifest file. 
Most of these declarations are informational only and the system does not read them, 
but external services such as Google Play do read them in order to provide filtering 
for users when they search for apps from their device.

For example, if your app requires a camera and uses APIs introduced in Android 2.1 (`API Level` 7), 
you should declare these as requirements in your manifest file like this:
```xml
<manifest ... >
  <uses-feature android:name="android.hardware.camera.any" android:required="true" />
  <uses-sdk android:minSdkVersion="7" android:targetSdkVersion="19" />
  ...
</manifest>
```

Now, devices that do not have a camera and have an Android version lower than 2.1 
cannot install your app from Google Play.

However, you can also declare that your app uses the camera, but does not require it. 
In that case, your app must set the `required` attribute to `"false"` 
and check at runtime whether the device has a camera and disable any camera features as appropriate.

More information about how you can manage your app's compatibility with different devices 
is provided in the `Device Compatibility` document.

## App Resources

An Android app is composed of more than just code -it requires resources that are separate from the source code, 
such as images, audio files, and anything relating to the visual presentation of the app. 
For example, you should define animations, menus, styles, colors, 
and the layout of activity user interfaces with XML files. 
Using app resources makes it easy to update various characteristics of your app 
without modifying code and - by providing sets of alternative resources - enables you to optimize your app 
for a variety of device configurations (such as different languages and screen sizes).

For every resource that you include in your Android project, the SDK build tools define a unique integer ID, 
which you can use to reference the resource from your app code or from other resources defined in XML. 
For example, if your app contains an image file named `logo.png` (saved in the `res/drawable/` directory), 
the SDK tools generate a resource ID named `R.drawable.logo`, 
which you can use to reference the image and insert it in your user interface.

One of the most important aspects of providing resources separate from your source code 
is the ability for you to provide alternative resources for different device configurations. 
For example, by defining UI strings in XML, you can translate the strings into other languages 
and save those strings in separate files. 
Then, based on a language *qualifier* that you append to the resource directory's name 
(such as `res/values-fr/` for French string values) and the user's language setting, 
the Android system applies the appropriate language strings to your UI.

Android supports many different *qualifiers* for your alternative resources. 
The qualifier is a short string that you include in the name of your resource directories 
in order to define the device configuration for which those resources should be used. 
As another example, you should often create different layouts for your activities, 
depending on the device's screen orientation and size. 
For example, when the device screen is in portrait orientation (tall), 
you might want a layout with buttons to be vertical, but when the screen is in landscape orientation (wide), 
the buttons should be aligned horizontally. 
To change the layout depending on the orientation, 
you can define two different layouts and apply the appropriate qualifier to each layout's directory name. 
Then, the system automatically applies the appropriate layout depending on the current device orientation.

For more about the different kinds of resources you can include in your application 
and how to create alternative resources for different device configurations, read `Providing Resources`.

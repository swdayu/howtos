
# Activities

An `Activity` is an application component that provides a screen 
with which users can interact in order to do something, such as dial the phone, 
take a photo, send an email, or view a map. 
Each activity is given a window in which to draw its user interface. 
The window typically fills the screen, but may be smaller than the screen and float on top of other windows.

Activity是提供屏幕显示与用户发生交互动作的应用组件，如拨打电话、拍照、发送邮件或查看地图。
每个Activity都会在指定窗口绘制用户界面。窗口通常是全屏的，但也可能比屏幕小悬浮在其它窗口之上。

An application usually consists of multiple activities that are loosely bound to each other. 
Typically, one activity in an application is specified as the "main" activity, 
which is presented to the user when launching the application for the first time. 
Each activity can then start another activity in order to perform different actions. 
Each time a new activity starts, the previous activity is stopped, 
but the system preserves the activity in a stack (the "back stack"). 
When a new activity starts, it is pushed onto the back stack and takes user focus. 
The back stack abides to the basic "last in, first out" stack mechanism, 
so, when the user is done with the current activity and presses the Back button, 
it is popped from the stack (and destroyed) and the previous activity resumes. 
(The back stack is discussed more in the `Tasks and Back Stack` document.)

应用通常包含多个Activity。有一个称为Main Activity，负责在启动应用时呈现给用户。
之后，每个Activity都可以启动其他Activity完成不同的工作。
每当新Activity启动时，前一个Activity就会停止，但会继续保存在后备栈中。
新Activity创建后会压入到后备栈的栈顶，并获取用户焦点。
后备栈遵循后进先出策略，因此当用户完成当前Activity返回时，
栈顶Activity会出栈（并销毁），而前一个Activity会重新呈现。
（对后备栈更深入的讨论参见`Tasks and Back Stack`部分）。

When an activity is stopped because a new activity starts, 
it is notified of this change in state through the activity's lifecycle callback methods. 
There are several callback methods that an activity might receive, 
due to a change in its state - whether the system is creating it, stopping it, resuming it, 
or destroying it - and each callback provides you the opportunity 
to perform specific work that's appropriate to that state change. 
For instance, when stopped, your activity should release any large objects, 
such as network or database connections. 
When the activity resumes, you can reacquire the necessary resources and resume actions that were interrupted.
These state transitions are all part of the activity lifecycle.

当一个Activity因启动新Activity而停止，这个状态变化会通过回调函数进行通知。
由于状态的改变，Activity会接收到很多函数回调，包括创建、停止、重新开启或销毁，
回调函数提供了根据不同状态做不同事情的机会。
例如当停止时，应释放掉Activity的大对象，如网络或数据连接。
当Activity重新启动时，需要重新获取需要的资源并继续被打断的工作。
这些状态的转换存在于Activity的整个生命周期中。

The rest of this document discusses the basics of how to build and use an activity, 
including a complete discussion of how the activity lifecycle works, 
so you can properly manage the transition between various activity states.

剩余部分介绍如何创建和使用Activity，包括Activity的生命周期怎样工作，
因而你将懂得如果管理各种Activity状态之间的转换。

## Creating an Activity

To create an activity, you must create a subclass of Activity (or an existing subclass of it). 
In your subclass, you need to implement callback methods that the system calls 
when the activity transitions between various states of its lifecycle, 
such as when the activity is being created, stopped, resumed, or destroyed. 

The two most important callback methods are:
- `onCreate()`: You must implement this method. The system calls this when creating your activity. 
    Within your implementation, you should initialize the essential components of your activity. 
    Most importantly, this is where you must call `setContentView()` to 
    define the layout for the activity's user interface.

    必须实现`onCreate()`回调函数，当创建Activity时系统会调用这个函数。
    实现这个函数时，应该初始化Activity。更重要的，必须调用`setContentView()`定义Activity用户界面的布局。

- `onPause()`: The system calls this method as the first indication that the user 
    is leaving your activity (though it does not always mean the activity is being destroyed). 
    This is usually where you should commit any changes that should be persisted 
    beyond the current user session (because the user might not come back).

    `onPause()`回调函数是用户离开Activity时系统给的第一个通知。
    **通常在这个函数中保存修改的数据，因为用户可能不再回来**。

There are several other lifecycle callback methods that you should use 
in order to provide a fluid user experience between activities 
and handle unexpected interuptions that cause your activity to be stopped and even destroyed. 
All of the lifecycle callback methods are discussed later, in the section about `Managing the Activity Lifecycle`.

### Implementing a user interface

The user interface for an activity is provided by a hierarchy of views - objects derived from the `View` class. 
Each view controls a particular rectangular space within the activity's window 
and can respond to user interaction.
For example, a view might be a button that initiates an action when the user touches it.

Activity的用户界面由`View`提供。每个View控制了Activity窗口中的一部分矩形区域，并响应用户输入。
如View可能是一个按钮，当用户点击时就会产生一个动作。

Android provides a number of ready-made views that you can use to design and organize your layout. 
"Widgets" are views that provide a visual (and interactive) elements for the screen, 
such as a button, text field, checkbox, or just an image. 
"Layouts" are views derived from `ViewGroup` that provide a unique layout model for its child views, 
such as a linear layout, a grid layout, or relative layout. 
You can also subclass the `View` and `ViewGroup` classes (or existing subclasses) 
to create your own widgets and layouts and apply them to your activity layout.

**控件**提供屏幕显示（和交互）元素，如按钮、文本框等等。
**布局**是从`ViewGroup`继承的View，用于为所有子View提供唯一布局模型，例如线性、网格或相对布局。

The most common way to define a layout using views is with an XML layout file saved in your application resources.
This way, you can maintain the design of your user interface separately from the source code 
that defines the activity's behavior. 
You can set the layout as the UI for your activity with `setContentView()`, 
passing the resource ID for the layout. 
However, you can also create new Views in your activity code 
and build a view hierarchy by inserting new `Views` into a `ViewGroup`, 
then use that layout by passing the root `ViewGroup` to `setContentView()`.

最常用的方法是使用XML文件定义的View的布局，并使用`setContentView()`将布局设置到你的Activity。
也可以直接在代码中创建View并将View添加到ViewGroup，然后通过Root ViewGroup调用`setContentView()`使用这个布局。

For information about creating a user interface, see the `User Interface` documentation.

### Declaring the activity in the manifest

You must declare your activity in the manifest file in order for it to be accessible to the system. 
To declare your activity, open your manifest file and add an `<activity>` element 
as a child of the `<application>` element. 

为了让系统访问到，必须在Manifest文件中声明你的Activity。
声明Activity要在Manifest文件中`<application>`元素下添加一个子元素`<activity>`。

For example:
```xml
<manifest ... >
  <application ... >
    <activity android:name=".ExampleActivity" />
    ...
  </application ... >
  ...
</manifest >
```

There are several other attributes that you can include in this element, 
to define properties such as the label for the activity, an icon for the activity, 
or a theme to style the activity's UI. 
The `android:name` attribute is the only required attribute - it specifies the class name of the activity. 
Once you publish your application, you should not change this name, because if you do, 
you might break some functionality, such as application shortcuts 
(read the blog post, `Things That Cannot Change`).

有很多其他的属性可以添加，但是`android:name`是必须添加的元素，它指定这个Activity的类名。

See the `<activity>` element reference for more information about declaring your activity in the manifest.

### Using intent filters

An `<activity>` element can also specify various intent filters - using the `<intent-filter>` element - 
in order to declare how other application components may activate it.

When you create a new application using the Android SDK tools, 
the stub activity that's created for you automatically includes an intent filter 
that declares the activity responds to the "main" action and should be placed in the "launcher" category. 
The intent filter looks like this:
```xml
<activity android:name=".ExampleActivity" android:icon="@drawable/app_icon">
  <intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
  </intent-filter>
</activity>
```

The `<action>` element specifies that this is the "main" entry point to the application. 
The `<category>` element specifies that this activity 
should be listed in the system's application launcher (to allow users to launch this activity).

If you intend for your application to be self-contained and not allow other applications 
to activate its activities, then you don't need any other intent filters. 
Only one activity should have the "main" action and "launcher" category, as in the previous example. 
Activities that you don't want to make available to other applications should have no intent filters 
and you can start them yourself using explicit intents (as discussed in the following section).

However, if you want your activity to respond to implicit intents that are delivered from other applications 
(and your own), then you must define additional intent filters for your activity. 
For each type of intent to which you want to respond, you must include an `<intent-filter>` that 
includes an `<action>` element and, optionally, a `<category>` element and/or a `<data>` element. 
These elements specify the type of intent to which your activity can respond.

For more information about how your activities can respond to intents, 
see the `Intents and Intent Filters` document.


## Starting an Activity

You can start another activity by calling `startActivity()`, 
passing it an `Intent` that describes the activity you want to start. 
The intent specifies either the exact activity you want to start or 
describes the type of action you want to perform (and the system selects the appropriate activity for you, 
which can even be from a different application). 
An intent can also carry small amounts of data to be used by the activity that is started.

When working within your own application, you'll often need to simply launch a known activity. 
You can do so by creating an intent that explicitly defines the activity you want to start, using the class name. 
For example, here's how one activity starts another activity named `SignInActivity`:
```java
Intent intent = new Intent(this, SignInActivity.class);
startActivity(intent);
```

However, your application might also want to perform some action, such as send an email, 
text message, or status update, using data from your activity. 
In this case, your application might not have its own activities to perform such actions, 
so you can instead leverage the activities provided by other applications on the device, 
which can perform the actions for you. 
This is where intents are really valuable - you can create an intent that describes an action you want 
to perform and the system launches the appropriate activity from another application. 
If there are multiple activities that can handle the intent, then the user can select which one to use. 
For example, if you want to allow the user to send an email message, you can create the following intent:
```java
Intent intent = new Intent(Intent.ACTION_SEND);
intent.putExtra(Intent.EXTRA_EMAIL, recipientArray);
startActivity(intent);
```

The `EXTRA_EMAIL` extra added to the intent is a string array of email addresses 
to which the email should be sent. 
When an email application responds to this intent, it reads the string array provided in the extra 
and places them in the "to" field of the email composition form. 
In this situation, the email application's activity starts and when the user is done, your activity resumes.

### Starting an activity for a result

Sometimes, you might want to receive a result from the activity that you start. 
In that case, start the activity by calling `startActivityForResult()` (instead of `startActivity()`). 
To then receive the result from the subsequent activity, implement the `onActivityResult()` callback method. 
When the subsequent activity is done, it returns a result in an `Intent` to your `onActivityResult()` method.

如果要从其他的Activity接收结果，需要调用`startActivityForResult()`并实现`onActivityResult()`接收结果。

For example, perhaps you want the user to pick one of their contacts, 
so your activity can do something with the information in that contact. 
Here's how you can create such an intent and handle the result:
```java
private void pickContact() {
  // Create an intent to "pick" a contact, as defined by the content provider URI
  Intent intent = new Intent(Intent.ACTION_PICK, Contacts.CONTENT_URI);
  startActivityForResult(intent, PICK_CONTACT_REQUEST);
}

@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
  // If the request went well (OK) and the request was PICK_CONTACT_REQUEST
  if (resultCode == Activity.RESULT_OK && requestCode == PICK_CONTACT_REQUEST) {
    // Perform a query to the contact's content provider for the contact's name
    Cursor cursor = getContentResolver().query(data.getData(),
    new String[] {Contacts.DISPLAY_NAME}, null, null, null);
    if (cursor.moveToFirst()) { // True if the cursor is not empty
      int columnIndex = cursor.getColumnIndex(Contacts.DISPLAY_NAME);
      String name = cursor.getString(columnIndex);
      // Do something with the selected contact's name...
    }
  }
}
```

This example shows the basic logic you should use in your `onActivityResult()` method 
in order to handle an activity result. 
The first condition checks whether the request was successful - if it was, then the `resultCode` 
will be `RESULT_OK` - and whether the request to which this result is responding is known - 
in this case, the requestCode matches the second parameter sent with `startActivityForResult()`. 
From there, the code handles the activity result 
by querying the data returned in an `Intent` (the data parameter).

What happens is, a `ContentResolver` performs a query against a content provider, 
which returns a `Cursor` that allows the queried data to be read. 
For more information, see the `Content Providers` document.

For more information about using intents, see the `Intents and Intent Filters` document.

## Shutting Down an Activity

You can shut down an activity by calling its `finish()` method. 
You can also shut down a separate activity that you previously started by calling `finishActivity()`.

关闭Activity可以调用它的`finish()`函数，也可以调用`finishActivity()`关闭一个特定的Activity。

> **Note:** In most cases, you should not explicitly finish an activity using these methods. 
As discussed in the following section about the activity lifecycle, 
the Android system manages the life of an activity for you, so you do not need to finish your own activities.
Calling these methods could adversely affect the expected user experience and 
should only be used when you absolutely do not want the user to return to this instance of the activity.

> 注意的是，大多数情况都不需要自己关闭一个Activity，因为系统会管理Activity的生命周期。
调用这些函数会影响用户体验，真正不想让用户再次回到你的Activity时才使用。

## Managing the Activity Lifecycle

Managing the lifecycle of your activities by implementing callback methods 
is crucial to developing a strong and flexible application. 
The lifecycle of an activity is directly affected by its association with other activities, 
its task and back stack.

通过实现回调函数管理Activity的生命周期对于开发出强壮和灵活的应用是非常重要的。
Activity的生命周期直接对与它关联的其他Activity、以及它的Task和后备栈产生影响。

An activity can exist in essentially three states:

Activity存在3个核心状态：

- **Resumed:** The activity is in the foreground of the screen and has user focus. 
    (This state is also sometimes referred to as "running".)

    这个Activity运行在前台并获取了用户焦点（也成为是”运行状态）。

- **Paused:** Another activity is in the foreground and has focus, but this one is still visible. 
    That is, another activity is visible on top of this one and that activity is partially transparent 
    or doesn't cover the entire screen. 
    A paused activity is completely alive (the Activity object is retained in memory, 
    it maintains all state and member information, and remains attached to the window manager), 
    but can be killed by the system in extremely low memory situations.

    其他Activity运行到了前台并获取了用户焦点。暂停的Activity是完全活动的（Activity对象保持在内存中，
    它维持了所以的状态并关联在窗口管理器中），但是当内存不够时，系统可能会杀死暂停的Activity。

- **Stopped:** The activity is completely obscured by another activity (the activity is now in the "background").
    A stopped activity is also still alive (the Activity object is retained in memory, 
    it maintains all state and member information, but is not attached to the window manager). 
    However, it is no longer visible to the user and 
    it can be killed by the system when memory is needed elsewhere.

    停止的Activity完全被其他Activity遮蔽（在后台运行）。
    停止的Activity还是活动的（只是没有关联在窗口管理器中）。
    然后因为它不再对用户可见，因此在内存不足是可能被系统杀死。

If an activity is paused or stopped, the system can drop it from memory either by asking it to finish 
(calling its `finish()` method), or simply killing its process. 
When the activity is opened again (after being finished or killed), it must be created all over.

当Activity暂停或停止时，系统可能调用`finish()`或杀掉进程将它从内存中移除。

### Implementing the lifecycle callbacks

When an activity transitions into and out of the different states described above, 
it is notified through various callback methods. 
All of the callback methods are hooks that you can override to do appropriate work 
when the state of your activity changes. 
The following skeleton activity includes each of the fundamental lifecycle methods:

```java
public class ExampleActivity extends Activity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // The activity is being created.
  }
  @Override
  protected void onStart() {
    super.onStart();
    // The activity is about to become visible.
  }
  @Override
  protected void onResume() {
    super.onResume();
    // The activity has become visible (it is now "resumed").
  }
  @Override
  protected void onPause() {
    super.onPause();
    // Another activity is taking focus (this activity is about to be "paused").
  }
  @Override
  protected void onStop() {
    super.onStop();
    // The activity is no longer visible (it is now "stopped")
  }
  @Override
  protected void onDestroy() {
    super.onDestroy();
    // The activity is about to be destroyed.
  }
}
```

> **Note:** Your implementation of these lifecycle methods must always call the superclass implementation 
before doing any work, as shown in the examples above.

Taken together, these methods define the entire lifecycle of an activity. 
By implementing these methods, you can monitor three nested loops in the activity lifecycle: 

- The **entire lifetime** of an activity happens between the call to `onCreate()` and the call to `onDestroy()`.
  Your activity should perform setup of "global" state (such as defining layout) in `onCreate()`, 
  and release all remaining resources in `onDestroy()`. 
  For example, if your activity has a thread running in the background to download data from the network, 
  it might create that thread in `onCreate()` and then stop the thread in `onDestroy()`.

  **完整生命周期**从`onCreate()`开始到`onDestroy()`结束。
  
- The **visible lifetime** of an activity happens between the call to `onStart()` and the call to `onStop()`.
  During this time, the user can see the activity on-screen and interact with it. 
  For example, `onStop()` is called when a new activity starts and this one is no longer visible. 
  Between these two methods, you can maintain resources that are needed to show the activity to the user. 
  For example, you can register a `BroadcastReceiver` in `onStart()` to monitor changes that impact your UI, 
  and unregister it in `onStop()` when the user can no longer see what you are displaying. 
  The system might call `onStart()` and `onStop()` multiple times during the entire lifetime of the activity, 
  as the activity alternates between being visible and hidden to the user.

  **可见生命周期**从`onStart()`开始到`onStop()`结束。在这段时间中Activity是可见和可交互的。
  这两个函数可能会被调用多次，因为Activity可以在可见和不可见之间切换。

- The **foreground lifetime** of an activity happens between the call to `onResume()` and the call to `onPause()`.
  During this time, the activity is in front of all other activities on screen and has user input focus. 
  An activity can frequently transition in and out of the foreground - for example, 
  `onPause()` is called when the device goes to sleep or when a dialog appears. 
  Because this state can transition often, the code in these two methods should be fairly lightweight 
  in order to avoid slow transitions that make the user wait.

  **可见生命周期**中还包含**前台生命周期**，这个周期从`onResume()`开始到`onPause()`结束。
  这段时间中，Activity运行在屏幕最前端并获取到了用户焦点。
  Activity可能频繁退出和进入**前台生命周期**，因此这两个回调函数应该执行尽量少的代码避免在切换时让用户等待。

可能的调用流程：
```
               ______________________________________________
              |                                              |
              v                                              |
          onRestart         ___________                      |
              |            |           |                     |
              v            v           |                     |
onCreate -> onStart -> onResume -> onPause(*) -> onStop(*) -- --> onDestroy(*)
              |                                    ^
              |                                    |   (*) is "killable"
               ------------------------------------
```

> **Note:** An activity that's not technically "killable" by this definition 
might still be killed by the system - but that would happen only in extreme circumstances 
when there is no other recourse. 
When an activity might be killed is discussed more in the `Processes and Threading` document.

> 处在不可杀掉状态的Activity可能仍然被系统杀掉，但是这仅发生没有其他资源可用的极端情况下。
详细情况可参考`Processes and Threading`部分。

### Saving activity state

The introduction to `Managing the Activity Lifecycle` briefly mentions that 
when an activity is paused or stopped, the state of the activity is retained. 
This is true because the `Activity` object is still held in memory when it is paused or stopped - 
all information about its members and current state is still alive. 
Thus, any changes the user made within the activity are retained 
so that when the activity returns to the foreground (when it "resumes"), those changes are still there.

However, when the system destroys an activity in order to recover memory, the `Activity` object is destroyed, 
so the system cannot simply resume it with its state intact. 
Instead, the system must recreate the `Activity` object if the user navigates back to it. 
Yet, the user is unaware that the system destroyed the activity and recreated it and, thus, 
probably expects the activity to be exactly as it was. 
In this situation, you can ensure that important information about the activity state 
is preserved by implementing an additional callback method that allows you to save information 
about the state of your activity: `onSaveInstanceState()`.

然而，如果系统将Activity销毁掉了，系统就很难将它的状态完整的还原。
当用户回再回到这个Activity时，系统必须从头开始创建Activity。
用户不会知道系统销毁了Activity有重新创建了它，因此期望这个Activity会回到原来的样子。
这种情况下，可以额外实现回调函数`onSaveInstanceState()`将Activity的状态信息先保存起来。

The system calls `onSaveInstanceState()` before making the activity vulnerable to destruction. 
The system passes this method a `Bundle` in which you can save state information about the activity 
as name - value pairs, using methods such as `putString()` and `putInt()`. 
Then, if the system kills your application process and the user navigates back to your activity, 
the system recreates the activity and passes the `Bundle` to both `onCreate()` and `onRestoreInstanceState()`.
Using either of these methods, you can extract your saved state from the `Bundle` and restore the activity state.
If there is no state information to restore, then the `Bundle` passed to you is null 
(which is the case when the activity is created for the first time).

在`onSaveInstanceState()`里可以将参数保存到`Bundle`参数中。
当系统重新创建Activity时，会把`Bundle`传递到函数`onCreate()`和`onRestoreInstanceState()`中。
使用这两个函数之一，你可以用`Bundle`中的信息将Activity恢复到原来的状态。
当第一次创建Activity时，`Bundle`参数会是`null`。

> **Note:** There's no guarantee that `onSaveInstanceState()` will be called before your activity is destroyed,
because there are cases in which it won't be necessary to save the state (such as when the user leaves 
your activity using the *Back* button, because the user is explicitly closing the activity). 
If the system calls `onSaveInstanceState()`, it does so before `onStop()` and possibly before `onPause()`.

> 然而，不能保证`onSaveInstance()`一定会在Activity销毁之前被调用。
但是如果被调用，会在`onStop()`或`onPause()`之前调用。

However, even if you do nothing and do not implement `onSaveInstanceState()`, some of the activity state 
is restored by the `Activity` class's default implementation of `onSaveInstanceState()`. 
Specifically, the default implementation calls the corresponding `onSaveInstanceState()` method 
for every `View` in the layout, which allows each view to provide information about itself that should be saved.
Almost every widget in the Android framework implements this method as appropriate, 
such that any visible changes to the UI are automatically saved and restored when your activity is recreated. 
For example, the `EditText` widget saves any text entered by the user and the `CheckBox` widget saves 
whether it's checked or not. 
The only work required by you is to provide a unique ID (with the `android:id` attribute) for each widget 
you want to save its state. 
If a widget does not have an ID, then the system cannot save its state.

然而，即使你没有实现`onSaveInstanceState()`这个函数，
Activity的一些状态还是会被Activity默认的`onSaveInstanceState()`函数回复。
具体的，这个函数会依次调用布局中所有View对象的`onSaveInstanceState()`函数。
几乎所有Android控件都实现了这个回调函数。
你唯一需要做的是为每一个想要保存其状态的控件提供一个唯一的ID（通过`android:id`属性）。
如果一个控件没有ID，系统就不会保存它的状态。

You can also explicitly stop a view in your layout from saving its state 
by setting the `android:saveEnabled` attribute to "false" or by calling the `setSaveEnabled()` method. 
Usually, you should not disable this, 
but you might if you want to restore the state of the activity UI differently.

也可以将`android:saveEnabled`设定成`“false”`或调用`setSaveEnabled()`函数明确的不让系统保存一个View的状态信息。

Although the default implementation of `onSaveInstanceState()` saves useful information about your activity's UI,
you still might need to override it to save additional information. 
For example, you might need to save member values that changed during the activity's life 
(which might correlate to values restored in the UI, 
but the members that hold those UI values are not restored, by default).

Because the default implementation of `onSaveInstanceState()` helps save the state of the UI, 
if you override the method in order to save additional state information, 
you should always call the superclass implementation of `onSaveInstanceState()` before doing any work. 
Likewise, you should also call the superclass implementation of `onRestoreInstanceState()` if you override it, 
so the default implementation can restore view states.

虽然默认实现的`onSaveInstanceState`会帮忙保存UI信息，
但你仍然可能需要重新实现这个函数用来保存其他额外的信息。

当实现自己的函数时，必须先调用父类的`onSaveInstanceState()`函数。
同样，实现`onRestoreInstanceState()`函数时必须先调用父类的`onRestoreInstanceState()`。

> **Note:** Because `onSaveInstanceState()` is not guaranteed to be called, 
you should use it only to record the transient state of the activity (the state of the UI) - 
you should never use it to store persistent data. 
Instead, you should use `onPause()` to store persistent data (such as data that should be saved to a database)
when the user leaves the activity.

> 因为`onSaveInstanceState()`不保证一定会调到，只应该在这个函数中保存Activity的瞬时状态，
而不能使用这个函数保存永久数据。
**相反，应该在`onPuase()`函数中保存这些永久数据**（如那些要保存到数据库中的数据）。

A good way to test your application's ability to restore its state is to simply rotate the device 
so that the screen orientation changes. 
When the screen orientation changes, the system destroys and recreates the activity in order to 
apply alternative resources that might be available for the new screen configuration. 
For this reason alone, it's very important that your activity completely restores its state when it is recreated,
because users regularly rotate the screen while using applications.

测试你的应用是否能成功恢复状态的一种好方法是旋转设备不断切换屏幕的朝向。

### Handling configuration changes

Some device configurations can change during runtime (such as screen orientation, keyboard availability, and language). When such a change occurs, Android recreates the running activity (the system calls onDestroy(), then immediately calls onCreate()). This behavior is designed to help your application adapt to new configurations by automatically reloading your application with alternative resources that you've provided (such as different layouts for different screen orientations and sizes).

If you properly design your activity to handle a restart due to a screen orientation change and restore the activity state as described above, your application will be more resilient to other unexpected events in the activity lifecycle.

The best way to handle such a restart is to save and restore the state of your activity using onSaveInstanceState() and onRestoreInstanceState() (or onCreate()), as discussed in the previous section.

For more information about configuration changes that happen at runtime and how you can handle them, read the guide to Handling Runtime Changes.

### Coordinating activities

When one activity starts another, they both experience lifecycle transitions. The first activity pauses and stops (though, it won't stop if it's still visible in the background), while the other activity is created. In case these activities share data saved to disc or elsewhere, it's important to understand that the first activity is not completely stopped before the second one is created. Rather, the process of starting the second one overlaps with the process of stopping the first one.

The order of lifecycle callbacks is well defined, particularly when the two activities are in the same process and one is starting the other. Here's the order of operations that occur when Activity A starts Acivity B:

1. Activity A's onPause() method executes.
2. Activity B's onCreate(), onStart(), and onResume() methods execute in sequence. 
   (Activity B now has user focus.)
3. Then, if Activity A is no longer visible on screen, its onStop() method executes.

This predictable sequence of lifecycle callbacks allows you to manage the transition of information from one activity to another. For example, if you must write to a database when the first activity stops so that the following activity can read it, then you should write to the database during onPause() instead of during onStop().


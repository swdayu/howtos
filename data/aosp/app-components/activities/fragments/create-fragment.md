
## Creating a Fragment

To create a fragment, you must create a subclass of `Fragment` (or an existing subclass of it). 
The `Fragment` class has code that looks a lot like an `Activity`. 
It contains callback methods similar to an activity, 
such as `onCreate()`, `onStart()`, `onPause()`, and `onStop()`. 
In fact, if you're converting an existing Android application to use fragments, 
you might simply move code from your activity's callback methods 
into the respective callback methods of your fragment.

实现一个Fragment，需要从Fragment类继承（或它的子类）。Fragment跟Activity非常相像。

Usually, you should implement at least the following lifecycle methods:

通常，至少应该实现下面这3个生命周期的回调函数：

- `onCreate()`:  The system calls this when creating the fragment. 
   Within your implementation, you should initialize essential components of the fragment 
   that you want to retain when the fragment is paused or stopped, then resumed.
  
- `onCreateView()`: The system calls this when it's time for the fragment to draw its user interface 
   for the first time. To draw a UI for your fragment, you must return a `View` from this method 
   that is the root of your fragment's layout. You can return null if the fragment does not provide a UI.

    当系统第一次想要为Fragment绘制用户界面时，这个函数就会被调用。
    为了绘制Fragment的用户界面，应该用这个函数返回你的Frangement的根布局的View对象。
    如果这个Fragment不提供用户界面，则应该返回`null`。

- `onPause()`: The system calls this method as the first indication that the user is leaving the fragment 
   (though it does not always mean the fragment is being destroyed). 
   This is usually where you should commit any changes that should be persisted 
   beyond the current user session (because the user might not come back).

    在这个函数中，通常应将改变了的永久性数据保存起来（因为用户可能不再回到这个界面）。

Activity在运行时Fragment的生命周期：
```
[Fragment is added] 
         |
         v
      onAttach -> onCreate -> onCreateView -> onActivityCreated -> onStart -> onResume
                                 ^                                                |
                                 | (#2)                                           v
    onDetach <- onDestroy <- onDestroyView <- onStop <- onPause <--(#1)-- [Fragment is active]
       |
       v
[Fragment is destroyed]  

(#1): User navigates backward or fragment is removed/replaced, 
      or the fragment is added to the back stack, then removed/replaced
(#2): The fragment returns to the layout from the back stack
```

Most applications should implement at least these three methods for every fragment, 
but there are several other callback methods you should also use to handle 
various stages of the fragment lifecycle. 
All the lifecycle callback methods are discussed in more detail 
in the section about `Handling the Fragment Lifecycle`.

大多数应用都应该为Fragment实现这3个回调函数，但还有很多其他的回调函数可以用来处理Fragment生命周期的状态。
详细的介绍见`Handling the Fragment Lifecycle`部分。

There are also a few subclasses that you might want to extend, instead of the base `Fragment` class:

- `DialogFragment`: Displays a floating dialog. Using this class to create a dialog is a good alternative 
   to using the dialog helper methods in the `Activity` class, 
   because you can incorporate a fragment dialog into the back stack of fragments managed by the activity, 
   allowing the user to return to a dismissed fragment.
   
- `ListFragment`: Displays a list of items that are managed by an adapter (such as a `SimpleCursorAdapter`), 
   similar to `ListActivity`. It provides several methods for managing a list `view`, 
   such as the `onListItemClick()` callback to handle click events.

- `PreferenceFragment`: Displays a hierarchy of Preference objects as a list, similar to P`referenceActivity`. 
   This is useful when creating a "settings" activity for your application. 

也可以从上面的3个子类继承实现你自己的Fragment。    

### Adding a user interface

A fragment is usually used as part of an activity's user interface 
and contributes its own layout to the activity.
To provide a layout for a fragment, you must implement the `onCreateView()` callback method, 
which the Android system calls when it's time for the fragment to draw its layout. 
Your implementation of this method must return a `View` that is the root of your fragment's layout.

Fragment通常作为Activity用户界面的一部分使用。
你需要实现`onCreateView()`回调函数返回Fragment的界面布局。

> **Note:** If your fragment is a subclass of `ListFragment`, the default implementation 
returns a `ListView` from `onCreateView()`, so you don't need to implement it.

> 注意，如果你从子类`ListFragment`继承，默认的实现会返回`ListView`，因此你不需要再实现一个。

To return a layout from `onCreateView()`, you can inflate it from a layout resource defined in XML. 
To help you do so, `onCreateView()` provides a `LayoutInflater` object.

可以在XML文件中定义Fragment的布局，然后通过`onCreateView()`提供的参数`LayoutInflater`返回布局。

For example, here's a subclass of `Fragment` that loads a layout from the `example_fragment.xml` file:
```java
public static class ExampleFragment extends Fragment {
  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    // Inflate the layout for this fragment
    return inflater.inflate(R.layout.example_fragment, container, false);
  }
}
```

**Creating a layout:**  In the sample above, `R.layout.example_fragment` is a reference to a layout resource 
named `example_fragment.xml` saved in the application resources. 
For information about how to create a layout in XML, see the `User Interface` documentation.

如何通过XML定义布局可参加`User Interface`部分。

The `container` parameter passed to `onCreateView()` is the parent `ViewGroup` (from the activity's layout) 
in which your fragment layout will be inserted. 
The `savedInstanceState` parameter is a `Bundle` that provides data about the previous instance of the fragment, 
if the fragment is being resumed (restoring state is discussed more in the section 
about `Handling the Fragment Lifecycle`).

The `inflate()` method takes three arguments:
- The resource ID of the layout you want to inflate.
- The `ViewGroup` to be the parent of the inflated layout. 
  Passing the container is important in order for the system to apply layout parameters to 
  the root view of the inflated layout, specified by the parent `view` in which it's going.
- A `boolean` indicating whether the inflated layout should be attached to the `ViewGroup` 
  (the second parameter) during inflation. 
  (In this case, this is false because the system is already inserting the inflated layout 
  into the `container` - passing true would create a redundant view group in the final layout.)

Now you've seen how to create a fragment that provides a layout. 
Next, you need to add the fragment to your activity.

这里看到了如果实现一个带有布局的Fragment。
接下来，需要将实现的Fragment添加到Activity中。

### Adding a fragment to an activity

Usually, a fragment contributes a portion of UI to the host activity, 
which is embedded as a port of the activity's overall view hierarchy.
There are two ways you can add a fragment to the activity layout:

有两种方法将Fragment添加到Activity的布局中：

**Declare the fragment inside the activity's layout file**

In this case, you can specify layout properties for the fragment as if were a view.
For example, here's the layout file for an activity with two fragments:

第一种方法，你可以想添加一个View一样将Fragment添加到Activity的布局文件中。

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
  android:orientation="horizontal"
  android:layout_width="match_parent"
  android:layout_height="match_parent">
  <fragment android:name="com.example.news.ArticleListFragment"
    android:id="@+id/list"
    android:layout_weight="1"
    android:layout_width="0dp"
    android:layout_height="match_parent" />
  <fragment android:name="com.example.news.ArticleReaderFragment"
    android:id="@+id/viewer"
    android:layout_weight="2"
    android:layout_width="0dp"
    android:layout_height="match_parent" />
</LinearLayout>
```

The `android:name` attribute in the `<fragment>` specifies the `Fragment` class to instantiate in the layout.

When the system creates this activity layout, it instantiates each fragment specified in the layout 
and calls the `onCreateView()` method for each one, to retrieve each fragment's layout. 
The system inserts the `View` returned by the fragment directly in place of the `<fragment>` element.

> **Note:** Each fragment requires a unique identifier that the system can use to restore the fragment 
if the activity is restarted (and which you can use to capture the fragment to perform transactions, 
such as remove it). 

> There are three ways to provide an ID for a fragment:
> - Supply the `android:id` attribute with a unique ID.
> - Supply the `android:tag` attribute with a unique string.
> - If you provide neither of the previous two, the system uses the ID of the container view.

> 每一个Fragment都必须提供一个唯一的ID。

> 有三种方法可以为Fragment提供ID：
> - 通过`android:id`属性提供一个ID
> - 通过`android:tag`属性提供一个ID字符串
> - 如果都没有提供，则使用包含Fragment的容器的View ID

**Or, programmatically add the fragment to an existing ViewGroup**

At any time while your activity is running, you can add fragments to your activity layout. 
You simply need to specify a `ViewGroup` in which to place the fragment.

第二种方法是直接将Fragment添加到存在的`ViewGroup`中。

To make fragment transactions in your activity (such as add, remove, or replace a fragment), 
you must use APIs from `FragmentTransaction`. 
You can get an instance of `FragmentTransaction` from your Activity like this:
```java
FragmentManager fragmentManager = getFragmentManager();
FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
```

You can then add a fragment using the `add()` method, 
specifying the fragment to add and the view in which to insert it. 
For example:
```java
ExampleFragment fragment = new ExampleFragment();
fragmentTransaction.add(R.id.fragment_container, fragment);
fragmentTransaction.commit();
```

在Activity中操作Frangment事务，需要使用`FragmentTransaction`，
如上面的例子创建一个事务并将Fragment添加到一个`ViewGroup`容器中。

The first argument passed to `add()` is the `ViewGroup` in which the fragment should be placed, 
specified by resource ID, and the second parameter is the fragment to add.

Once you've made your changes with `FragmentTransaction`, you must call `commit()` for the changes to take effect.

当`FragmentTransaction`发生了改变，必须调用`commit()`使改变生效。

#### Adding a fragment without a UI

The examples above show how to add a fragment to your activity in order to provide a UI. 
However, you can also use a fragment to provide a background behavior for the activity 
without presenting additional UI.

然而，Fragment还可以为Activity执行用户界面无关的后台任务。

To add a fragment without a UI, add the fragment from the activity using `add(Fragment, String)` 
(supplying a unique string "tag" for the fragment, rather than a view ID). 
This adds the fragment, but, because it's not associated with a view in the activity layout, 
it does not receive a call to `onCreateView()`. So you don't need to implement that method.

调用`add(Fragment, String)`可以将用户界面无关的Fragment添加到Activity中。
因为不需要关联View到Activity布局中，因此不会接收到`onCreateView()`的回调，你也不需要实现这个回调函数。

Supplying a string tag for the fragment isn't strictly for non-UI fragments - you can also supply string tags 
to fragments that do have a UI - but if the fragment does not have a UI, 
then the string tag is the only way to identify it. 
If you want to get the fragment from the activity later, you need to use `findFragmentByTag()`.

如果Fragment没有用户界面，使用`tag`字符串的方式是唯一识别Fragment的方式。
如果你需要在Activity中找到对应的Fragment，需要调用`findFragmentByTag()`。

For an example activity that uses a fragment as a background worker, without a UI, 
see the `FragmentRetainInstance.java` sample, which is included in the SDK samples 
(available through the Android SDK Manager) and located on your system as
`<sdk_root>/APIDemos/app/src/main/java/com/example/android/apis/app/FragmentRetainInstance.java`.

把Fragment作为后台任务执行的例子，可参考看`FragmentRetainInstance.java`。


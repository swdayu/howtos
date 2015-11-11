
# Fragments

A Fragment represents a behavior or a portion of user interface in an Activity. 
You can combine multiple fragments in a single activity to build a multi-pane UI 
and reuse a fragment in multiple activities. 
You can think of a fragment as a modular section of an activity, which has its own lifecycle, 
receives its own input events, and which you can add or remove while the activity is running 
(sort of like a "sub activity" that you can reuse in different activities).

A fragment must always be embedded in an activity and the fragment's lifecycle is directly affected 
by the host activity's lifecycle. 
For example, when the activity is paused, so are all fragments in it, 
and when the activity is destroyed, so are all fragments. 
However, while an activity is running (it is in the *resumed* lifecycle state), 
you can manipulate each fragment independently, such as add or remove them. 
When you perform such a fragment transaction, 
you can also add it to a back stack that's managed by the activity - 
each back stack entry in the activity is a record of the fragment transaction that occurred. 
The back stack allows the user to reverse a fragment transaction (navigate backwards), 
by pressing the *Back* button.

When you add a fragment as a part of your activity layout, 
it lives in a `ViewGroup` inside the activity's view hierarchy and the fragment defines its own view layout. 
You can insert a fragment into your activity layout by declaring the fragment in the activity's layout file, 
as a `<fragment>` element, or from your application code by adding it to an existing `ViewGroup`. 
However, a fragment is not required to be a part of the activity layout; 
you may also use a fragment without its own UI as an invisible worker for the activity.

This document describes how to build your application to use fragments, 
including how fragments can maintain their state when added to the activity's back stack, 
share events with the activity and other fragments in the activity, 
contribute to the activity's action bar, and more.

## Design Philosophy

Android introduced fragments in Android 3.0 (API level 11), 
primarily to support more dynamic and flexible UI designs on large screens, such as tablets. 
Because a tablet's screen is much larger than that of a handset, 
there's more room to combine and interchange UI components. 
Fragments allow such designs without the need for you to manage complex changes to the view hierarchy. 
By dividing the layout of an activity into fragments, 
you become able to modify the activity's appearance at runtime and preserve those changes in a back stack 
that's managed by the activity.

For example, a news application can use one fragment to show a list of articles on the left 
and another fragment to display an article on the right - both fragments appear in one activity, side by side, 
and each fragment has its own set of lifecycle callback methods and handle their own user input events. 
Thus, instead of using one activity to select an article and another activity to read the article, 
the user can select an article and read it all within the same activity.

You should design each fragment as a modular and reusable activity component. 
That is, because each fragment defines its own layout and its own behavior with its own lifecycle callbacks, 
you can include one fragment in multiple activities, 
so you should design for reuse and avoid directly manipulating one fragment from another fragment. 
This is especially important because a modular fragment allows you to change your fragment combinations 
for different screen sizes. 
When designing your application to support both tablets and handsets, 
you can reuse your fragments in different layout configurations to optimize the user experience 
based on the available screen space. 
For example, on a handset, it might be necessary to separate fragments to provide a single-pane UI 
when more than one cannot fit within the same activity.

For example - to continue with the news application example - the application 
can embed two fragments in Activity A, when running on a tablet-sized device. 
However, on a handset-sized screen, there's not enough room for both fragments, 
so Activity A includes only the fragment for the list of articles, 
and when the user selects an article, it starts Activity B, 
which includes the second fragment to read the article. 
Thus, the application supports both tablets and handsets by reusing fragments in different combinations.

For more information about designing your application with different fragment combinations 
for different screen configurations, see the guide to `Supporting Tablets and Handsets`.

### Creating a Fragment

To create a fragment, you must create a subclass of `Fragment` (or an existing subclass of it). 
The `Fragment` class has code that looks a lot like an `Activity`. 
It contains callback methods similar to an activity, 
such as `onCreate()`, `onStart()`, `onPause()`, and `onStop()`. 
In fact, if you're converting an existing Android application to use fragments, 
you might simply move code from your activity's callback methods 
into the respective callback methods of your fragment.

Usually, you should implement at least the following lifecycle methods:

- `onCreate()`:  The system calls this when creating the fragment. 
   Within your implementation, you should initialize essential components of the fragment 
   that you want to retain when the fragment is paused or stopped, then resumed.
  
- `onCreateView()`: The system calls this when it's time for the fragment to draw its user interface 
   for the first time. To draw a UI for your fragment, you must return a `View` from this method 
   that is the root of your fragment's layout. You can return null if the fragment does not provide a UI.
   
- `onPause()`: The system calls this method as the first indication that the user is leaving the fragment 
   (though it does not always mean the fragment is being destroyed). 
   This is usually where you should commit any changes that should be persisted 
   beyond the current user session (because the user might not come back).

Most applications should implement at least these three methods for every fragment, 
but there are several other callback methods you should also use to handle 
various stages of the fragment lifecycle. 
All the lifecycle callback methods are discussed in more detail 
in the section about `Handling the Fragment Lifecycle`.

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
    
### Adding a user interface

A fragment is usually used as part of an activity's user interface 
and contributes its own layout to the activity.
To provide a layout for a fragment, you must implement the `onCreateView()` callback method, 
which the Android system calls when it's time for the fragment to draw its layout. 
Your implementation of this method must return a `View` that is the root of your fragment's layout.

> **Note:** If your fragment is a subclass of `ListFragment`, the default implementation 
returns a `ListView` from `onCreateView()`, so you don't need to implement it.

To return a layout from `onCreateView()`, you can inflate it from a layout resource defined in XML. 
To help you do so, `onCreateView()` provides a `LayoutInflater` object.

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

The container parameter passed to `onCreateView()` is the parent `ViewGroup` (from the activity's layout) 
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


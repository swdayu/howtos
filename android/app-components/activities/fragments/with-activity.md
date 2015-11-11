
## Communicating with the Activity

Although a `Fragment` is implemented as an object that's independent from an `Activity`
and cn be used inside multiple activities, a given instance of a fragment is directly tied
to the activity that contains it.

Specifically, the fragment can access the `Activity` instance with `getActivity()` 
and easily perform tasks such as find a view in the activity layout:
```java
View listView = getActivity().findViewById(R.id.list);
```

Likewise, your activity can call methods in the fragment by acquiring a reference to the `Fragment` 
from `FragmentManager`, using `findFragmentById()` or `findFragmentByTag()`. 
For example:
```java
ExampleFragment fragment = (ExampleFragment)
  getFragmentManager().findFragmentById(R.id.example_fragment);
```

Fragment可以通过`getActivity()`访问包含它的Activity。
同样，Activity可以通过`getFragmentManager()`访问到其中的Fragment。

### Creating event callbacks to the activity

In some cases, you might need a fragment to share events with the activity. 
A good way to do that is to define a callback interface inside the fragment and 
require that the host activity implement it. 
When the activity receives a callback through the interface, 
it can share the information with other fragments in the layout as necessary.

在一些情况下，可能需要让Fragment与Activity共享事件。
好的做法是在Fragment中定义回调接口，然后Activity实现这个接口。
当Fragment`onAttach`时将Activity实例保存到回调接口中。
后面如果Fragment中产生了这个事件，就执行保存好的回调接口回调Activity实现的函数，
让Activity有机会对这个事件进行相应的处理。

For example, if a news application has two fragments in an activity - one to show a list of articles (fragment A) 
and another to display an article (fragment B) - then fragment A must tell the activity 
when a list item is selected so that it can tell fragment B to display the article. 
In this case, the `OnArticleSelectedListener` interface is declared inside fragment A:
```java
public static class FragmentA extends ListFragment {
  ...
  // Container Activity must implement this interface
  public interface OnArticleSelectedListener {
    public void onArticleSelected(Uri articleUri);
  }
  ...
}
```

Then the activity that hosts the fragment implements the `OnArticleSelectedListener` interface 
and overrides `onArticleSelected()` to notify fragment B of the event from fragment A. 
To ensure that the host activity implements this interface, fragment A's `onAttach()` callback method 
(which the system calls when adding the fragment to the activity) instantiates an instance 
of `OnArticleSelectedListener` by casting the Activity that is passed into `onAttach()`:
```java
public static class FragmentA extends ListFragment {
  OnArticleSelectedListener mListener;
  ...
  @Override
  public void onAttach(Activity activity) {
    super.onAttach(activity);
    try {
      mListener = (OnArticleSelectedListener)activity;
    } catch (ClassCastException e) {
      throw new ClassCastException(activity.toString() + "must implement OnArticleSelectedListener");
    }
  }
  ...
}
```

If the activity has not implemented the interface, then the fragment throws a `ClassCastException`. 
On success, the `mListener` member holds a reference to activity's implementation of `OnArticleSelectedListener`, 
so that fragment A can share events with the activity by calling methods 
defined by the `OnArticleSelectedListener` interface. 

如果Activity没有实现这个接口，会抛出`ClassCastException`异常。

For example, if fragment A is an extension of ListFragment, each time the user clicks a list item, 
the system calls `onListItemClick()` in the fragment, which then calls `onArticleSelected()` 
to share the event with the activity:
```java
public static class FragmentA extends ListFragment {
  OnArticleSelectedListener mListener;
  ...
  @Override
  public void onListItemClick(ListView l, View v, int position, long id) {
    // Append the clicked item's row ID with the content provider Uri
    Uri noteUri = ContentUris.withAppendedId(ArticleColumns.CONTENT_URI, id);
    // Send the event and Uri to the host activity
    mListener.onArticleSelected(noteUri);
  }
  ...
}
```

The `id` parameter passed to `onListItemClick()` is the row ID of the clicked item, 
which the activity (or other fragment) uses to fetch the article from the application's ContentProvider.

More information about using a content provider is available in the `Content Providers` document.

### Adding items to the App Bar

Your fragments can contribute menu items to the activity's Options Menu (and, consequently, the app bar) 
by implementing `onCreateOptionsMenu()`. 
In order for this method to receive calls, however, you must call `setHasOptionsMenu()` during `onCreate()`, 
to indicate that the fragment would like to add items to the Options Menu 
(otherwise, the fragment will not receive a call to `onCreateOptionsMenu()`).

Any items that you then add to the Options Menu from the fragment are appended to the existing menu items. 
The fragment also receives callbacks to `onOptionsItemSelected()` when a menu item is selected.

Fragment可以实现`onCreateOptionMenu()`回调函数为Activity的选项菜单呈现菜单项。
为了让这个函数回调，必须在`onCreate()`函数中调用`setHasOptionMenu()`来表明Fragment将为选项菜单添加菜单项。
所有来自于Fragment的选项会追加到现有菜单项之后。当菜单项被选定时，Fragment会接收到`onOptionsItemSelected()`回调。

You can also register a view in your fragment layout to provide a context menu 
by calling `registerForContextMenu()`. 
When the user opens the context menu, the fragment receives a call to `onCreateContextMenu()`. 
When the user selects an item, the fragment receives a call to `onContextItemSelected()`.

还可以调用`registerForContextMenu()`将Fragment的布局View注册成交互菜单。
当用户打开交互菜单时，Fragment会接收到`onCreateContextMenu()`回调。
当用户选择其中一个菜单项时，Fragment会接收到`onContextItemSelected()`回调。

> **Note:** Although your fragment receives an on-item-selected callback for each menu item it adds, 
the activity is first to receive the respective callback when the user selects a menu item. 
If the activity's implementation of the on-item-selected callback does not handle the selected item, 
then the event is passed to the fragment's callback. This is true for the Options Menu and context menus.

> 尽管Fragment会接收到每个菜单项选定事件的回调，但Activity是首先接收到这些回调的对象。
只有Activity自己没有实现这些回调函数时，这些事件才会传递给Fragment。
对于选项菜单和交互菜单，这个条件都是成立的。

For more information about menus, see the `Menus` developer guide and the `App Bar` training class.

关于菜单的更多详细信息，参考`Menus`以及`App Bar`部分。


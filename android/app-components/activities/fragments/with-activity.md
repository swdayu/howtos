
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

### Creating event callbacks to the activity

In some cases, you might need a fragment to share events with the activity. 
A good way to do that is to define a callback interface inside the fragment and 
require that the host activity implement it. 
When the activity receives a callback through the interface, 
it can share the information with other fragments in the layout as necessary.

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

You can also register a view in your fragment layout to provide a context menu 
by calling `registerForContextMenu()`. 
When the user opens the context menu, the fragment receives a call to `onCreateContextMenu()`. 
When the user selects an item, the fragment receives a call to `onContextItemSelected()`.

> **Note:** Although your fragment receives an on-item-selected callback for each menu item it adds, 
the activity is first to receive the respective callback when the user selects a menu item. 
If the activity's implementation of the on-item-selected callback does not handle the selected item, 
then the event is passed to the fragment's callback. This is true for the Options Menu and context menus.

For more information about menus, see the `Menus` developer guide and the `App Bar` training class.

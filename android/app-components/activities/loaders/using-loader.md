
## Using Loaders in an Application

This section describes how to use loaders in an Android application. 
An application that uses loaders typically includes the following:
- An `Activity` or `Fragment`.
- An instance of the `LoaderManager`.
- A `CursorLoader` to load data backed by a `ContentProvider`. 
  Alternatively, you can implement your own subclass of `Loader` 
  or `AsyncTaskLoader` to load data from some other source.
- An implementation for `LoaderManager.LoaderCallbacks`. 
  This is where you create new loaders and manage your references to existing loaders.
- A way of displaying the loader's data, such as a `SimpleCursorAdapter`.
- A data source, such as a `ContentProvider`, when using a `CursorLoader`.

在应用中使用Loader需要有：一个Activity或Fragment；一个LoaderManager实例；
基于ContentProvider的CursorLoader，或实现自己的Loader/AsyncTaskLoader加载其他源头数据；
实现LoaderManager.LoaderCallbacks，它用于创建新的Loader以及管理现存Loader的引用；
一种呈现数据的方式，如使用SimpleCursorAdapter；一个数据源，例如使用CursorLoader时需要的ContentProvider。

### Starting a Loader

The LoaderManager manages one or more Loader instances within an Activity or Fragment.
There is only one LoaderManager per activity or fragment.

You typically initialize a Loader within the activity's `onCreate()` method, 
or within the fragment's `onActivityCreated()` method. You do this as follows:
```java
// Prepare the loader.  Either re-connect with an existing one,
// or start a new one.
getLoaderManager().initLoader(0, null, this);
```

The `initLoader()` method takes the following parameters:
- A unique ID that identifies the loader. In this example, the ID is 0.
- Optional arguments to supply to the loader at construction (null in this example).
- A LoaderManager.LoaderCallbacks implementation, which the LoaderManager calls to report loader events.
  In this example, the local class implements the LoaderManager.LoaderCallbacks interface,
  so it passes a reference to itself, `this`.

The `initLoader()` call ensures that a loader is initialized and active.
It has two possible outcomes:
- If the loader specified by the ID already exists, the last created loader is reused
- If the loader specified by the ID does *not* exists, 
  `initLoader()` triggers the LoaderManager.LoaderCallbacks method `onCreateLoader()`.
  This is where you implement the code to instantiate and return a new loader.
  For more discussion, see the section `onCreateLoader`.

In either case, the given LoaderManager.LoaderCallbacks implementation is associated with the loader, 
and will be called when the loader state changes. 
If at the point of this call the caller is in its started state, 
and the requested loader already exists and has generated its data, 
then the system calls `onLoadFinished()` immediately (during `initLoader()`), 
so you must be prepared for this to happen. See `onLoadFinished` for more discussion of this callback

Note that the `initLoader()` method returns the Loader that is created, 
but you don't need to capture a reference to it. The LoaderManager manages the life of the loader automatically.
The LoaderManager starts and stops loading when necessary, 
and maintains the state of the loader and its associated content. 
As this implies, you rarely interact with loaders directly (though for an example of using loader methods 
to fine-tune a loader's behavior, see the `LoaderThrottle` sample). 
You most commonly use the LoaderManager.LoaderCallbacks methods to intervene in the loading process 
when particular events occur. 
For more discussion of this topic, see Using the `LoaderManager Callbacks`.

### Restarting a Loader

When you use `initLoader()`, as shown above, it uses an existing loader with the specified ID if there is one.
If there isn't, it create one. But sometimes you want to discard your old data and start over.

To discard your old data, you use `restartLoader()`.
For example, this implementation of `SearchView.OnQueryTextListener` restarts the loader 
when the user's query changes.
The loader needs to be restarted so that it can use the revised search filter to do a new query:
```java
public boolean onQueryTextChanged(String newText) {
  // Called when the action bar search text has changed.  Update
  // the search filter, and restart the loader to do a new query
  // with this filter.
  mCurFilter = !TextUtils.isEmpty(newText) ? newText : null;
  getLoaderManager().restartLoader(0, null, this);
  return true;
}
```

### Using the LoaderManager Callbacks

LoaderManager.LoaderCallbacks is a callback interface that lets a client interact with the LoaderManager.
Loaders, in particular CursorLoader, are expected to retain their data after being stopped. 
This allows applications to keep their data across the activity or fragment's `onStop()` and `onStart()` methods,
so that when users return to an application, they don't have to wait for the data to reload. 
You use the LoaderManager.LoaderCallbacks methods when to know when to create a new loader, 
and to tell the application when it is time to stop using a loader's data.


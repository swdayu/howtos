
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

通常在Activity的`onCreate()`或Fragment的`onActivityCreated()`回调函数中调用`initLoader()`初始化一个Loader。

The `initLoader()` method takes the following parameters:
- A unique ID that identifies the loader. In this example, the ID is 0.
- Optional arguments to supply to the loader at construction (null in this example).
- A LoaderManager.LoaderCallbacks implementation, which the LoaderManager calls to report loader events.
  In this example, the local class implements the LoaderManager.LoaderCallbacks interface,
  so it passes a reference to itself, `this`.

函数`initLoader()`的第一个参数指定Loader的唯一ID，这个例子中ID是0；
第二个参数是传递给Loader构造器的参数，这个例子中是`null`；
第三个参数是实现了`LoaderManager.LoaderCallbacks`接口的类对象，
当Loader相关事件发生时LoaderManager会调用这个接口的函数，这个例子中当前类实现了这个接口，因此传入的是`this`。

The `initLoader()` call ensures that a loader is initialized and active.
It has two possible outcomes:
- If the loader specified by the ID already exists, the last created loader is reused
- If the loader specified by the ID does *not* exists, 
  `initLoader()` triggers the LoaderManager.LoaderCallbacks method `onCreateLoader()`.
  This is where you implement the code to instantiate and return a new loader.
  For more discussion, see the section `onCreateLoader`.

调用完`initLoader()`会确保Loader初始化完成并处于活动状态。
有两种可能结果：如果指定的ID已经存在，会重用最近一次创建的Loader；
否则`initLoader()`会触发调用`LoaderManager.LoaderCallbacks`接口中的`onCreateLoader()`，
这是你实例化并返回新创建的Loader的地方，详细信息见`onCreateLoader`部分。

In either case, the given LoaderManager.LoaderCallbacks implementation is associated with the loader, 
and will be called when the loader state changes. 
If at the point of this call the caller is in its started state, 
and the requested loader already exists and has generated its data, 
then the system calls `onLoadFinished()` immediately (during `initLoader()`), 
so you must be prepared for this to happen. See `onLoadFinished` for more discussion of this callback

两种情况，传入的`LoaderManager.LoaderCallbacks`接口实例对象都会与Loader关联，
当Loader状态发生变化时会调用其中对应的函数。

Note that the `initLoader()` method returns the Loader that is created, 
but you don't need to capture a reference to it. The LoaderManager manages the life of the loader automatically.
The LoaderManager starts and stops loading when necessary, 
and maintains the state of the loader and its associated content. 
As this implies, you rarely interact with loaders directly (though for an example of using loader methods 
to fine-tune a loader's behavior, see the `LoaderThrottle` sample). 
You most commonly use the LoaderManager.LoaderCallbacks methods to intervene in the loading process 
when particular events occur. 
For more discussion of this topic, see `Using the LoaderManager Callbacks`.

`initLoader()`返回创建的Loader，但不需要获取它的引用。LoaderManager会自动管理Loader的生命周期。
LoaderManager在需要的时候会自动开始或停止加载数据，并且维护Loader及其内容的状态。
也即，你很少需要直接与Loader交互。
你主要需要做的是使用LoaderManager.LoaderCallback定义的函数当特定事件发生时干预到加载过程中。
这个主题更详细的信息见`Using the LoaderManger Callbacks`。

### Restarting a Loader

When you use `initLoader()`, as shown above, it uses an existing loader with the specified ID if there is one.
If there isn't, it create one. But sometimes you want to discard your old data and start over.

使用`initLoader()`的时候，如果ID已存在会使用已存 的Loader，否则重新创建一个。
但有时你可能需要丢弃原来的Loader并重新开头创建一个。

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

使用函数`restartLoader()`可以将老的Loader丢弃掉。
如上面的例子用户查询发生改变时，调用`restartLoader()`会丢弃掉原来的再重新创建一个Loader。

### Using the LoaderManager Callbacks

LoaderManager.LoaderCallbacks is a callback interface that lets a client interact with the LoaderManager.
Loaders, in particular CursorLoader, are expected to retain their data after being stopped. 
This allows applications to keep their data across the activity or fragment's `onStop()` and `onStart()` methods,
so that when users return to an application, they don't have to wait for the data to reload. 
You use the LoaderManager.LoaderCallbacks methods when to know when to create a new loader, 
and to tell the application when it is time to stop using a loader's data.


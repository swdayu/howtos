
## Loader API Summary

There are multiple classes and interfaces that may be involved in using loaders in an application.
They are summarized below:

- **LoaderManager**: An abstract class associated with an Activity or Fragment 
    for managing one or more Loader instances. 
    This helps an application manage longer-running operations in conjunction with 
    the Activity or Fragment lifecycle; the most common use of this is with a `CursorLoader`, 
    however applications are free to write their own loaders for loading other types of data.
    
    There is only one `LoaderManager` per activity or fragment. 
    But a `LoaderManager` can have multiple loaders.

    每个Activity或Fragment都只有一个`LoaderManager`。
    但是一个`LoaderManager`可以有多个Loader。

- **LoaderManager.LoaderCallbacks**: A callback interface for a client to interact with the `LoaderManager`. 
    For example, you use the `onCreateLoader()` callback method to create a new loader.

    与`LoaderManager`交互的回调接口。例如可以使用`onCreateLoader()`回调函数创建一个新的Loader。

- **Loader**: An abstract class that performs asynchronous loading of data. 
    This is the base class for a loader. You would typically use `CursorLoader`, 
    but you can implement your own subclass. 
    While loaders are active they should monitor the source of their data and 
    deliver new results when the contents change. 

    执行异步数据加载的抽象类。它是Loader的基类，一般会使用`CursorLoader`，但可以实现自己的子类。
    当Loader处于活动状态时，需要监控数据源头，当内容改变时传递新结果。

- **AsyncTaskLoader**: Abstract loader that provides an `AsyncTask` to do the work.

    提供`AsyncTask`执行任务的抽象Loader。

- **CursorLoader**: A subclass of `AsyncTaskLoader` that queries the `ContentResolver` and returns a `Cursor`. 
    This class implements the `Loader` protocol in a standard way for querying cursors, 
    building on `AsyncTaskLoader` to perform the cursor query on a background thread 
    so that it does not block the application's UI. 
    Using this loader is the best way to asynchronously load data from a `ContentProvider`, 
    instead of performing a managed query through the fragment or activity's APIs.

    `AsyncTaskLoader`的子类，它需要用到`ContentResolver`并返回`Cursor`。
    这个类实现了`Loader`协议对游标查询的标准操作，即创建一个`AsyncTaskLoader`在后台线程执行查询工作，
    从而不会阻塞应用用户界面。
    与使用Activity或Fragment的API执行查询，使用这个Loader是从`ContentProvider`异步加载数据的最好方法。

The classes and interfaces in the above table are the essential components you'll use 
to implement a loader in your application. 
You won't need all of them for each loader you create, but you'll always need a reference to the `LoaderManager` 
in order to initialize a loader and an implementation of a `Loader` class such as `CursorLoader`. 
The following sections show you how to use these classes and interfaces in an application.

[Next: Using Loaders in an Application](./using-loader.md)

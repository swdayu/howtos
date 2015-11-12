
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




## Managing Fragments

To manage the fragments in your activity, you need to use `FragmentManager`. 
To get it, call `getFragmentManager()` from your activity.

Some things that you can do with `FragmentManager` include:
- Get fragments that exist in the activity, with `findFragmentById()` 
  (for fragments that provide a UI in the activity layout) or `findFragmentByTag()` 
  (for fragments that do or don't provide a UI).
- Pop fragments off the back stack, with `popBackStack()` (simulating a `Back` command by the user).
- Register a listener for changes to the back stack, with `addOnBackStackChangedListener()`.

For more information about these methods and others, refer to the `FragmentManager` class documentation.

As demonstrated in the previous section, you can also use `FragmentManager` to open a `FragmentTransaction`, 
which allows you to perform transactions, such as add and remove fragments.


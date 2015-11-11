
## Managing Fragments

To manage the fragments in your activity, you need to use `FragmentManager`. 
To get it, call `getFragmentManager()` from your activity.

可以调用`getFragmentManager()`在Activity中管理Fragment。

Some things that you can do with `FragmentManager` include:
- Get fragments that exist in the activity, with `findFragmentById()` 
  (for fragments that provide a UI in the activity layout) or `findFragmentByTag()` 
  (for fragments that do or don't provide a UI).
- Pop fragments off the back stack, with `popBackStack()` (simulating a `Back` command by the user).
- Register a listener for changes to the back stack, with `addOnBackStackChangedListener()`.

For more information about these methods and others, refer to the `FragmentManager` class documentation.

通过`FragmentManager`，可以：
- 调用`findFragmentById()`（对于提供了用户界面的Fragment）或
  `findFragmentByTag()`（对提供或没提供用户界面的Fragment都可以调用这个函数）获取Activity中的Fragment；
- 调用`popBackStack()`从后备栈中取出一个Fragment（与用户的后退操作类似）；
- 调用`addOnBackStackChangeListener()`注册一个监听后备栈状态变化的监听器；

更多关于`FragmentManager`的信息请参考类文档。

As demonstrated in the previous section, you can also use `FragmentManager` to open a `FragmentTransaction`, 
which allows you to perform transactions, such as add and remove fragments.

`FragmentManager`也可以用来打开一个`FragmentTransaction`，它用于对Fragment进行添加和移除等操作。


# Fragments
- [Design Philosophy](./design-philosophy.md)
- [Creating a Fragment](./create-fragment.md)
- [Managing Fragments](./manage-fragment.md)
- [Performing Fragment Transactions](./fragment-transaction.md)
- [Communicating with the Activity](./with-activity.md)
- [Handling the Fragment Lifecycle](./fragment-lifecycle.md)
- [Example](./fragment-example.md)

A `Fragment` represents a behavior or a portion of user interface in an `Activity`. 
You can combine multiple fragments in a single activity to build a multi-pane UI 
and reuse a fragment in multiple activities. 
You can think of a fragment as a modular section of an activity, which has its own lifecycle, 
receives its own input events, and which you can add or remove while the activity is running 
(sort of like a "sub activity" that you can reuse in different activities).

Fragment可以表示Activity的一个子任务或用户界面的一部分。
可以在一个Activity中使用多个Fragment实现一个多窗体信息的用户界面，一个Fragment还可以重用到多个Activity中。

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

Fragment必须用在Activity内部，它的生命周期直接受Activity生命周期的影响。
例如，如果Activity暂停了，其中的所有Fragment都会暂停；如果Activity销毁掉了，那么所有Fragment也一样。
而如果Activity处在运行状态（及*Resumed*生命周期状态），可以独立的对Fragment进行操作，例如进行添加和移除。
当执行这些Fragment事务的时候，你还可以将Fragment添加到Activity维护的后备栈中。
后备栈允许用户按返回按钮回退Fragment事务。

When you add a fragment as a part of your activity layout, 
it lives in a `ViewGroup` inside the activity's view hierarchy and the fragment defines its own view layout. 
You can insert a fragment into your activity layout by declaring the fragment in the activity's layout file, 
as a `<fragment>` element, or from your application code by adding it to an existing `ViewGroup`. 
However, a fragment is not required to be a part of the activity layout; 
you may also use a fragment without its own UI as an invisible worker for the activity.

当添加一个Fragment作为Activity布局的一部分时，
这个Fragment会存在于Activity View结构中的一个`ViewGroup`内，
并且这个内部的Fragment还会定义自己的试图布局。
可以通过Activity的布局文件中的`<fragment>`元素将一个Fragment添加到Activity布局中，
或者在代码中直接将Fragment添加到一个存在的`ViewGroup`中。

**然而，Frangment不一定要成为Activity布局的一部分，也可以没有用户界面不可见地为Activity执行任务。**

This document describes how to build your application to use fragments, 
including how fragments can maintain their state when added to the activity's back stack, 
share events with the activity and other fragments in the activity, 
contribute to the activity's action bar, and more.

这部分描述怎样使用Fragment创建应用程序，包括当添加到Activity的后备栈是如果管理它的状态、
如何与Activity以及Activity中的其他Fragment共享事件，等等。

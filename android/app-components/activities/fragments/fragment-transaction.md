
## Performing Fragment Transactions

A great feature about using fragments in your activity is the ability to add, remove, replace, 
and perform other actions with them, in response to user interaction. 
Each set of changes that you commit to the activity is called a transaction 
and you can perform one using APIs in `FragmentTransaction`. 
You can also save each transaction to a back stack managed by the activity, 
allowing the user to navigate backward through the fragment changes 
(similar to navigating backward through activities).

You can acquire an instance of `FragmentTransaction` from the `FragmentManager` like this:
```java
FragmentManager fragmentManager = getFragmentManager();
FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
```

Each transaction is a set of changes that you want to perform at the same time. 
You can set up all the changes you want to perform for a given transaction using methods 
such as `add()`, `remove()`, and `replace()`. 
Then, to apply the transaction to the activity, you must call `commit()`.

Before you call `commit()`, however, you might want to call `addToBackStack()`, 
in order to add the transaction to a back stack of fragment transactions. 
This back stack is managed by the activity and allows the user to return to the previous fragment state, 
by pressing the `Back` button.

在调用`commit()`之前，可以调用`addToBackStack()`将事务操作保存到后备栈中。
Activity维护的后备栈允许用户按后退按钮回退到前一个Fragment状态。

For example, here's how you can replace one fragment with another, 
and preserve the previous state in the back stack:
```java
// Create new fragment and transaction
Fragment newFragment = new ExampleFragment();
FragmentTransaction transaction = getFragmentManager().beginTransaction();

// Replace whatever is in the fragment_container view with this fragment,
// and add the transaction to the back stack
transaction.replace(R.id.fragment_container, newFragment);
transaction.addToBackStack(null);

// Commit the transaction
transaction.commit();
```

In this example, `newFragment` replaces whatever fragment (if any) is currently in the layout container 
identified by the `R.id.fragment_container` ID. 
By calling `addToBackStack()`, the replace transaction is saved to the back stack 
so the user can reverse the transaction and bring back the previous fragment by pressing the Back button.

If you add multiple changes to the transaction (such as another `add()` or `remove()`) and call `addToBackStack()`, 
then all changes applied before you call `commit()` are added to the back stack as a single transaction 
and the `Back` button will reverse them all together.

The order in which you add changes to a `FragmentTransaction` doesn't matter, except:
- You must call `commit()` last
- If you're adding multiple fragments to the same container, 
  then the order in which you add them determines the order they appear in the view hierarchy

If you do not call `addToBackStack()` when you perform a transaction that removes a fragment, 
then that fragment is destroyed when the transaction is committed and the user cannot navigate back to it. 
Whereas, if you do call `addToBackStack()` when removing a fragment, 
then the fragment is stopped and will be resumed if the user navigates back.

当移除一个Fragment时，如果不调用`addToBackStack()`，对应的Fragment会被销毁，当事务提交完后用户就不能回退回去了。
但如调用了`addToBackStack()`，对应的Fragment只是会被Stop，当用户回退时将重新启动显示。

> **Tip:** For each fragment transaction, you can apply a transition animation, 
by calling `setTransition()` before you commit.

> 对于每一个Fragment事务，都可以调用`setTransition()`设置一个转换动画。

Calling `commit()` does not perform the transaction immediately. 
Rather, it schedules it to run on the activity's UI thread (the "main" thread) 
as soon as the thread is able to do so. 
If necessary, however, you may call `executePendingTransactions()` from your UI thread 
to immediately execute transactions submitted by `commit()`. 
Doing so is usually not necessary unless the transaction is a dependency for jobs in other threads.

调用`commit()`不会立即执行事务操作，而要等Activity用户界面线程（主线程）调度到才执行。
如果需要，你可以在你的用户界面线程调用`executePendingTransactions()`立即执行事务操作。
一般不需要这样做，除非事务依赖于其他线程中的操作。

> **Caution:** You can commit a transaction using `commit()` only prior to the activity saving its state 
(when the user leaves the activity). If you attempt to commit after that point, an exception will be thrown. 
This is because the state after the commit can be lost if the activity needs to be restored. 
For situations in which its okay that you lose the commit, use `commitAllowingStateLoss()`.

> Fragment事务的`commit()`必须在Activity执行状态保持之前执行，如果在这之后会抛出异常。




## Handling the Fragment Lifecycle

Managing the lifecycle of a fragment is a lot like managing the lifecycle of an activity. 
Like an activity, a fragment can exist in three states:
- **Resumed**: The fragment is visible in the running activity.
- **Paused**: Another activity is in the foreground and has focus, 
    but the activity in which this fragment lives is still visible 
    (the foreground activity is partially transparent or doesn't cover the entire screen).
- **Stopped**: The fragment is not visible. 
    Either the host activity has been stopped or 
    the fragment has been removed from the activity but added to the back stack. 
    A stopped fragment is still alive (all state and member information is retained by the system). 
    However, it is no longer visible to the user and will be killed if the activity is killed. 

**暂停状态**：其他Activity运行到前台获取了用户焦点，但是Fragment所在的Activity仍然是可见的
（前台Activity没有完全遮蔽后台Activity）。
**停止状态**：所在的Activity进入了停止状态或Fragment从Activity中移除添加到了后备栈中。
停止的Fragment仍然是活动的（系统还保留着它所有的状态和信息）。
然而，因为它对用户不可见如果Activity被杀掉了，它也会被杀掉。

Also like an activity, you can retain the state of a fragment using a Bundle, 
in case the activity's process is killed and you need to restore the fragment state when the activity is recreated. 
You can save the state during the fragment's `onSaveInstanceState()` callback 
and restore it during either `onCreate()`, `onCreateView()`, or `onActivityCreated()`. 
For more information about saving state, see the [Activities](../activities.md) document.

像Activity一样，可以使用Bundle保存Fragment的状态，当Activity杀掉再重建时也需要重新恢复Fragment的状态。
可以在`onSaveInstanceState()`回调函数中保存状态，
在`onCreate()`、`onCreateView()`、`onActivityCreated()`函数中进行恢复。
更多的信息见[Activities](../activities.md)部分。

The most significant difference in lifecycle between an activity and a fragment is 
how one is stored in its respective back stack. 
An activity is placed into a back stack of activities that's managed by the system when it's stopped, 
by default (so that the user can navigate back to it with the Back button, as discussed in `Tasks and Back Stack`). 
However, a fragment is placed into a back stack managed by the host activity 
only when you explicitly request that the instance be saved by calling `addToBackStack()` 
during a transaction that removes the fragment.

比较重要的区别是，系统会自动将停止的Activity保存到后备栈中，
而Fragment需要调用`addToBackStack()`进行手动保存。

Otherwise, managing the fragment lifecycle is very similar to managing the activity lifecycle. 
So, the same practices for managing the activity lifecycle also apply to fragments. 
What you also need to understand, though, is how the life of the activity affects the life of the fragment.

> **Caution:** If you need a Context object within your Fragment, you can call `getActivity()`. 
However, be careful to call `getActivity()` only when the fragment is attached to an activity. 
When the fragment is not yet attached, or was detached during the end of its lifecycle, 
`getActivity()` will return null.

> 如果在Fragment中需要一个Context对象，要调用`getActivity()`。
然而只有当Fragment已经与Activity进行了关联才有效。
如果还没有关联或Fragment在其生命周期中Detach了，`getActivity()`会返回`null`。

### Coordinating with the activity lifecycle

The lifecycle of the activity in which the fragment lives directly affects the lifecycle of the fragment, 
such that each lifecycle callback for the activity results in a similar callback for each fragment. 
For example, when the activity receives `onPause()`, each fragment in the activity receives `onPause()`.

Fragments have a few extra lifecycle callbacks, however, that handle unique interaction with the activity 
in order to perform actions such as build and destroy the fragment's UI. 
These additional callback methods are:
- `onAttach()`: Called when the fragment has been associated with the activity (the Activity is passed in here).
- `onCreateView()`: Called to create the view hierarchy associated with the fragment.
- `onActivityCreated()`: Called when the activity's `onCreate()` method has returned.
- `onDestroyView()`: Called when the view hierarchy associated with the fragment is being removed.
- `onDetach()`: Called when the fragment is being disassociated from the activity.

**Figure 3.** The effect of the activity lefecycle on the fragment lifecycle.
```
[Activity State]         | Created                                                   |
[Fragment Calllbacks]    | onAttach -> onCreate -> onCreateView -> onActivityCreated | ->

[Activity State]         | Started |    | Resumed  |    | Paused  |    | Stopped |
[Fragment Calllbacks] -> | onStart | -> | onResume | -> | onPause | -> | onStop  | ->
                      
[Activity State]         | Destroyed                              |
[Fragment Calllbacks] -> | onDestoryView -> onDestory -> onDetach |
```

The flow of a fragment's lifecycle, as it is affected by its host activity, is illustrated by figure 3. 
In this figure, you can see how each successive state of the activity 
determines which callback methods a fragment may receive. 
For example, when the activity has received its `onCreate()` callback, 
a fragment in the activity receives no more than the `onActivityCreated()` callback.

Once the activity reaches the resumed state, you can freely add and remove fragments to the activity. 
Thus, only while the activity is in the resumed state can the lifecycle of a fragment change independently.

However, when the activity leaves the resumed state, 
the fragment again is pushed through its lifecycle by the activity.

只有当Activity在Resume状态时，Fragment才能独立的改变其生命周期状态。
如果Activity离开了Resume状态，Fragment会被迫跟随Activity一起进入相应状态中。

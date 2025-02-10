
## Design Philosophy

Android introduced fragments in Android 3.0 (API level 11), 
primarily to support more dynamic and flexible UI designs on large screens, such as tablets. 
Because a tablet's screen is much larger than that of a handset, 
there's more room to combine and interchange UI components. 
Fragments allow such designs without the need for you to manage complex changes to the view hierarchy. 
By dividing the layout of an activity into fragments, 
you become able to modify the activity's appearance at runtime and preserve those changes in a back stack 
that's managed by the activity.

Fragment的引进是为了支持在大屏幕上实现更加动态以及灵活的用户界面设计。

For example, a news application can use one fragment to show a list of articles on the left 
and another fragment to display an article on the right - both fragments appear in one activity, side by side, 
and each fragment has its own set of lifecycle callback methods and handle their own user input events. 
Thus, instead of using one activity to select an article and another activity to read the article, 
the user can select an article and read it all within the same activity.

You should design each fragment as a modular and reusable activity component. 
That is, because each fragment defines its own layout and its own behavior with its own lifecycle callbacks, 
you can include one fragment in multiple activities, 
so you should design for reuse and avoid directly manipulating one fragment from another fragment. 
This is especially important because a modular fragment allows you to change your fragment combinations 
for different screen sizes. 
When designing your application to support both tablets and handsets, 
you can reuse your fragments in different layout configurations to optimize the user experience 
based on the available screen space. 
For example, on a handset, it might be necessary to separate fragments to provide a single-pane UI 
when more than one cannot fit within the same activity.

你应该将Fragment实现成模块化的可重用的Activity组件。
因为每一个Fragment读定义自己的布局、行为以及生命周期，你可以一个Fragment用到多个Activity中，
因此你应该面向重用来实现Fragment，而应避免通过一个Fragment直接去操作另一个Fragment。
这个非常重要，因为模块化的Frangement可以让你通过改变Fragment的组合去适应不同大小的屏幕。

For example - to continue with the news application example - the application 
can embed two fragments in Activity A, when running on a tablet-sized device. 
However, on a handset-sized screen, there's not enough room for both fragments, 
so Activity A includes only the fragment for the list of articles, 
and when the user selects an article, it starts Activity B, 
which includes the second fragment to read the article. 
Thus, the application supports both tablets and handsets by reusing fragments in different combinations.

For more information about designing your application with different fragment combinations 
for different screen configurations, see the guide to `Supporting Tablets and Handsets`.

更多的关于不同屏幕配置设计不同Fragment组合的细节请参考`Supporting Tablets and Handsets`。

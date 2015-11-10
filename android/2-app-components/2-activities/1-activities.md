
# Activities

An `Activity` is an application component that provides a screen 
with which users can interact in order to do something, such as dial the phone, 
take a photo, send an email, or view a map. 
Each activity is given a window in which to draw its user interface. 
The window typically fills the screen, but may be smaller than the screen and float on top of other windows.

Activity是提供屏幕显示与用户发生交互动作的应用组件，如拨打电话、拍照、发送邮件或查看地图。
每个Activity都会在指定窗口绘制用户界面。窗口通常是全屏的，但也可能比屏幕小悬浮在其它窗口之上。

An application usually consists of multiple activities that are loosely bound to each other. 
Typically, one activity in an application is specified as the "main" activity, 
which is presented to the user when launching the application for the first time. 
Each activity can then start another activity in order to perform different actions. 
Each time a new activity starts, the previous activity is stopped, 
but the system preserves the activity in a stack (the "back stack"). 
When a new activity starts, it is pushed onto the back stack and takes user focus. 
The back stack abides to the basic "last in, first out" stack mechanism, 
so, when the user is done with the current activity and presses the Back button, 
it is popped from the stack (and destroyed) and the previous activity resumes. 
(The back stack is discussed more in the `Tasks and Back Stack` document.)

When an activity is stopped because a new activity starts, 
it is notified of this change in state through the activity's lifecycle callback methods. 
There are several callback methods that an activity might receive, 
due to a change in its state - whether the system is creating it, stopping it, resuming it, 
or destroying it - and each callback provides you the opportunity 
to perform specific work that's appropriate to that state change. 
For instance, when stopped, your activity should release any large objects, 
such as network or database connections. 
When the activity resumes, you can reacquire the necessary resources and resume actions that were interrupted.
These state transitions are all part of the activity lifecycle.

The rest of this document discusses the basics of how to build and use an activity, 
including a complete discussion of how the activity lifecycle works, 
so you can properly manage the transition between various activity states.


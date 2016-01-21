
## Android输入系统

所涉及的源代码文件
- SystemServer.java
- InputManagerService.java
- WindowManagerService.java
- WindowState.java
- InputMonitor.java
- InputEventReceiver.java
- com_android_server_input_InputManagerService.cpp
- android_view_inputEventReceiver.cpp
- InputManager.cpp
- EventHub.cpp/.h
- InputDispatcher.cpp/.h
- InputTransport.cpp/.h

这部分讨论Android输入系统的工作原理，包括输入设备的管理、输入事件的加工方式以及派发流程。
因此主要探讨的对象有两个：输入设备和输入事件。触摸屏和键盘是Android最普遍的输入设备，当然
Android所支持的输入设备的种类不止这两个，鼠标、游戏手柄均在内建的支持之列。

当输入设备可用时，Linux内核会在/dev/input/下创建对应的名为event0~n或其他名称的设备节点。
而当输入设备不可用时，则会将对应的节点删除。在用户空间可以通过ioctl的方式从这些设备节点
中获取其对应的输入设备的类型、厂商、描述等信息。

当用户操作输入设备时，Linux内核接收到相应的硬件中断，然后将中断加工成原始的输入事件数据
并写入其对应的设备节点中，在用户空间可以通过read函数将事件数据读出。Android输入系统的工作
原理概况来说，就是监控/dev/input/下的所有设备节点，当某个设备节点有数据可读时，将数据读出
并进行一系列的翻译加工，然后在所有的窗口中寻找合适的事件接收者，并派发给它。

Android系统提供了getevent与sendevent两个工具供开发者从设备节点中直接读取输入事件或写入
输入事件。getevent监听输入设备节点的内容，当输入事件被写入节点时，getevent会将其读出并打印
在屏幕上。由于getevent不会对事件数据做任何加工，因此其输出的内容是有内核提供的最原始的事件。
使用选项-t可以打印事件的事件戳，如下面的例子。注意其输出的是十六进制格式，每条数据有5项信息：
产生事件的时间戳、事件类型、事件代码、以及事件值。一个原始事件所包含的信息量是比较有限的。
而在Android中所使用的某些输入事件，入触摸屏的点击/滑动，其中包含了很多的信息，如XY坐标、触摸屏
索引等，其实是输入系统整合了多个原始事件后的结果。这个过程将在后面详细探讨。
```shell
$ adb shell getevent --help
$ adb shell getevent [-option] [device_path]
$ adb shell getevent -t
add device 1: /dev/input/event3
  name:     "edc"
add device 2: /dev/input/event2
  name:     "walkmotion"
add device 3: /dev/input/event1
  name:     "qpnp_pon"
could not get driver version for /dev/input/mice, Not a typewriter
add device 4: /dev/input/event4
  name:     "gpio-keys"
could not get driver version for /dev/input/mouse0, Not a typewriter
add device 5: /dev/input/event0
  name:     "synaptics_dsx"
[   10256.777054] /dev/input/event2: 0003 0000 00000002
[   10256.777054] /dev/input/event2: 0000 0000 00000000
[   10256.855925] /dev/input/event2: 0003 0000 00000001
[   10256.855925] /dev/input/event2: 0000 0000 00000000
```

输入设备的节点不仅在用户空间可以读，而且是可写的，因此可以将原始事件写入节点中，从而实现模拟
用户输入的功能。sendevent工具的作用正是如此，它的输入参数与getevent的输出是对应的，只不过
sendevent的参数是十进制格式。输入设备节点在用户空间可读可写的特性为自动化测试提供了便利。
```shell
$ adb shell sendevent [device_path] [event_type] [event_code] [event_value]
```

上面讲述了输入事件的源头是位于/dev/input/下的设备节点，而输入系统的终点是由WMS管理的某个
窗口。最初的输入事件为内核生成的原始事件，而最终交付给窗口的则是KeyEvent或MotionEvent对象。
因此Android输入系统的主要工作是读取设备节点的原始事件，将其加工封装，然后派发给一个特定的
窗口以及窗口中的控件。这个过程由InputManagerService（简称为IMS）系统服务为核心的多个参与
者共同完成。输入系统的总体流程和参与者如下所示。

```
[Linux Kernel] --> [/dev/input/event0~n] -->

            [InputManageService]                   [WMS]
    ----------------------------------------     ----------                        [View 1]
--> [EventHub][InputReader][InputDispatcher] --> [Window 1] --> [ViewRootImpl] --> [View 2]
                  /|            /|                  ...                              ...
    [InputReaderPolicy][InputDispatcherPolicy]   [Window n]                        [View n]
```

Linux内核接受输入设备的中断，并将原始事件的数据写入设备节点中。设备节点作为内核
与IMS的桥梁，它将原始事件的数据暴露给用户空间以便IMS从中读取事件。其中EventHub
直接访问所有的设备节点，正如其名字所描述的，它通过名为getEvents的函数将所有输入
系统相关的待处理的底层事件返回给使用者，这些事件包括原始输入事件、设备节点的增减等。

InputReader是IMS中关键组件之一，它运行在独立的线程中，负责管理输入设备的列表与配置，
以及进行输入事件的加工处理。它通过线程不断地调用getEvents从EventHub中取出事件并处理，
并交给InputDispatcher进行派发。InputReaderPolicy为事件的加工处理提供一些策略配置，
例如键盘布局信息等。

InputDispatcher是IMS中的另一个关键组件，它也运行在一个独立的线程中。InputDispatcher
保存了来自WMS的所有窗口信息，当它收到InputReader的输入事件后，会寻找合适的窗口并将事件
派发给此窗口。InputDispatcherPolicy为InputDispatcher的派发过程提供策略控制。例如截取
某些特定的输入事件用作特殊用途，或者阻止将某些事件派发给目标窗口。一个典型的例子就是
HOME键被InputDispatcherPolicy截取到PhoneWindowManager中进行处理，并阻止窗口收到HOME
键的按键事件。


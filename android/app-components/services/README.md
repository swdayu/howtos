
# Services
- [The Basics](./basics.md)
- [Declaring a Service in the manifest](./manifest.md)
- [Creating a Service](./service.md)
- [Sending Notifications to the User](./notification.md)
- [Running a Service in the Foreground](./foreground.md)
- [Managing the Lifecycle of a Service](./lifecycle.md)

> A Service is an application component that can perform long-running operations in the background 
and does not provide a user interface. 
Another application component can start a service and it will continue to run in the background 
even if the user switches to another application. 
Additionally, a component can bind to a service to interact with it and even perform interprocess communication (IPC). 
For example, a service might handle network transactions, play music, perform file I/O, 
or interact with a content provider, all from the background.

> A service can essentially take two forms:
> - **Started**: A service is "started" when an application component (such as an activity) 
starts it by calling `startService()`. 
Once started, a service can run in the background indefinitely, even if the component that started it is destroyed. 
Usually, a started service performs a single operation and does not return a result to the caller. 
For example, it might download or upload a file over the network. 
When the operation is done, the service should stop itself.
> - **Bound**: A service is "bound" when an application component binds to it by calling `bindService()`. 
A bound service offers a client-server interface that allows components to interact with the service, 
send requests, get results, and even do so across processes with interprocess communication (IPC). 
A bound service runs only as long as another application component is bound to it. 
Multiple components can bind to the service at once, but when all of them unbind, the service is destroyed. 

> Although this documentation generally discusses these two types of services separately, your service can work both ways—it can be started (to run indefinitely) and also allow binding. It's simply a matter of whether you implement a couple callback methods: `onStartCommand()` to allow components to start it and `onBind()` to allow binding.

> Regardless of whether your application is started, bound, or both, any application component can use the service (even from a separate application), in the same way that any component can use an activity - by starting it with an Intent. However, you can declare the service as private, in the manifest file, and block access from other applications. This is discussed more in the section about *Declaring the service in the manifest*.

> **Caution**: A service runs in the main thread of its hosting process - the service does not create its own thread and does not run in a separate process (unless you specify otherwise). This means that, if your service is going to do any CPU intensive work or blocking operations (such as MP3 playback or networking), you should create a new thread within the service to do that work. By using a separate thread, you will reduce the risk of *Application Not Responding (ANR)* errors and the application's main thread can remain dedicated to user interaction with your activities.

服务是没有用户界面的可以长时间在后台运行的应用组件。
其他的应用组件可以启动服务使其在后台持续运行，不管用户是否已经切换到其他的应用上。
其他组件也可以绑定到一个服务与其交互，甚至执行进程间通信。
例如服务可以在后台执行网络事务、播放音乐、执行文件操作、或与内容提供者交互。

服务一般有两种形式：
- 启动的服务：它是其他组件（例如Activity）调用`startService()`启动的服务。
  服务一旦启动就会持续执行下去，即使启动它的组件已经销毁了。
  一般，启动的服务会执行一个单一的操作，并且不会将结果返回给调用者。
  例如下载一个文件或上传文件到网络上。当对应的操作执行完，服务将自动停止。
- 绑定的服务：它是其他组件调用`bindService()`绑定的服务。
  绑定的服务允许其他组件与其进行交互，例如发送请求、获取结果、或执行进程间通信。
  绑定的服务的生存期和与它交互的组件的生存期相同。
  多个组件可以绑定同一个服务，当这些组件解绑之后，服务就会终止运行。

一个服务可以同时支持被其他组件启动或绑定，只需要提供对应的回调函数`onStartCommand()`和`onBind()`既可。
其他组件使用服务的方式与使用Activity的方式是相同的，都是使用Intent进行组件之间的沟通。
但是可以在服务的Menifest文件中将服务声明为私有服务，不允许其他应用对其进行访问。

注意的是，服务将运行在当前进程的主线程中，服务不会创建自己的线程、也不会运行在隔离的进程中（除非你明确指定）。
因此，如果服务执行的是CPU繁忙的或阻塞的操作（例如MP3播放或网络操作），应该创建一个新的线程让服务在新线程中工作。
这样可以避免应用没有响应的错误，应用的主线程也可以保持活动持续响应用户的交互。

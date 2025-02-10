
# 简介

创建服务，需要从Service或其子类继承，然后实现必要的Service生存期回调函数。
几个重要的回调函数是：onStartCommand()会在其他组件startService()时调用，
start的服务会持续执行，直到服务自己调用stopSelf()或其他组件调用stopService()结束服务，
如果只希望其他组件来bindService()，则不需要定义这个回调函数；
onBind()会在其他组件bindService()时调用，该回调函数需要返回用于访问该服务的IBinder接口，
这个函数必须要实现，如果不希望其他组件来绑定应该返回null，绑定的服务在第一个组件bindService()时开始执行，
直到最后一个组件unbindService()解绑时系统自动销毁它。
onCreate()会在服务创建时在onStartCommand()或onBind()之前调用，如果服务已经在运行不会调用这个函数；
onDestroy()会在服务销毁时调用，应该在该回调函数中清除使用的资源，这是服务接收到的最后一个回调函数。

Android系统只有在内存不足，并且当获取了用户焦点的Activity需要系统资源时，才会强制停止服务。
声明在前台运行的服务优先级最高，基本不会被系统杀掉；其次是获取了用户焦点的Activity绑定的服务；
否则启动的服务执行时间越长，就越容易被放到后台任务列表低优先级位置，也越容易被系统杀掉。
当系统杀掉服务后，依据onStartCommand()的返回值，系统会尽快在系统资源可用时重新启动服务。
实现的服务应该能够优雅的处理被系统杀掉并重新启动的情况。

使用服务还是线程：服务简单的说是一个可以在后台运行的组件，即使与它交互的组件不再来访问了，
它还可能在后台运行，如果这是你需要的就应该使用服务；如果仅需在用户交互时在主线程外执行一项任务，
可能你需要的就是创建一个新线程去执行这项任务，然后终止这个线程。
可以使用传统的Thread类，也可以考虑AsyncTask或HandlerThread。
另外注意的是服务默认会在应用程序主线程上运行，如果服务执行密集型或阻塞式操作，仍然需要在服务中创建新的线程。

# Manifest配置文件

像Activity和其他组件一样，需要在Manifest文件中声明所有定义的服务。
声明一个服务只需要在<application>父元素下添加<service>子元素，例如：
```xml
<service android:name=".ExampleService"
  android:enabled=["true"|"false"]
  android:exported=["true"|"false"] #false: stop other apps use your service even with explicit intent
  android:isolatedProcess=["true"|"false"]
  android:permission="string" #the premission an entity must have to start or bind the service
  android:process="string"    #the name of a process that you want the service to run
  android:label="string_resource"
  android:icon="drawable_resource" />
```
为了你应用的安全性，应该只使用explicit intent启动或绑定你的服务，不要为服务定义indent过滤条件。
>  If it's critical that you allow for some amount of ambiguity as to which service starts, 
you can supply intent filters for your services and exclude the component name from the Intent, 
but you then must set the package for the intent with setPackage(), 
which provides sufficient disambiguation for the target service.

# Started Service

用一个Intent调用startService()可以启动服务，Intent用于指定对应的服务及要传递的数据。
服务会在onStartCommand()回调函数中接收到这个Intent。

一般情况下，可以从两个类继承来创建启动的服务。第一个类是Service：它是所有服务的子类，
从这个类继承要注意的一点是，应该创建新线程去执行密集型或阻塞式任务；
第二个类是IntentService：它使用工作线程依次处理收到的所有start请求，
如果你的服务不需要同时处理多个请求，从这个类继承是最好的选择，
你只需要实现onHandleIntent()回调函数来处理每一个请求即可。

IntentService已经实现的功能：创建一个工作线程在主线程外处理onStartCommand()接收到的所有Intent；
创建一个工作队列存储接收到的Intent，然后依次取出Intent回调子类实现的onHandleIntent()；
当所有start请求都处理完毕时自动终止服务；提供返回null的默认onBind()回调函数实现；
提供默认的onStartCommand()回调函数实现，它将Intent发送到工作队列，然后传递到onHandleIntent()回调函数中。
因此从这个类继承，只需实现onHandleIntent()回调函数。

回调函数onStartCommand()会返回一个整数，它决定系统杀死服务后的行为，返回的值可以是：

START_NOT_STICKY，如果系统在onStartCommand()之后将服务进程杀死，该服务不会由系统重新创建，
只有新的startService()请求到来时才再次创建服务，例如使用定时器不断startService()从服务获取数据，
该过程系统可能将服务杀死，当下次获取更多数据时，startService()会重新创建服务；
> This is the safest option to avoid running your service when not necessary and 
  when your application can simply restart any unfinished jobs.

START_REDELIVER_INTENT，如果系统在onStartCommand()之后将服务进程杀死，并且还有没处理完的Intents，
则系统会安排时间重新创建这个服务，并将这些Intents传递到onStartCommand()，
如果杀死服务前所有请求都处理完了，系统不会重新创建这个服务。
> This is suitable for services that are actively performing a job that should be immediately resumed, 
  such as downloading a file.

START_STICKY，如果系统在onStartCommand()之后将服务进程杀死，该服务会在适当的时候由系统重新创建，
并使用null Intent调用onStartCommand()让服务回到started状态，但系统不会重新传递服务杀死时没有处理完的Intent，
另外新的startService()请求也会触发服务重新创建；
> This is suitable for media players (or similar services) that are not executing commands, 
  but running indefinitely and waiting for a job.

使用Intent启动服务，例如：
```java
Intent intent = new Intent(this, ExampleService.class);
startService(intent);
```
如果希望服务返回一个结果，可以getBroadcast()并为广播创建PendingIntent去启动服务，服务可以使用广播将结果传回。
多次startService()会导致多次调用服务的onStartCommand()，然而只需要执行一次stopSelf()或stopService()就可以终止服务。
Started服务必须自己负责终止，即使允许Bound，只要onStartCommand()接收到了Start请求就必须自己将服务终止。
如果多线程同时处理onStartCommand()收到的请求，可以使用stopSelf(startId)来终止服务，
它可以避免终止服务时接收的请求还没处理完的情况。
调用stopSelf(startId)后，系统只会在startId与最新的请求Id相等时才将服务终止掉。

# 服务通知

服务启动后，通过[Toast Notification][1]或[Status Bar Notification][2]可以给用户发送事件消息。
Toast通知是在当前窗口之上显示一会然后自动消失的通知；
而状态栏通知则会在状态栏显示图标和消息，用户还可以选择执行相应的操作。
例如当服务下载完文件后，可以发送一个状态栏通知，用户可以点击启动一个Activity查看下载的文件。

[1]: http://developer.android.com/guide/topics/ui/notifiers/toasts.html
[2]: http://developer.android.com/guide/topics/ui/notifiers/notifications.html

服务可以在前台运行，前台运行的服务必须提供状态栏通知，它会有"Ongoing"头部，
表示这个通知不能清除，除非服务终止了或从前台移除了。
例如播放器使用服务播放音乐，这个服务应该设置成前台运行，状态栏中的通知可能显示当前播放的音乐，
并可以让用户启动Activity打开播放器。调用startForeground()函数即可以让服务进入前台，它需要两个参数：
一个不为0的唯一标识通知的整数；以及对应的Notification对象。将服务从前台移除可以调用stopForeground()，
它带有一个布尔参数表示是否也将状态栏通知移除，这个函数不会终止服务。
然而如果终止一个在前台运行的服务，对应的状态栏通知也会被移除。

# 生存周期

![Service Lifecycle](../assets/service_lifecycle.png)

Start和Bind服务两条路径不是完全隔离的。你可以绑定一个已经startService()的服务。
这种情况下，stopService()或stopSelf()不会真正将服务终止，直到所有绑定的Client都解绑了。

Started服务生存期流程：
```
1. Start Request 1 -> onCreate() -> onStartCommand()
2. Start Request 2 -> onStartCommand()
3. System Kill Service -> onDestory()
4. System Recreate Service -> onCreate() -> onStartCommand()
5. Stop Service -> onDestory()
```

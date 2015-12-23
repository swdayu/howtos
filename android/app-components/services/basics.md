
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



# 绑定的服务

绑定服务的应用组件首先需要实现一个ServiceConnection类，用于监控与服务的连接。
然后使用这个类的对象调用bindService()绑定到对应的服务，bindService()会立即返回，
但系统会建立与服务的连接，并回调ServiceConnection的onServiceConnected()函数，
将服务的访问接口IBinder对象传递给它。该过程中绑定服务的应用组件称为Client，服务称为Server。
Client得到IBinder对象后，就可以通过这个接口对象访问绑定的服务。

多个Client可以同时连接到一个服务，但系统只会调用一次onBind()，得到IBinder对象后，
后面的请求直接使用这个对象，不再回调onBind()函数。而当最后一个Client进行解绑之后，
系统会自动将服务销毁（除非服务还被其他Client调用startService()启动了）。

如果定义的服务既可以Start也可以Bind，绑定服务的所有Client都解绑之后，只要服务被Start系统就不会将服务销毁，
Started的服务需要调用stopSelf()或stopService()来终止。
但如果没有完全解绑的情况下就调用stopSelf()或stopService()会怎样？
同时允许Start和Bind在有些情况下是需要的，例如：
> For example, a music player might find it useful to allow its service to run indefinitely and also provide binding. 
  This way, an activity can start the service to play some music and the music continues to play 
  even if the user leaves the application. Then, when the user returns to the application, 
  the activity can bind to the service to regain control of playback.

当创建用于绑定的服务时，必须在onBind()回调函数中返回IBinder对象，有三种方法来实现这个接口。

从Binder类继承：如果你的服务是私有的，只有你自己的应用使用，且该服务与Client运行在同一个进程中（一般都是这样），
应该使用这种方法来创建你的接口。Client得到接口对象后，可以直接访问接口对象甚至服务的public方法。
唯一不使用该方法的原因是服务需要被其他应用访问或服务运行在隔离的进程中。

使用Messenger：如果你的服务需要在不同的进程中运行，可以使用Messenger创建服务的接口。
以这种方式，服务需要定义一个Handler来处理不同类型的Message对象，Handler是Messenger的核心，
这样Client可以通过Message对象发送命令给服务。另外Client也可以定义Messenger让服务发送消息给自己。
这是最简单的执行进程间通信（IPC）的方法，因为Messenger会将所有请求缓存到同一个线程队列中，让你无需考虑服务的线程安全问题。

使用AIDL：Messenger其实是基于AIDL（Android接口定义语言）实现的，它将所有Client请求都缓存在同一个线程队列中，
使得服务可以在Handler中依次处理每个请求，不需要考虑线程安全性。然而如果你的服务希望同时处理多个请求，则需要使用AIDL。
这种情况下，你的服务必须处理多线程问题，使得服务是线程安全的。使用这种方法，首先需要创建.aidl文件定义对应的接口；
Android SDK工具会解析这个文件并生成一个包含这些接口并处理进程间通信的抽象类；
在你的服务中，需要从这个抽象类继承并实现这些接口。
> AIDL (Android Interface Definition Language) performs all the work to decompose objects into primitives 
  that the operating system can understand and marshall them across processes to perform IPC.
  
# 从Binder继承

首先，需要在服务中实现一个Binder子类，该类或者包含Client能够调用的public方法，
或者返回包含对应public方法的当前Service对象或Service中的其他类对象；
然后，在onBind()回调函数中返回该对象，Client会在onServiceConnected()回调函数中获取到该对象；
最后，Client使用对象提供的public方法访问绑定的服务。

服务和Client必须在同一进程的原因是，Client会直接将IBinder对象转换成实际的类型从而调用它的方法。
一个具体的示例如下。注意在下面的例子中，服务在onStop()函数中解绑，但在实际情况中Client应该选择合适的时间点。
```java
// Service
public class MyService extends Service {
  public class MyBinder extends Binder {
    MyService getService() { return MyService.this; }
  }

  public int callMethodForClients() {
    return 0;
  }

  private final IBinder mBinder = new MyBinder();

  @Override
  public IBinder onBind(Intent intent) {
    return mBinder;
  }
}

// Client
public class ClientActivity extends Activity {
  private ServiceConnection mConnection = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName className, IBinder service) {
      MyBinder binder = (MyBinder)service;
      mService = binder.getService();
      mBound = true;
    }

    @Override
    public void onServiceDisconnected(ComponentName arg0) {
      mBound = false;
    }
  }

  @Override
  protected void onStart() {
    super.onStart();
    Intent intent = new Intent(this, MyService.class);
    bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
  }

  public void onButtonClick(View v) {
    if (mBound) {
      int num = mService.callMethodForClients();
      Log.i(TAG, "number: " + num);
    }
  }

  @Override
  protected void onStop() {
    super.onStop();
    if (mBound) {
      unbindService(mConnection);
      mBound = false;
    }
  }
}
```


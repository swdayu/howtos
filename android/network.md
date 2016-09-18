
# Android Network
- https://developer.android.com/training/basics/network-ops/connecting.html
- https://developer.android.com/training/basics/network-ops/managing.html
- https://developer.android.com/reference/java/net/HttpURLConnection.html

> Most network-connected Android apps use HTTP to send and receive data   
> HttpURLConneciton supports HTTPs, streaming uploads and downloads, configurable timeouts, IPV6, and connection pooling

Permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

```java
// the device may be out of range of a network, or the user may have disabled both wifi and mobile data access  
public class HttpExampleActivity extends Activity {
  public boolean isNetworkAvailable() {
    ConnectivityManager mgr = (ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
    NetworkInfo info = mgr.getActiveNetworkInfo();
    if (info != null && info.isConnected()) {
      return true;
    }
    return false;
  }
  
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
  }
}
```

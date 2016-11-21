
```
Settings | Bluetooth Dashboard Tile Summary 的更新
* com.android.settings.dashboard.DashboardSummary.onStart()
* com.android.settings.dashboard.SummaryLoader$Worker.handleMessage(SummaryLoader.java:215)
* com.android.settings.dashboard.SummaryLoader.-wrap1(SummaryLoader.java)
* com.android.settings.dashboard.SummaryLoader.setListeningW(SummaryLoader.java:175)
* com.android.settings.bluetooth.BluetoothSettings$SummaryProvider.setListening(BluetoothSettings.java:689)
* com.android.settings.bluetooth.BluetoothSettings$SummaryProvider.getSummary(BluetoothSettings.java:700)
* 其中 BluetoothSettings.setListening() 会从 adp.isEnabled()/getConnectionState() 获取状态保存到 mEnabled/mConnected
* BluetoothAdapter.getConnectionState() 会经 AdapterService 到 AdapterProperties.getConnectionState() 获取状态
* AdapterProperties 将状态保存在 mConnectionState 中，而通过 AdapterProperties.setConnectionState(state) 设置状态
* 最终是通过 AdapterProperties.sendConnectionStateChange(BluetoothDevice, int profile, state, prevState) 设置 profile 的状态
* 因此要么 profile 自己调用这个函数进行 profile 状态更新，或通过调用以下两个函数间接将状态更新到 AdapterProperties:
* 一是调用 AdapterService.onProfileConnectionStateChanged(Bluetooth, int profile, state, prevState)
* 二是调用 ProfileService.notifyProfileConnectionStateChanged(Bluetooth, int profile, state, prevState)
```

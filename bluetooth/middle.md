
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

BT Connection State
* com.android.settingslib.bluetooth.BluetoothEventManager$1.onReceive(BluetoothEventManager.java:174)
* com.android.settingslib.bluetooth.LocalBluetoothProfileManager$StateChangedHandler.onReceive(321)
* com.android.settingslib.bluetooth.CachedBluetoothDevice.refresh(CachedBluetoothDevice.java:655)
* com.android.settingslib.bluetooth.CachedBluetoothDevice.dispatchAttributesChanged(CachedBluetoothDevice.java:975)
* com.android.settings.bluetooth.BluetoothDevicePreference.onDeviceAttributesChanged(BluetoothDevicePreference.java:205)
* com.android.settingslib.bluetooth.CachedBluetoothDevice.getConnectionSummary(CachedBluetoothDevice.java:1424)

BLE Profile Connection State
* XxxProfile receives EVENT_CLIENT_CONNECTED/DISCONNECTED or after connectXxx/disconnectXxx()
* GattServerProfile.callbackMessage(msg, dev, result)
* GattServerProfile.executeCallback(msg, dev, result)
* BluetoothGattManager.receiveMessage(msg, dev, result)
* CachedBluetoothDevice.onGattDeviceConnectionStateChanged(msg, dev, result, this)
* CachedBluetoothDevice.refreshGatt(state)
* CachedBluetoothDevice.dispatchGattAttributesChanged(state)
* BluetoothDevicePreference.onGattDeviceAttributesChanged(state)
* BluetoothDevicePreference.setSummary(summary according to state)
* 其中每个 BLE profile (XxxProfile) 都是 GattServerProfile 的子类，每个 BLE 设备都对应一个 BluetoothGattManager
* GattServerProfile 保存了 BluetoothGattManager 的一个列表，当某个 BLE 设备状态发生变化时从列表中找对应的 BluetoothGattManager 回调
```

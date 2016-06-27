
**Keywords**
```c
## HFP

1. SCO State:  "AG SCO State|AG_AUDIO|setBluetoothScoOn"
2. AT Command: "bta_ag_hfp_result|HFP AT cmd"

[Connection]
L2CA_SetDesireRole // set allow role switch or not when create connection
btm_sec_disconnected
ACL_DISCONNECTED
L2CA_DisconnectRsp
```

**disable dun service**
```c
<service
  android:process="@string/process"
  android:name=".dun.BluetoothDunService"          ## vendor/qcom/opensource/bluetooth/src/org/codeaurora/bluetooth/dun/
  android:enabled="@bool/profile_supported_dun" >  ## vendor/qcom/opensource/bluetooth/res/values/config.xml
  <intent-filter>
    <action android:name="android.bluetooth.IBluetoothDun" />
  </intent-filter>
</service>
```

**BLE鼠标测试**
```c
ELECOM M-BT11BB Series 鼠标
1. 搜索配对连接，鼠标不摇动可以成功连上，摇动鼠标则加快连接
2. 连接成功后断连，再点击手机上的鼠标去连接，需要摇动鼠标才能连上，如果不摇动连接会失败
3. 断连后，如果只摇动鼠标，不主动选择手机上的鼠标去连，也会连接失败（BLE的连接需要手机端作为initiator去做initiating）
```

**LINE注册**
```c
SQ平板上使用LINE时的发现：
1. 需要连上WIFI以及插入SIM卡后才能进行注册
2. 注册LINE首先要验证电话号码，而LINE默认使用电话语音进行验证码验证
3. 该平板只能收发短信不能拨打电话，如果要使用当前SIM卡电话进行注册，电话验证码就收不到
4. 一种方法是，在输入验证码的界面上点"?"图标的帮助，在帮助里找到短信验证码，填入当前SIM电话号码就可以获取到短信验证码
5. 返回刚才的验证码输入界面，输入收到的短信验证码，即可验证成功
6. 验证完电话号码后，LINE账号需要你使用电子邮件来注册，如果这个电子邮件你原来注册过，原来的账号会清除
```

**Hangouts测试**
```c
1. 使用Hangouts拨打IP电话，响铃声音可以传到蓝牙耳机，但通话语音需要插入SIM卡才能传到蓝牙耳机
2. 但移除SIM后，Hangouts的通话语音又可以传到蓝牙耳机???
```

**CTS**

Android M: BLE搜索要收到设备需要把GPS打开；

**BLE Profile**

Guest User下收不到手表的FMP通知，也不能同步时间等，需要切换到Owne User；

**自动重连**
- 手机与BLE设备连接之后，先关闭在打开对方设备蓝牙，对方设备会自动进行重连
- 手机与BLE设备连接之后，手机先关闭再打开蓝牙，手机会自动重连这个设备，
  如果对方设备已经处于不可连接状态（当手机关掉蓝牙连接会断掉，对方设备可能将也会将蓝牙关闭导致不可连），
  需要将它设置到可连接状态之后连接才能建立成功

**文件位置**
```shell
$ adb shell cat /etc/bluetooth/bt_stack.conf | less
$ adb shell cat /system/etc/bluetooth/bt_stack.conf | less

/system/etc/bluetooth/bt_stack.conf
/system/lib/hw/bluetooth.default.so
```

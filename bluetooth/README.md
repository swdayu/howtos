
## BT Power ON/OFF
```c
BluetoothManagerService
BT_VND_OP_POWER_CTRL
```

## Handsfree Profile (HFP)

Steps to register and using Line app on SQ tablet 
> 需要连上WIFI以及插入SIM卡后才能进行注册  
> 注册LINE首先要验证电话号码，而LINE默认使用电话语音进行验证码验证  
> 该平板只能收发短信不能拨打电话，如果要使用当前SIM卡电话进行注册，电话验证码就收不到  
> 一种方法是，在输入验证码的界面上点"?"图标的帮助，在帮助里找到短信验证码，填入当前SIM电话号码就可以获取到短信验证码  
> 返回刚才的验证码输入界面，输入收到的短信验证码，即可验证成功  
> 验证完电话号码后，LINE账号需要你使用电子邮件来注册，如果这个电子邮件你原来注册过，原来的账号会清除  

ATA from bt headset
```java
[com_android_bluetooth_hfp]answer_call_callback
[HeadsetStateMachine]onAnswerCall 
[HeadsetStateMachine]Connected/AudioOn.processMessage EVENT_TYPE_ANSWER_CALL
[HeadsetStateMachine]processAnswerCall
[BluetoothPhoneServiceImpl]answerCall
[CallsManager]answerCall
```

## Bluetooth Low Energy (BLE)

BLE scanning (device searching)
> if using startScan() to perform ble device searching, the result scan results can be received only when GPS is ON  
> batch scan doesn't have this limitation  

Guest user limitation when using ble profiles
> guest user cannot receive FMP notification and the time is also not synced using TIP  
> it is needed to switch to owner user  

ELECOM M-BT11BB Series BLE Mouse
> 搜索配对连接，鼠标不摇动可以成功连上，摇动鼠标则加快连接  
> 连接后在手机上主动断开，再点击手机上的鼠标去连接，需要摇动鼠标才能连上，如果不摇动连接会失败  
> 如果主动断开后只摇动鼠标而不主动选择手机上的鼠标去连接，也会连接失败（因为主动断开的情况下，手机不会发起背景连接）  


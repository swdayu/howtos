
Bluetooth ON/OFF
```c
* BluetoothManagerService|bt_vendor|BT_VND_OP_POWER_CTRL
* BluetoothAdapter.STATE_OFF (10) -> STATE_BLE_TURNING_ON (14) -> (BT_VND_OP_POWER_CTRL: On) ->
* STATE_BLE_ON (15) -> STATE_TURNING_ON (11) -> STATE_ON (12)
* BluetoothAdapter.STATE_ON (12) -> STATE_TURNING_OFF (13) -> STATE_BLE_ON (15) ->
* STATE_BLE_TURNING_OFF (16) -> (BT_VND_OP_POWER_CTRL: Off) -> STATE_OFF (10)
---
* Adapter状态变成STATE_BLE_ON(15)之后会触发 AdapterState.BleOnState.BLE_TURN_OFF 调用 disable() 真正关闭蓝牙：
* notifyAdapterStateChange(BluetoothAdapter.STATE_BLE_TURNING_OFF)
* adapterService.disableNative() -> bluetooth.c$disable() -> stack_manager.c$shut_down_stack_async() ->
* stack_manager.c$event_shut_down_stack(context)
* 1. btif_disable_bluetooth();
* 2. module_shut_down(get_module(BTIF_CONFIG_MODULE));
* 3. future_await(local_hack_future);
* 4. module_shut_down(get_module(CONTROLLER_MODULE));
* 5. stack_manager.c$event_signal_stack_down(context) -> HAL_CBACK(bt_hal_cbacks, adapter_state_changed_cb, BT_STATE_OFF)
* 关蓝牙主要函数btif_disable_bluetooth()，该函数是异步的，发送消息后会返回然后执行到步骤3等待蓝牙关闭semaphore
* 该semaphore会在蓝牙真正关闭后，在函数btif_disable_bluetooth_evt()中触发，首先看函数btif_disable_bluetooth()执行的内容：
* btif_dm_on_disable(); btif_sock_cleanup(); btif_pan_cleanup(); BTA_DisableBluetooth();真正重要的是最后一个函数：
* 首先，BTA_DisableBluetooth()给 btu_bta_msg_queue 发送 BTA_DM_API_DISABLE_EVT 消息
* 该消息队列处理函数 btu_bta_msg_ready 从中取出消息，按照消息的分类传给对应消息类别的处理函数，如下
* msg_group = p_msg->event>>8; (*bta_sys_cb.reg[msg_group]->evt_hdlr)(p_msg);　消息的类别由高8位定义
* 消息BTA_DM_API_DISABLE_EVT是 BTA_ID_BM 类别中的第１个消息（从0开始数起），该分类的处理函数是 bta_dm_sm_execute
* 该函数会将消息分派给真正的消息处理函数：msg_id = p_msg->event&0xff; (*bta_dm_action[msg_id])( (tBTA_DM_MSG*) p_msg);
* 消息ID有低8位决定，BTA_DM_API_DISABLE_EVT是 BTA_ID_BM 的第1个消息，会调用第1个处理函数　bta_dm_disable 进行处理
* 最终触发调用 bta_dm_cb.p_sec_cback(BTA_DM_DISABLE_EVT, NULL) => btif_dm_upstreams_evt，然后执行核心流程关闭蓝牙芯片:
* btif_disable_bluetooth_evt()
* 1. bte_main_enable_lpm(FALSE)
* 2. bte_main_disable() => module_shut_down(get_module(HCI_MODULE/BTSNOOP_MODULE)); BTU_ShutDown();
* 3. future_ready(stack_manager_get_hack_future(), FUTURE_SUCCESS)
* 蓝牙芯片在第２步关闭 HCI 模块是关闭: module_shut_down(get_module(HCI_MODULEHCI)) => hci_module.shut_down() =>
* vendor->send_command(BT_VND_OP_POWER_CTRL, BT_VND_PWR_OFF) => bt_vendor_qcom.c$op(CTRL, OFF)
* 第３步释放semaphore，触发semaphore等待函数 future_await(local_hack_future) 返回，至此蓝牙关闭成功
---
* 给 btu_bta_msg_queue 发送消息到最后触发 btu_bta_msg_ready 取出消息的流程如下：
```

## HFP (handsfree profile)

Steps to register and using Line app on SQ tablet 
> 需要连上WIFI以及插入SIM卡后才能进行注册  
> 注册LINE首先要验证电话号码，而LINE默认使用电话语音进行验证码验证  
> 该平板只能收发短信不能拨打电话，如果要使用当前SIM卡电话进行注册，电话验证码就收不到  
> 一种方法是，在输入验证码的界面上点"?"图标的帮助，在帮助里找到短信验证码，填入当前SIM电话号码就可以获取到短信验证码  
> 返回刚才的验证码输入界面，输入收到的短信验证码，即可验证成功  
> 验证完电话号码后，LINE账号需要你使用电子邮件来注册，如果这个电子邮件你原来注册过，原来的账号会清除  

ATA from bt headset
> [com_android_bluetooth_hfp]answer_call_callback  
> [HeadsetStateMachine]onAnswerCall   
> [HeadsetStateMachine]Connected/AudioOn.processMessage EVENT_TYPE_ANSWER_CALL  
> [HeadsetStateMachine]processAnswerCall  
> [BluetoothPhoneServiceImpl]answerCall  
> [CallsManager]answerCall  

## BLE (bluetooth low energy)

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


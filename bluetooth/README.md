
```
* BARB - Bluetooth Architectural Review Board
* /system/build.prop
* /data/misc/bluetooth/.bt_nv.bin
* /data/misc/bluetooth/logs/btsnoop_hci.log
* /data/misc/bluedroid/bt_config.conf
* /data/misc/bluedroid/bt_fw_version.txt
* /bt_firmware/image/btnv32.bin
* /etc/bluetooth/bt_stack.conf
---
* 灭屏和点亮 "REC@0   : screen_toggled: 0|REC@0   : screen_toggled: 1"
* BluetoothSettingsBatchPlugin: call onRestore on
* DataProtectionService: RestoreExecutor onRestore() retVal :0
* 查看鼠标键盘按键：adb shell getevent -t -l | grep "EV_KEY"
---
BT profiles
* device/qcom/common/device/overlay/packages/apps/Bluetooth/res/values/config.xml
* vendor/qcom/opensource/bluetooth/res/values/config.xml 
* packages/apps/Bluetooth/res/values/config.xml
* device/qcom/common/rootdir/etc/init.qcom.rc (services define)
```

Android-O BT ON/OFF
```
BD_ADDR is set to BT controller when firmware patch download:
* hci_module_start_up()
* message_loop_run()
* hci_initialize()
* btHci->initialize(callbacks)
* BluetoothHci::initialize()
* DataHandler::Init(TYPE_BT, ...)
* DataHandler::Open()
CASE#1 {
* UartController::Init()
* PatchDLManager.PerformChipInit()
* BluetoothAddress::GetLocalAddress(vnd_local_bd_addr_***)
* PatchDLManager::SocInit()
* PatchDLManager::DownloadTlvFile()
* PatchDLManager::GetTlvFile() replace the BD Address before download:
*   if (ptlv_header->tlv_type == TLV_TYPE_BT_NVM) {
*     /* Write BD Address */
*     if (nvm_ptr->tag_id == TAG_NUM_2) { memcpy(nvm_byte_ptr, vnd_local_bd_addr_***, 6);
CASE#2 {
* MctController::Init()
* NvmTagsManager::SocInit()
* BluetoothAddress::GetLocalAddress(vnd_local_bd_addr_***)
* NvmTagsManager::DownloadNvmTags(vnd_local_bd_addr_***) replace the BD Address before download:
*   if (cmds[i][MCT_TAG_NUM_OFFSET] == TAG_NUM_2) { memcpy(&cmds[i][MCT_TAG_BDADDR_OFFSET], bdaddr***, 6);
---
The BD Address priorities defined in the BluetoothAddress::GetLocalAddress():
* vendor address "fetch_vendor_addr()" read address from "/data/misc/bluetooth/.bt_nv.bin" >
* address in the path PROPERTY_BT_BDADDR_PATH "ro.bt.bdaddr_path" >
* address in the property FACTORY_BDADDR_PROPERTY "ro.boot.btmacaddr" >
* address in the property PERSIST_BDADDR_PROPERTY "persist.service.bdroid.bdaddr" >
* random address "22:22:XX:XX:XX:XX" 
At the beginning, the phone doesn't have the file "/data/misc/bluetooth/.bt_nv.bin" 
and uses a random address. After the patch applied, the ".bt_nv.bin" is generated and the
phone uses the vendor address from ".bt_nv.bin".
```

BT auto ON after FDR (Android O)
```
* R.bool.def_bluetooth_on is the default value after FDR for BT can trun on or not, this value is true on Android O.
* Settings.Global.BLUETOOTH_ON is a gobal setting to record the BT status while BT on and off.
* BluetoothManagerService.persistBluetoothSetting(int value) is the function used to modify this setting Settings.Global.BLUETOOTH_ON.
```

蓝牙开关和重连
```
* 开关蓝牙涉及的类：BluetoothAdapter, BluetoothManagerService，AdapterState，AdapterProperties
* adapter state changed|isBleAppPresent|BT_VND_OP_POWER_CTRL|bt_vendor|disable timeout｜start timeout
* AdapterState关蓝牙状态机：BEGIN_BREDR_CLEANUP => BEGIN_DISABLE => BREDR_STOPPED (BleOnState) => DISABLED (OffState)
* 开蓝牙：BluetoothAdapter.STATE_OFF (10) -> STATE_BLE_TURNING_ON (14) -> (BT_VND_OP_POWER_CTRL: On) ->
* STATE_BLE_ON (15) -> STATE_TURNING_ON (11) -> STATE_ON (12)
* 开蓝牙最后一步启动蓝牙核心Profile服务： startCoreServices|setProfileServiceState|onProfileServiceStateChange
* ---
* According to BluetoothManagerService.bluetoothStateChangeHandler():
* BluetoothAdapter.ACTION_STATE_CHANGED only broadcasted when STATE_TURNING_ON/STATE_ON/STATE_TURNING_OFF
* ---
* 03:41:29.188 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 10-> 14
* 03:41:29.228 23906 24199 I bt_vendor: bt-vendor : BT_VND_OP_POWER_CTRL: On
* 03:41:29.422 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 14-> 15
* 03:41:29.430 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 15-> 11
* 03:41:29.594 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 11-> 12
* 关蓝牙：BluetoothAdapter.STATE_ON (12) -> STATE_TURNING_OFF (13) -> STATE_BLE_ON (15) ->
* STATE_BLE_TURNING_OFF (16) -> (BT_VND_OP_POWER_CTRL: Off) -> STATE_OFF (10)
* 03:41:39.918 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 12-> 13
* 03:41:39.947 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 13-> 15
* 03:41:40.036 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 15-> 16
* 03:41:40.574 23906 24204 I bt_vendor: bt-vendor : BT_VND_OP_POWER_CTRL: Off
* 03:41:40.663 23906 24198 I BluetoothAdapterState: Bluetooth adapter state changed: 16-> 10
* 从 13-> 15 到 15->16 的流程：
* 00:07:56.396  9796  9830 I BluetoothAdapterState: Bluetooth adapter state changed: 13-> 15
* 00:07:56.399  1888  1910 D BluetoothManagerService: Message: 60
* 00:07:56.399  1888  1910 D BluetoothManagerService: MESSAGE_BLUETOOTH_STATE_CHANGE: prevState = 13, newState=15
* 00:07:56.399  1888  1910 D BluetoothManagerService: Intermediate off, back to LE only mode
* 00:07:56.399  1888  1910 D BluetoothManagerService: BLE State Change Intent: 13 -> 15
* 00:07:56.399  1888  1910 D BluetoothManagerService: Broadcasting onBluetoothStateChange(false) to 18 receivers.
* 00:07:56.408  9796  9830 I BluetoothAdapterState: Entering BleOnState
* 00:07:56.781  1888  1910 D BluetoothManagerService: Calling sendBrEdrDownCallback callbacks
* 00:07:56.781  1888  1910 D BluetoothManagerService: isBleAppPresent() count: 0
* 00:07:56.782  9796  9830 D BluetoothAdapterState: Current state: BLE ON, message: 20
* 00:07:56.782  9796  9830 D BluetoothAdapterProperties: Setting state to 16
* 00:07:56.782  9796  9830 I BluetoothAdapterState: Bluetooth adapter state changed: 15-> 16
* 关底层蓝牙超时（BT_VND_OP_POWER_CTRL OFF 没执行到）的一种流程：
* 00:17:29.539  1470  1619 D BluetoothManagerService: BLE State Change Intent: 15 -> 16
* 00:17:29.539  8924  8958 D BluetoothAdapterProperties: onBleDisable
* 00:17:29.539  8924  8958 I BluetoothAdapterState: Entering PendingCommandState
* 00:17:29.553  8924  8964 D BluetoothAdapterProperties: Scan Mode:20
* 00:17:37.548  8924  8958 D BluetoothAdapterState: Current state: PENDING_COMMAND, message: 103
* 00:17:37.548  8924  8958 E BluetoothAdapterState: Error disabling Bluetooth (disable timeout) ****
* ---
* 关蓝牙是ProfileService的关闭流程
* 关闭GattService的对应函数为setGattProfileServiceState(names,OFF)，其他ProfileService为setProfileServiceState(names,OFF)
* startService(service, OFF) => onStartCommand() => doStop() => stop() => stopSelf() => onDestroy() => cleanup()
* ---
* 有种叫 EAS policy 的策略用于禁止不符合策略的用户开启蓝牙：
* Bluetooth EAS policy: AdapterService.enable()
* - DevicePolicyManager mDPM =(DevicePolicyManager)getSystemService(Context.DEVICE_POLICY_SERVICE);
* - if (mDPM != null && mDPM.getBluetoothDisabled(null)) "enable() Bluetooth is disabled by EAS policy"
* DevicePolicyManager.getBluetoothDisabled() => DevicePolicyManagerService.getBluetoothDisabled()
---
* Adapter状态变为STATE_BLE_ON(15)之后会触发 AdapterState.BleOnState.BLE_TURN_OFF 调用 disableNative() 关闭蓝牙：
* notifyAdapterStateChange(BluetoothAdapter.STATE_BLE_TURNING_OFF)
* adapterService.disableNative() -> bluetooth.c$disable() -> stack_manager.c$shut_down_stack_async() ->
* stack_manager.c$event_shut_down_stack(context)
* 1. btif_disable_bluetooth();
* 2. module_shut_down(get_module(BTIF_CONFIG_MODULE));
* 3. future_await(local_hack_future);
* 4. module_shut_down(get_module(CONTROLLER_MODULE));
* 5. stack_manager.c$event_signal_stack_down(context) -> HAL_CBACK(bt_hal_cbacks,adapter_state_changed_cb,BT_STATE_OFF)
* 关蓝牙的主要函数btif_disable_bluetooth()是异步的，发送消息后会立即返回，然后执行到步骤3等待蓝牙关闭的semaphore
* 该semaphore会在蓝牙真正关闭后，在函数btif_disable_bluetooth_evt()中触发，先来看函数btif_disable_bluetooth()执行的内容：
* btif_dm_on_disable(); btif_sock_cleanup(); btif_pan_cleanup(); BTA_DisableBluetooth(); 真正重要的是最后一个函数：
* 首先，BTA_DisableBluetooth() 给消息队列 btu_bta_msg_queue 发送 BTA_DM_API_DISABLE_EVT 消息
* 该队列处理函数 btu_bta_msg_ready 从中取出消息，按照消息的分类，将消息传给对应消息类别的处理函数，如下
* msg_group = p_msg->event>>8; (*bta_sys_cb.reg[msg_group]->evt_hdlr)(p_msg);　消息的类别 (msg_group) 由高8位定义
* 消息BTA_DM_API_DISABLE_EVT是 BTA_ID_BM 类别中的第１个消息（从0开始数起），该消息类别的处理函数是 bta_dm_sm_execute
* 该函数会接着将消息分派给真正的消息处理函数：msg_id = p_msg->event&0xff; (*bta_dm_action[msg_id])( (tBTA_DM_MSG*) p_msg);
* 消息ID由低8位决定，BTA_DM_API_DISABLE_EVT 是 BTA_ID_BM 的第1个消息，会调用第1个处理函数　bta_dm_disable 进行处理
* 最终触发调用 bta_dm_cb.p_sec_cback(BTA_DM_DISABLE_EVT, NULL) => btif_dm_upstreams_evt，然后执行到一下函数关闭蓝牙芯片:
* btif_disable_bluetooth_evt()
* 1. bte_main_enable_lpm(FALSE)
* 2. bte_main_disable() => module_shut_down(get_module(HCI_MODULE/BTSNOOP_MODULE)); BTU_ShutDown();
* 3. future_ready(stack_manager_get_hack_future(), FUTURE_SUCCESS)
* 蓝牙芯片在第２步关闭 HCI 模块时关闭: module_shut_down(get_module(HCI_MODULEHCI)) => hci_module.shut_down() =>
* vendor->send_command(BT_VND_OP_POWER_CTRL, BT_VND_PWR_OFF) => bt_vendor_qcom.c$op(CTRL, OFF)
* 第３步释放semaphore，触发semaphore等待函数 future_await(local_hack_future) 返回，至此蓝牙关闭成功
---
* 给消息队列 btu_bta_msg_queue 发送消息到最后触发 btu_bta_msg_ready 取消息的流程：
* 首先，dequeue 处理函数 btu_bta_msg_ready 通过 fixed_queue_register_dequeue 进行注册，与对应的队列和处理线程关联，如下:
* fixed_queue_register_dequeue(btu_bta_msg_queue, thread_get_reactor(bt_workqueue_thread), btu_bta_msg_ready, NULL)
* 线程负责等待队列上的消息，当有消息到来时调用队列的处理函数 btu_bta_msg_ready 进行处理，根据这里的设计思想，一个线程可以监视多个队列
* 注册时，处理函数保存在 queue->dequeue_ready 中，另外消息队列都对应一个 reactor_object，如下为队列注册 reactor_object
* queue->dequeue_object = reactor_register(thread_reactor,queue->dequeue_sem->fd,queue,internal_dequeue_ready,NULL):
* 1. reactor_object_t* ro = osi_calloc(sz); ro->context = queue; ro->fd = fd; ro->reactor = thread_reactor;
* 2. ro->read_ready = internal_dequeue_ready; struct epoll_event event = {0}; event.data.ptr = ro;
* 3. if (read_ready) event.events |= (EPOLLIN|EPOLLRDHUP); epoll_ctl(thread_reactor->epoll_fd,EPOLL_CTL_ADD,fd,&event);
* 各种对象的关系为：每个线程对应一个reactor，每个队列对应一个reactor_object，线程运行时会进入reactor循环，其中处理多个reactor_object
* 在处理 reactor_object 时，如果是读事件会调用 ro->read_ready(ro->context) 调用到函数 internal_dequeue_ready(queue)
* 函数 internal_dequeue_ready 会调用真正的队列处理函数 queue->dequeue_ready(queue, NULL) 即 btu_bta_msg_ready(queue, NULL)
* 因此只要队列对应的 reactor_object 被处理，队列的处理函数 btu_bta_msg_ready 就会调用，但 reactor_object 的处理怎样触发呢？
* 最关键的步骤是上面的第3步，该步骤调用 epoll_ctl 将 reactor_object 应该怎样触发的事件添加到了 reactor 的 epoll_fd 中
* 注册的事件这样说：当队列的 queue->dequeue_sem->fd 可读（EPOLLIN|EPOLLRDHUP）时，麻烦调用 reactor_object 的 read_ready 进行处理
* 因此 reactor 只需在 epoll_fd 中等待事件发生，如果是可读事件，调用 reactor_object->ready_ready 进行处理即可
* 注意 reactor_object 保存在事件的 event.data.ptr 变量中，因此事件发生时，reactor 可以在事件的变量中得到 reactor_object
* 最后，线程对应的 reactor 循环位于 run_reactor 函数中，该循环按照以上描述对 reactor_object 进行处理：
* reactor_status_t run_reactor(reactor_t *reactor, int turns)
* - struct epoll_event events[MAX_EVENTS];                                      // 该数组保存发生的事件
* - for (int i = 0; turns == 0 || i < turns; ++i) {                             // 进入线程循环，turns通常为0表示无限循环
* -   OSI_NO_INTR(ret = epoll_wait(reactor->epoll_fd, events, MAX_EVENTS, -1)); // 等待 epoll_fd 中事件发生
* -   for (int j = 0; j < ret; ++j) {                                           // 对每个发生的事件进行处理
* -     reactor_object_t *ro = (reactor_object_t *)events[j].data.ptr;          // 获取 reactor_object，然后处理读写事件
* -     if (events[j].events & (EPOLLIN | EPOLLHUP | EPOLLRDHUP | EPOLLERR)) ro->read_ready(ro->context);
* -     if (!ro->object_removed && events[j].events & EPOLLOUT) ro->write_ready(object->context);
* -   }
* - }
* 还有一个问题，上面说当队列的 queue->dequeue_sem->fd 可读时，才会触发 reactor 处理事件，怎样让队列的这个 fd 可读呢？
* 实际上在调用 fixed_queue_enqueue(btu_bta_msg_queue, p_msg) 添加消息到队列中时，该函数就会写这个 fd 使它变成可读
* 调用流程为 fixed_queue_enqueue() => semaphore_post(queue->dequeue_sem) => eventfd_write(semaphore->fd, 1ULL)
* 因此将消息添加到队列中时，就会触发队列注册的线程对应的 reactor 成功等待到事件，然后进行一系列的回调对消息进行处理：
* run_reactor => reactor_object->read_ready => internal_dequeue_ready => queue->dequeue_ready => btu_bta_msg_ready
```

HCI/SNOOP
```
vendor/qcom/opensource/bluetooth/bt_logger/
vendor/qcom/opensource/bluetooth/btsnoop_dump/
system/bt/hci/src/btsnoop
---
The log switch between hci_snoop.cfa and btsnoop_hci.log is START_SNOOP_LOGGING(), below is the flow:
01. bluetooth.c will property_set("bluetooth.startbtlogger", "true") to start "bt_logger" service (vendor/qcom/opensource/bluetooth/bt_logger/)
02. btsnoop.c$start_up()
03. update_logging()
04. btsnoop_net_open() -> listen_fn_() -> local_socket_create() -> using listen_socket_local_ to listen on socket "bthcitraffic"
05. START_SNOOP_LOGGING() to send_event(START_SNOOP_SIGNAL)
06. bt_logger/src/bt_logger.c: process_packet() -> start_snoop_logging()
07. bt_logger/src/btsnoop_dump.c: snoop_dump_thread() -> snoop_connect_to_source()
08. bt_logger/src/btsnoop_dump.c: connect the socket "bthcitraffic"
09. hci/src/btsnoop_net.c: client_socket = accept(listen_socket_local_, ...);
10. client_socket_btsnoop = client_socket;
11. hci/src/btsnoop.c: btsnoop_net_write() -> send(client_socket_btsnoop, ...) -> write to "hci_btsnoopxxx.cfa"
    if client_socket_btsnoop is -1, write to "btsnoop_hci.log".
void btsnoop_write(const void *data, size_t length) {
  if (client_socket_btsnoop != -1) {
      btsnoop_net_write(data, length);
      /* skip writing to file if external client is connected*/
      return; 
  }
  if (logfile_fd != INVALID_FD)
      write(logfile_fd, data, length);
}
---
And btsnoop_net.c$listen_fn_() is not only listen on "bthcitraffic",
but also listen on: LOCALHOST_ = 0x7F000001; LISTEN_PORT_ = 8872;
And the priority of "0x7F000001:8872" is higher than "bthcitraffic".
I think if we write an apk connect to "0x7F000001:8872", we can receive the hci log and store it any where.
---
* hci receive: event_uart_has_bytes() => hal_says_data_ready() => btu_hci_msg_queue => btu_hci_msg_ready()
* hci_layer.c$hal_says_data_ready() 接收 hci event 和 acl data
* - acl data: packet_fragmenter->reassemble_and_dispatch() => dispatch to btu_hci_msg_queue
* - acl event: dispatch to btu_hci_msg_queue, the queue is registered as following:
*   data_dispatcher_register_default(hci->event_dispatcher, btu_hci_msg_queue);
*   hci->set_data_queue(btu_hci_msg_queue);
* hci_layer.c$transmit_fragment() 发送 hci command 和 acl data
* - hal->transmit_data(type, date, length)
* btsnoop.c$capture() 用于抓取 hci log，该函数被上面两个函数调用
* hci command 和 hci event 定义在头文件 hcidefs.h 和 vendor_hcidefs.h 中
* 接收 hci event 和 acl data 处理流程如下：
* hal_says_data_ready() => dispatch event/data to btu_hci_msg_queue
* btu_hci_msg_ready(btu_hci_msg_queue)
* btu_hci_msg_process(p_msg) 
* - BT_EVT_TO_BTU_HCI_ACL: l2c_rcv_acl_data(p_msg)
HCI数据发送流程
* hci_thread管理两个队列，command_queue和packet_queue，分别用于发送HCI命令和ACL数据
* 上层发送HCI命令时，可以调用hci->transmit_command()或hci->transmit_downward()插入command_queue等待发送
* 上层发送ACL数据时，可以调用hci->transmit_downward()插入packet_queue等待发送
* hci接口在hci_layer.c$init_layer_interface()函数中初始化，并通过调用hci_layer.c$hci_layer_get_interface()获取该接口
* 队列中有数据后，Bluedroid的线程机制会触发队列中数据处理，线程机制的处理流程如下：
* => run_reactor()
* => reactor_object->read_ready(command_queue/packet_queue)
* => internal_dequeue_ready(command_queue/packet_queue)
* => queue->dequeue_ready(queue, queue->context)
* => event_command_ready(queue, context) / event_packet_ready(queue, context)
* HCI层的这两个函数event_command_ready/event_packet_ready调用后，便从队列中取出数据开始发送，数据从队列取出后的发送流程为：
* => packet_fragmenter->fragment_and_dispatch(packet)
* => packet_fragmenter.c$fragment_and_dispatch(packet)
* => packet_fragmenter_callbacks->fragmented(packet, finished)
* => hci_layer.c$transmit_fragment(packet, finished)
* => btsnoop->capture(packet, receive=false); hal->transmit_data(type, data, len)
* packet_fragmenter接口在packet_fragmenter.c文件中的interface结构体中初始化，并通过packet_fragmenter_get_interface()获取该接口
* packet_fragmenter_callbacks接口在hci_layer.c中同名结构体中初始化，并通过packet_fragmenter->init(cb)传给packet_fragmenter接口
* btsnoop接口在btsnoop.c中的interface接口体中初始化，并通过btsnoop_get_interface()获取该接口
* hal接口通过hci_hal.c$hci_hal_get_interface()获取，并在hci_hal_h4.c或hci_hal_mct.c中初始化
* 最后数据会通过vendor提供的串口发送给蓝牙芯片，vendor接口在vendor.c中的interface结构体中定义，调用vendor_get_interface()可以获取给接口
* HCI层通过vendor->open() => vendor.c$vendor_open() => "libbt-vendor.so"bt_vendor_interface_t->init()开启vendor
* hal接口在初始化时通过ports=vendor->send_command(VENDOR_OPEN_USERIAL, &fds)打开串口，之后便可以在对应串口发送数据
BTSNOOP
* HCI发送数据的抓取在 fragmenter_callbacks->fragmented(packet, finished)　=> hci_layer.c$transmit_fragment(packet, finished) 函数中
* HCI接收数据的抓取在 hci_hal_callbacks->data_ready(type => hci_layer.c$hal_says_data_ready(type) 函数中
* btsnoop->capture(packet, receive) => btsnoop.c$capture(packet, receive)
* btsnoop接口在btsnoop.c中的interface接口体中初始化，并通过btsnoop_get_interface()获取该接口
* BTSNOOP的开关，最终在capture中起作用的是变量logfile_fd，即log文件如果打开了即抓取log，否则不抓取
* logfile_fd在update_logging()函数中进行更新，start_up()和set_api_wants_to_log()两个函数调用了该函数
* 打开蓝牙时会调用 start_up() 函数，该函数检查 bt_stack.conf 中的设定来决定是否打开log
* 另外在开发者选项中打开"Enable Bluetooth HCI snoop log"，会触发调用set_api_wants_to_log()函数，然后logging_enabled_via_api会设为真
* 此时如果蓝牙已经打开，BTSNOOP的抓取会即时开启（当然如果bt_stac.conf已经开启了则继续开启），如果蓝牙没有打开则会在蓝牙打开时开启BTSNOOP的抓取
* 上层开启BTSNOOP的接口是 BluetoothAdapter.java$configHciSnoopLog(enable)，配置文件的位置为 /etc/bluetooth/bt_stack.conf
* 总的来说3个开关中任意一个打开BTSNOOP都会打开：开发者选项打开（logging_enabled_via_api），配置文件中的BtSnoopExtDump打开（hci_ext_dump_enabled）
* 或者打开配置文件中的BtSnoopLogOutput，对应判断函数为 stack_config->get_btsnoop_turned_on() => stack_config.c$get_btsnoop_turned_on()
Bluedroid中的线程
* hci_thread负责command_queue，packet_queue，串口相关操作，low_power_manager的相关操作
* bt_workqueue线程负责btu_bta_msg_queue，btu_hci_msg_queue，btu_general_alarm_queue
* media_worker线程负责btif_media_cmd_msg_queue
* aptx_media_worker线程负责aptx编码处理
* alarm_dispatcher线程负责定时器分发处理
* bt_jni_workqueue线程负责jni相关处理
* btif_sock线程负责btsock相关处理
* stack_manager线程负责stack管理相关处理
```

搜索配对连接
```
* 处理对方发起的connect request: l2c_link_hci_conn_req|btm_acl_created|btm_sec_disconnected
* 底层连接：Scan Mode:|btm_acl_created|btm_sec_disconnected|L2CA_DisconnectReq|W4_L2CAP_DISC_RSP
* Write_Scan_Enable 对应的上层参数：BluetoothAdapterProperties: Scan Mode:20/21/23
* BluetoothAdapter.SCAN_MODE_NONE(20) SCAN_MODE_CONNECTABLE(21) SCAN_MODE_CONNECTABLE_DISCOVERABLE(23)
* 上层连接：onProfileServiceStateChange|onProfileStateChanged|connectA2dpNative|A2dpStateMachine|
* connectHfpNative|HeadsetStateMachine|HeadsetService|BTA_AG|AG State Change|onProfileStateChanged|
* Connection state|bt_btif : BTHF|connect timeout|bt_btif : AV Sevent
* HFP从connnecting到connected状态：
* => HeadsetStateMachine$Pending.processMessage
* => HeadsetStateMachine$Pending.processConnectionEvent
* => HeadsetStateMachine.broadcastConnectionState
* => btservice.ProfileService.notifyProfileConnectionStateChanged
* => btservice.AdapterService.onProfileConnectionStateChanged
---
* BluetoothSettings.onOptionsItemSelected() BluetoothSettings.MENU_ID_SCAN
* BluetoothSettings.startScanning(): mAvailableDevicesCategory.removeAll(); mInitialScanStarted = true;
* LocalBluetoothAdapter.startScanning(force:true)
* BluetoothAdapter.startDiscovery()
* AdapterService.startDiscovery(): if a2dp multicast is ongoing then ignore discovery
* AdapterService.startDiscoveryNative()
* bluetooth.c$start_discovery() => btif_dm_start_discovery()
* BTA_DmSearch(&inq_params, services, bte_search_devices_evt)
* btif_dm.c$bte_search_devices_evt(BTA_DM_INQ_RES_EVT, p_data)
* btif_dm.c$btif_dm_search_devices_evt(BTA_DM_INQ_RES_EVT, p_param): will get bdname and alias BT_PROPERTY_BDNAME (0x1)
* bt_hal_cbacks->device_found_cb(num_properties, properties): bt_callbacks_t { device_found_callback device_found_cb; }
* com_android_bluetooth_btservice_AdapterService.cpp$device_found_callback(num_properties, properties):
* - remote_device_properties_callback => RemoteDevices.devicePropertyChangedCallback(address, types, vals)
* - method_deviceFoundCallback => RemoteDevices.deviceFoundCallback(address)
* RemoteDevices.deviceFoundCallback send Intent BluetoothDevice.ACTION_FOUND with cod, rssi, name
* BluetoothEventManager.DeviceFoundHandler.onReceive(context, intent, device) 
* - for new device: new CachedBluetoothDevice() -> fillData() -> fetchName() -> BluetoothDevice.getAliasName()
* - and then set rssi/cod/name and dispatchAttributesChanged
* CachedBluetoothDevice.dispatchAttributesChanged
* BluetoothDevicePreference.onDeviceAttributesChanged()
```

对方设备电源关闭的情况下进行BT和BLE配对的流程
```
BluetoothDevicePreference.onClicked()
CachedBluetoothDevice.startPairing() if (isBleDevice()) refreshGatt(GATT_STATE_BONDING)
BluetoothDevice.createBond()
AdapterService.createBond()
BondStateMachine.sendMessage(BondStateMachine.CREATE_BOND)
BondStateMachine.createBond()
AdapterService.createBondNative()
btif_dm_create_bond()
btif_dm_cb_create_bond()
bond_state_changed() BT_BOND_STATE_NONE -> BT_BOND_STATE_BONDING
BTA_DmBondByTransport()
bta_dm_bond()
BTM_SecBondByTransport()
btm_sec_bond_by_transport()
=> (1.LE) SMP_Pair() sec_state:BTM_SEC_STATE_AUTHENTICATING, btm_sec_change_pairing_state(BTM_PAIR_STATE_WAIT_AUTH_COMPLETE)
          L2CA_ConnectFixedChnl(L2CAP_SMP_CID)
          L2CA_ConnectFixedChnl()
          l2cu_create_conn()
          l2cble_create_conn()
          btm_send_hci_create_connection() link_state = LST_CONNECTING
          l2c_lcb_timer_timeout() L2CAP_BLE_LINK_CONNECT_TIMEOUT_MS (30s)
          l2c_link_timeout()
          l2cu_release_lcb()
          l2cu_process_fixed_disc_cback() pL2CA_FixedConn_Cb()
          smp_connect_callback()
          smp_sm_event() SMP_L2CAP_DISCONN_EVT
          smp_idle_terminate()
          smp_proc_pairing_cmpl()
          SMP_COMPLT_EVT(7) SMP_FAIL(0x18)
          btm_proc_smp_cback() SMP_COMPLT_EVT(7)
          bta_dm_ble_smp_cback() BTM_LE_COMPLT_EVT
          btif_dm_upstreams_evt() BTA_DM_BLE_AUTH_CMPL_EVT 
          btif_dm_ble_auth_cmpl_evt()
          bond_state_changed() BT_BOND_STATE_BONDING -> BT_BOND_STATE_NONE
   (2.BT) BTM_ReadRemoteDeviceName(BR_EDR) btm_sec_change_pairing_state(BTM_PAIR_STATE_GET_REM_NAME)
          btm_initiate_rem_name()
          btsnd_hcic_rmt_name_req()
          btu_hcif_rmt_name_request_comp_evt()
          btm_sec_rmt_name_request_complete()
          bta_security.p_auth_complete_callback()
          bta_dm_authentication_complete_cback() bta_dm_cb.p_sec_cback(BTA_DM_AUTH_CMPL_EVT)
          btif_dm_upstreams_evt() BTA_DM_AUTH_CMPL_EVT
          btif_dm_auth_cmpl_evt() HCI_ERR_PAGE_TIMEOUT
          bond_state_changed() BT_BOND_STATE_BONDING -> BT_BOND_STATE_NONE
```

状态栏蓝牙图标
```
蓝牙状态栏相关文件
* frameworks/base/services/core/java/com/android/server/BluetoothManagerService.java$bluetoothStateChangeHandler()
* frameworks/base/packages/SystemUI/src/com/android/systemui/statusbar/policy/BluetoothControllerImpl.java
* frameworks/base/packages/SystemUI/src/com/android/systemui/statusbar/phone/PhoneStatusBarPolicy.java
连接状态相关
* => PhoneStatusBarPolicy()/ACTION_DUN_STATE_CHANGED/onBluetoothDevicesChanged/onBluetoothStateChange
* => PhoneStatusBarPolicy.java$updateBluetooth()
* => BluetoothControllerImpl.isBluetoothConnected() || mIsDunConnected
*    getBluetoothAdapter().getConnectionState() == BluetoothAdapter.STATE_CONNECTED ||
*    BluetoothManager.getConnectedDevices(BluetoothProfile.GATT)
* => AdapterService.getAdapterConnectionState() => AdapterProperties.mConnectionState
*    GattService.getDevicesMatchingConnectionStates(new int[] { BluetoothProfile.STATE_CONNECTED })
在QuickSetting点击开蓝牙
* frameworks/base/packages/SystemUI/src/com/android/systemui/qs/tiles/BluetoothTile.java
* frameworks/base/packages/SystemUI/src/com/android/systemui/qs/tileimpl/QSTileImpl.java
* BluetoothTile.handleClick()
  BluetoothControllerImpl.setBluetoothEnabled(!mState.value)
  LocalBluetoothAdapter.setBluetoothEnabled(enable) => BluetoothAdapter.eanble() or disable()
* QSTileImpl.handleRefreshState(arg)
    BluetoothTile.handleUpdateState(mTmpState, arg);
    final boolean changed = mTmpState.copyTo(mState***);
  BluetoothTile.handleUpdateState(state, arg)
    final boolean enabled = mController.isBluetoothEnabled();
    state.value = enabled;
* BluetoothControllerImpl.isBluetoothEnabled() { return mEnabled; }
  BluetoothControllerImpl.onBluetoothStateChanged(int bluetoothState) {
    mEnabled = bluetoothState == BluetoothAdapter.STATE_ON || bluetoothState == BluetoothAdapter.STATE_TURNING_ON;
    mState = bluetoothState;
    mHandler.sendEmptyMessage(H.MSG_STATE_CHANGED);
```

HSP/HFP/SCO
```
* BTA_AG|AG State|AG SCO State|AG_AUDIO|setBluetoothScoOn
* HFP AT cmd|bta_ag_hfp_result
---
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
```

HID/HOGP
```
* 将HID数据写入内核： bta_hh_co_write: UHID write
* 查看Android事件： adb shell getevent -t -l | grep -iE "EV_KEY"
* This issue may be only caused by the APP interpreting LONG PRESS KEY to multiple characters.
* Could we check the APP'code to see how it hanlde key events?
* Android PFGr said below.
* ---
* repeatCount is working in the process of InputDispatcher.
* Then, the timer called KeyRepeatTimeout works when it receive DOWN.
* If the timer is over than 500msec, repeatCount will be incremented and Event is notified every 50msec.
* In this case, since it takes 520msec from DOWN to UP about KEY_1,
* repeatCoun might be incremented with 1 and the Event might be notified.
* ---
```

AVRCP Media Key Receive Flow (Android-O)
```
btif_rc.handle_rc_passthrough_cmd()
com_android_bluetooth_avrcp.btavrcp_passthrough_command_callback()
Avrcp.handlePassthroughCmdRequestFromNative()
Avrcp.handleMessage() MSG_NATIVE_REQ_PASS_THROUGH
Avrcp.handlePassthroughCmd()
MediaSessionManager.dispatchMediaKeyEvent(keyEvent)
MediaSessionManager.dispatchMediaKeyEvent(keyEvent, needWakeLock:false)
MediaSessionService.dispatchMediaKeyEvent(keyEvent, false)
```

A2DP Reconfig 相关流程
```
=> avdt_l2c_data_ind_cback()
   avdt_ad_tc_data_ind()
   avdt_msg_ind()
   avdt_scb_hdl_setconfig_cmd() AVDT_CONFIG_IND_EVT
   bta_av_config_ind() 
   bta_av_co_audio_setconfig() ***p_peer->acp = true; and set p_peer->reconfig_needed
   bta_av_co_set_codec_ota_config()
   bta_av_co_cb.codecs->setCodecOtaConfig()
   A2dpCodecConfig.setCodecUserConfig(codec_user_config, codec_audio_config, p_ota_codec_config, false)***
   A2dpCodecConfigSbc.updateEncoderUserConfig()
   a2dp_sbc_encoder_update() *** *p_restart_output always set to false

=> bta_av_getcap_results()/bta_av_save_caps()
   bta_av_co_audio_getconfig() ***set p_peer->reconfig_needed

=> setCodecConfigPreferenceNative()
   codec_config_src()/btif_recv_scms_data()
   btif_av_state_idle/closing/opened/opening/started_handler() BTIF_AV_SOURCE_CONFIG_REQ_EVT
   btif_update_source_codec()
   btif_a2dp_source_encoder_user_config_update_req() BTIF_MEDIA_SOURCE_ENCODER_USER_CONFIG_UPDATE
   btif_a2dp_source_encoder_user_config_update_event()
   bta_av_co_set_codec_user_config() ***bta_av_co_cb.codecs->setCodecUserConfig() and determine whether to do BTA_AvReconfig()
   A2dpCodecConfig.setCodecUserConfig(codec_user_config, codec_audio_config, p_peer_sink_capabilities, true) ***

=> btif_a2dp_recv_ctrl_data() A2DP_CTRL_SET_OUTPUT_AUDIO_CONFIG
   btif_a2dp_source_feeding_update_req() BTIF_MEDIA_AUDIO_FEEDING_UPDATE
   btif_a2dp_source_audio_feeding_update_event()
   bta_av_co_set_codec_audio_config() ***bta_av_co_cb.codecs->setCodecAudioConfig() and determine whether to do BTA_AvReconfig()
   A2dpCodecConfig.setCodecUserConfig(codec_user_config, codec_audio_config, p_peer_sink_capabilities, true) ***

当我们作为 A2DP Acceptor, 即对方发起连接，对方来 GetCapability => SetConfigration => Open => Start.
当对方 SetConfiguration 时会触发我们自己 Discovery => GetCapability 查询对方 A2DP 的信息
如果我们认为对方 SetConfigration 的参数需要 RECONFIG，我们会在对方 Start 后立即 Suspend，
然后去做 RECONFIG (Close => SetConfiguration => Open => Start)
```

AVRCP/A2DP
```
* A2DP与SCO: bthost_ipc|audio_start_stream|audio_stop_stream|a2dp_command|suspend_audio_datapath|ON A2DP|SCO State|audio_state|onAudioStateChanged|processAudioStateEvent
* AVRCP发送的PLAY/STOP: handle_rc_passthrough_cmd|AVRCP: Send key|MediaSessionService: Sending KeyEvent|MediaButton|NuPlayerDriver: start|NuPlayerDriver: pause
* Stopping VR|stopVoiceRecognition|Starting VR|startVoiceRecognition
* AVRCP按键信息，安卓N的键映射"android/frameworks/base/data/keyboards/AVRCP.kl"，另外 gpio-keys.kl 里能修改音量键行为
* 安卓N的AVRCP按键：BTA_AV_REMOTE_CMD_EVT|handle_rc_passthrough_cmd|bt_btif : send_key|bt_btif : send_event|MediaSessionService: Sending KeyEvent
* 安卓O的AVRCP按键：BTA_AV_REMOTE_CMD_EVT|MSG_NATIVE_REQ_PASS_THROUGH|Sending KeyEvent
* Audio和Player信息：NuPlayerDriver|MediaPlayer|updatePlayerPlayPauseState|updateCurrentMediaState|updatePlayStatusForDevice|
*     MSG_SET_A2DP_AUDIO_STATE *** (10 STATE_PLAYING, 11 STATE_NOT_PLAYING)
* SCO/A2DP/AVRCP交互: audio_start_stream|audio_stop_stream|a2dp_command|suspend_audio_datapath|ON A2DP|SCO State|audio_state|
*     AVRCP: Send key|ACTION_MEDIA_BUTTON|NuPlayerDriver: pause|NuPlayerDriver: start|updatePlayStatusForDevice|
*     BTIF_MEDIA_STOP_VS_CMD|BTIF_MEDIA_STOP_VS_CMD|BTIF_MEDIA_START_VS_CMD|BTIF_MEDIA_START_VS_CMD
* 电话挂断之后，Audio什么时间点将音频写到蓝牙？ Audio只要播放器有数据它就会一直写，写给谁只在于当前的选择的是手机还是蓝牙
* 那什么时候选择蓝牙呢？ AudioPolicyManager::checkA2dpSuspend() 当SCO断掉之后如果有A2DP就会切到A2DP
* 只要切到了A2DP就不会漏音，只是A2DP start的时间导致延时问题；漏音问题是由手机端电话挂断后播放器开始播放音乐，与SCO真实断连之间的时间差导致
* system/bt/audio_a2dp_h2: audio.a2dp.default_32 libbthost_if_32 (system/lib/hw, system/lib)
* A2DP COMMAND|skt_connect|skt_disconnect|AV Sevent
* AVDT_CONNECT => a2dp_stream_common_init => skt_connect(common->ctrl_fd) /data/misc/bluedroid/.a2dp_ctrl
* AVDT_DISCONNECT => adev_close_output_stream => skt_disconnect(common->ctrl_fd)
* AVDT_DISCONNECT => BT_VND_OP_POWER_CTRL: Off => a2dp_ctrl_receive => skt_disconnect(common->ctrl_fd)
* avdt_ccb_action:avdt_ccb_hdl_start_rsp => avdt_scb_action:avdt_scb_hdl_start_rsp => AVDT_START_CFM_EVT =>
* bta_av_proc_stream_evt => BTA_AV_STR_START_OK/FAIL_EVT => bta_av_hdl_event => bta_av_ssm_execute "AV Sevent"
---
* AVRCP.sendTrackChangedRsp trackNum
* 1. Music player app set track number by calling MediaSession.setMetadata()
* MediaSession: setMetadata traceNum 88
* MediaSession:    at android.media.session.MediaSession.setMetadata(MediaSession.java:420)
* MediaSession:    at android.support.v4.media.session.MediaSessionCompatApi21.setMetadata(MediaSessionCompatApi21.java:104)
* MediaSession:    at android.support.v4.media.session.MediaSessionCompat$MediaSessionImplApi21.setMetadata(MediaSessionCompat.java:2333)
* MediaSession:    at android.support.v4.media.session.MediaSessionCompat.setMetadata(MediaSessionCompat.java:436)
* MediaSession:    at com.google.android.music.playback.MusicPlaybackService.updateMediaSessionMetadata(MusicPlaybackService.java:2877)
* MediaSession:    at com.google.android.music.playback.MusicPlaybackService.updateNotificationAndMediaSessionMetadata(MusicPlaybackService.java:2219)
* MediaSession:    at com.google.android.music.playback.MusicPlaybackService.access$3400(MusicPlaybackService.java:137)
* MediaSession:    at com.google.android.music.playback.MusicPlaybackService$15.onArtRequestComplete(MusicPlaybackService.java:1787)
* MediaSession:    at com.google.android.music.art.ArtResolverImpl$NotifyListenersRunnable.run(ArtResolverImpl.java:338)
* MediaSession:    at android.os.Handler.handleCallback(Handler.java:751)
* MediaSession:    at android.os.Handler.dispatchMessage(Handler.java:95)
* MediaSession:    at android.os.Looper.loop(Looper.java:154)
* MediaSession:    at android.os.HandlerThread.run(HandlerThread.java:61)
* 2. Avrcp.MediaControllerListener.onMetadataChanged()
* Avrcp   : MediaController metadata changed
* Avrcp   : updateMetadata
* Avrcp   : MediaAttributes Changed to [MediaAttributes: ... - ... by ... (88/88) Pop]
* Avrcp   : sending track change for device 0
* Avrcp   : device found at index 0
* Avrcp   : mCurrentPlayStatePlaybackState {state=3, position=0, buffered position=0, speed=1.0, ...}
* Avrcp   : Current music player is = com.google.android.music
* Avrcp   :  TrackNumberRsp = 88for notification type 1
---
NuPlayerRenderer/AudioSink/AudioOutput/AudioTrack: libmediaplayerservice_32 (system/lib)
* "possible video time jump|AudioSink write would block"
* frameworks/av/media/libmediaplayerservice/MediaPlayerService.cpp
* frameworks/av/media/libmediaplayerservice/nuplayer/NuPlayerRenderer.cpp
* NuPlayer::Renderer::onResume() => mAudioSink->start()
SCMS-T
* 支持 SCMS-T 的设备会在 AVDTP_GET_CAPABILITIES 的响应数据包中包含 SCMS-T 信息:
* AVDTP Signaling:
        Message Type: Response Accept
        Signaling Identifier: AVDTP_GET_CAPABILITIES
        Service Category: Content Protection
                Length Of Service Capability (LOSC): 2
                Content Protection Type: SCMS-T
* 连接 A2DP 时首先发送 AVDTP_DISCOVER 发现对方设备可连接 SEP（Stream EndPoint）
* 然后发送 AVDTP_GET_CAPABILITIES 获取每个 SEP 的信息，DISCOVER　返回的 SEP 信息如下：
* AVDTP Signaling:
        Message Type: Response Accept
        Signaling Identifier: AVDTP_DISCOVER
        ACP Stream Endpoint ID: 1
                In-use: No
                Media Type: Audio
                TSEP: SNK
        ACP Stream Endpoint ID: 2
                In-use: No
                Media Type: Audio
                TSEP: SNK
* AVDTP_GET_CAPABILITIES 的大致流程是：
* bta_av_disc_results()
* bta_av_next_getcap()
* AVDT_GetCapReq()/AVDT_GetAllCapReq() set getcap.p_cback to bta_av_dt_cback[i]
* avdt_get_cap_req()
* avdt_ccb_event AVDT_CCB_API_GETCAP_REQ_EVT
* avdt_ccb_action AVDT_CCB_SND_GETCAP_CMD
* avdt_ccb_snd_getcap_cmd
* avdt_ccb_hdl_getcap_rsp
* bta_av_stream0_cback/bta_av_stream1_cback
* bta_av_proc_stream_evt AVDT_GETCAP_CFM_EVT => bta_sys_sendmsg()
* btu_bta_msg_ready() => bta_sys_event() => bta_av_hdl_event()
* bta_av_ssm_execute => p_scb->p_act_tbl[action])()
* STR_GETCAP_OK_EVT => BTA_AV_GETCAP_RESULTS => bta_av_a2d_action|bta_av_getcap_results
* STR_GETCAP_FAIL_EVT => BTA_AV_OPEN_FAILED => bta_av_a2d_action|bta_av_open_failed => AVDT_DisconnectReq
* ---
* bta_av_getcap_results() 会调用 bta_av_co_peer_has_scms_t() 检查对方是否支持 scms-t
* 其调用流程为 bta_av_co_peer_has_scms_t => bta_av_co_peer_cp_supported => bta_av_co_audio_sink_has_scmst => bta_av_co_cp_is_scmst
* 对方支持 scms-t 的情况会回调给上层，上层应用判断对方设备不支持 scms-t 时会弹出通知提示 non-SCMS-T-compliant:
* Connected Bluetooth device does not support SCMS-T audio protection. Content-protected audio may fail to be output.
* 在播放音乐传送 A2DP 数据时，audio_a2dp_hw.c$out_write(..., uint8_t cp_info) 会传入内容保护标识信息，这个信息也会在该函数中打印 DEBUG("cp_info x%x ", cp_info)
* 这个保护信息会传递到 btif_media_task.c$btif_recv_scms_data() 函数中，调用 bta_av_co_cp_set_flag(cp_info & BTA_AV_CP_SCMS_COPY_MASK) 保存起来
* 最后在函数　btif_media_send_vendor_selected_codec()　中调用 bta_av_co_cp_get_flag() 写入 A2DP 数据包，拥有内容保护信息的数据头部格式为：
* A2DP
    Role: Master (Audio Source)
    Contents Protection header
        Cp-bit: 1
        L-bit: 1
    Codec: APT-X
    Audio Frame: 0x 27 8b 3e 8b 3e a9 1f 8e e0 ...
* 即音频数据包包含一个 Contents Protection 头部信息，其中 Cp-bit L-bit 11 表示禁止拷贝（copy prohibited）
* 其他的值包括 copy allowed (00), copy once (10)，如果对方设备不支持 SCMS-T 则不会有这个头部
* 但如果是受版权保护的音乐，对方设备不支持 SCMS-T 的话会导致播放失败，问题 LAT1SYS228 有更详细的关于这个问题的信息
* 其中当使用非 SCMS-T 设备播放受保护内容时会提示："Error occurred before play This content is unable to play(0)(2)(0)"
* 原本 Contents Protection 头部的信息的值是 11，即 copy prohibited，这会导致对方设备接收数据后如果进行拷贝会失败
* 后来问题 LAT1SYS1538 将这个值改成了 00，使音乐可以任意拷贝
* 宏 AUDIO_SCMST 定义在 system/media/audio/include/system/audio.h 文件中
```

OBEX/OPP/PBAP/MAP
```
发送文件
* BluetoothOppReceiver.onReceive() ACTION_DEVICE_SELECTED: pick a device to send
* - BluetoothOppManager.getInstance(context).startTransfer(remoteDevice)
* Create a new InsertShareInfoThread(), and call InsertShareInfoThread.start() => InsertShareInfoThread.run()
* InsertShareInfoThread.insertSingleShare() or InsertShareInfoThread.insertMultipleShare()
* - mContext.getContentResolver().insert(BluetoothShare.CONTENT_URI, values)
* BluetoothOppService.BluetoothShareContentObserver.onChange()
* BluetoothOppService.updateFromProvider(): create a new UpdateThread and start => UpdateThread.run()
* BluetoothOppService.insertShare/updateShare(): create a new BluetoothOppTransfer and start
* BluetoothOppTransfer.start(): if DIRECTION_OUTBOUND then call startConnectSession()
* BluetoothOppTransfer.startConnectSession(): create a new SocketConnectThread and start
* SocketConnectThread.run(): wait connect and then send TRANSPORT_CONNECTED to mSessionHandler
* BluetoothOppTransfer.EventHandler.handleMessage(TRANSPORT_CONNECTED)
* BluetoothOppTransfer.startObexSession() DIRECTION_OUTBOUND
* - create a new BluetoothOppObexClientSession and start
* BluetoothOppObexClientSession.ClientThread.run() "BtOppObexClient Start!"
* BluetoothOppObexClientSession.ClientThread.doSend()
* BluetoothOppObexClientSession.ClientThread.sendFile()
---
* BluetoothOppReceiver.onReceive() ACTION_OPEN/LIST "android.btopp.intent.action.OPEN/LIST"
* - if DIRECTION_OUTBOUND then start BluetoothOppTransferActivity with related uri
* BluetoothOppTransferActivity.onCreate() => get mUri and mTransInfo from Intent and setUpDialog():
* - if DIALOG_SEND/RECEIVE_ONGOING: mNegativeButtonText/mPositiveButtonText = download_cancel/ok: "Stop/Hide"
* BluetoothOppTransferActivity.onClick() BUTTON_NEGATIVE to Stop sending
* - getContentResolver().delete(mUri, null, null)
* - getSystemService(NOTIFICATION_SERVICE)).cancel(mTransInfo.mID)
---
发送文件等待对方接收时取消
* Master  Final Packet         Conn.     26                   0:04:55.136594  #1 OBEX 发起连接
* Slave   Final Packet         OK        26  00:00:00.030980  0:04:55.167574  #2 对方接受连接
* Master  More Packets Follow  Put      203  00:00:00.052447  0:04:55.220021  #3 OBEX 发送数据等待对方接收
* Master  0x18     12          DISC          00:00:09.947835  0:05:05.167856  #4 10s后取消发送，RFCOMM 发起断连
---
发送文件正常流程
* Master  Final Packet         Conn.                          0:02:34.939579  #1 OBEX 发起连接
* Slave   Final Packet         OK        26  00:00:00.029467  0:02:34.969046  #2 对方接受连接
* Master  More Packets Follow  Put      205  00:00:00.048157  0:02:35.017203  #3 Put 第一包数据等待对方接收
* Slave   Final Packet         Continue  22  00:00:27.179526  0:03:02.196729  #4 对方27s后确认接收，发送 Continue
* Master  Final Packet         Put       25  00:00:00.019530  0:03:02.216259  #5 发送 Put 的 Final 包表示发送完毕
* Slave   Final Packet         OK        25  00:00:00.056341  0:03:02.272600  #6 对方 OK
* Master  Final Packet         Disc.     22  00:00:00.057979  0:03:02.330579  #7 断连 OBEX
* Slave   Final Packet         OK        22  00:00:00.031721  0:03:02.362300  #8 对方 OK
```

BLE Profiles Debug
```
$ adb shell setprop log.tag.tosbt DEBUG
$ grep -E "adapter state changed|setProfileServiceState|onProfileServiceStateChange"
$ grep -E " ANS| FMP| PASS | TIME  | PXP|btm_acl_created|btm_sec_disconnected"
$ "startANPServer|startPASPServer|startFMPTarget|startTIPServer|startPXPMonitor"
$ "stopANPServer|stopFMPTarget|stopPASPServer|stopPXPMonitor|stopTIPServer"
$ "connectTIP|connectANP|connectPXP|connectPASP|connectFMP"
```

BLE
```
BLE scanning (device searching)
* if using startScan() to perform ble device searching, the result scan results can be received only when GPS is ON  
* batch scan doesn't have this limitation 
* BluetoothLeScanner.startScan(List<ScanFilter> filters, ScanSettings settings, ...)
* startScan 在搜索BLE设备时可以通过 filters 参数设置过滤条件，可以指定多个条件，只要一个条件满足就会上报结果
* 每个 ScanFilter 可以指定设备的名字、设备的地址、服务UUID、服务数据、厂商数据等
* BluetoothLeScanner.startScan 后等注册 clientIf 完成后，在 onClientRegistered 中调用 GattService 的 startScan 真正执行搜索
* 然后，GattService 再调用 ScanManager 的　startScan，然后 ScanManager 调用 configureScanFilters 设置过滤条件
* ScanManager.configureScanFilters -> ScanManager.addFilterToController -> gattClientScanFilterAddNative ->
* gattClientScanFilterAddRemoveNative -> btgatt_interface_t.btgatt_client_interface_t->scan_filter_add_remove ->
* btif_gattc_scan_filter_add_remove -> BTA_DmBleCfgFilterCondition
* 搜到BLE设备后，GattService.onScanResult 会收到设备信息，该函数还会调用 matchesFilters 判断过滤条件是否满足
* 在 GattService.onScanResult 中查看服务数据的代码：
ScanRecord record = result.getScanRecord();
Map<ParcelUuid, byte[]> serviceData = record.getServiceData();
if (serviceData == null || serviceData.isEmpty()) {
  Log.e(TAG, "onScanResult serviceData is empty");
} else {
  for (Map.Entry<ParcelUuid, byte[]> entry : serviceData.entrySet()) {
    String data = new String(entry.getValue());
    Log.e(TAG, "onScanResult uuid " + entry.getKey().toString() + " data " + data);
  }
}
---
* BLE ANS 没有通知提示问题的确认
* 1. 对应的开关有没有打开：Bluetooth Settings | Menu | Bluetooth Low Energy | Alert Notification Detail Setting | check related items ON
* 2. 有通知出现到通知栏，并且该通知有震动或铃声或闪光的设置
* 3. APP的Notifications权限有没有禁用，如果禁用了就不会有通知，cancelflg将为true
* => NotificationManagerService.java$buzzBeepBlinkLocked(record)
* => NotifyAnsUpdate(record, (buzz || beep || blink))
*    03:50:00.156  9895  9895 D ANS     : mAlertReceiver onReceive()
*    03:50:00.156  9895  9895 D ANS     :     action = ans.action.NEW_ALERT
*    03:50:00.156  9895  9895 D ANS     :     ledOffMS = 0
*    03:50:00.156  9895  9895 D ANS     :     defaults = 0
*    03:50:00.156  9895  9895 D ANS     :     count = 1
*    03:50:00.156  9895  9895 D ANS     :  recordID: 0 cancelflg: true pkgname: android.schedulememo
*    03:50:00.156  9895  9895 D ANS     : catOrd: 11 sendMsg: false
* 其中 sendMsg: false 表示不会发送给蓝牙穿戴设备，可以与 cancelflg 为 true 或 pkgname 有关
* ---
* Guest用户使用BLE profiles的限制：
* guest user cannot receive FMP notification and the time is also not synced using TIP  
* it is needed to switch to owner user
* ---
* ELECOM M-BT11BB Series BLE Mouse
* 搜索配对连接，鼠标不摇动可以成功连上，摇动鼠标则加快连接  
* 连接后在手机上主动断开，再点击手机上的鼠标去连接，需要摇动鼠标才能连上，如果不摇动连接会失败  
* 如果主动断开后只摇动鼠标而不主动选择手机上的鼠标去连接，也会连接失败（因为主动断开的情况下，手机不会发起背景连接） 
```

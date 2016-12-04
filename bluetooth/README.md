
流程关键字
```
* BluetoothManagerService|bt_vendor|BT_VND_OP_POWER_CTRL|disable timeout
* btm_acl_created|L2CA_DisconnectReq|W4_L2CAP_DISC_RSP|btm_sec_disconnected
* A2DP COMMAND|skt_connect|skt_disconnect|AV Sevent
* AG SCO State|AG_AUDIO|setBluetoothScoOn
* HFP AT cmd|bta_ag_hfp_result
```

蓝牙开关
```
* BluetoothAdapter.STATE_OFF (10) -> STATE_BLE_TURNING_ON (14) -> (BT_VND_OP_POWER_CTRL: On) ->
* STATE_BLE_ON (15) -> STATE_TURNING_ON (11) -> STATE_ON (12)
* BluetoothAdapter.STATE_ON (12) -> STATE_TURNING_OFF (13) -> STATE_BLE_ON (15) ->
* STATE_BLE_TURNING_OFF (16) -> (BT_VND_OP_POWER_CTRL: Off) -> STATE_OFF (10)
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


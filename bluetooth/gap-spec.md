
## 9. Operational modes and procedures - LE physical transport（LE链路相关的模式和过程）

The following modes and procedures are defined for use over an LE physical transport (several different
modes and procedures may be performed simultaneously):
- Broadcast mode and observation procedure
- Discovery modes and procedures
- Connection modes and procedures
- Bonding modes and procedures

可以在一条LE链路上使用的模式和过程定义如下（其中的一些模式和过程可以同时进行）：
- 广播模式（发送无连接的advertising包）和发现过程（做BLE scanning）
- 设备可搜索模式（一般是发送可连接的advertising包）和设备搜索过程（做BLE scanning）
- 设备可连接模式（发送可连接advertising包）和设备连接过程（做BLE initiating）

The Host shall configure the Controller with its local Link Layer feature
information as defined in [Vol. 6] Part B Section 4.6 before performing any of
the above modes and procedures.

[TODO]???

### 9.1 Broadcast mode and observation procedure

The broadcast mode and observation procedure allow two devices to
communicate in a unidirectional connectionless manner using the advertising
events.

广播模式和发现过程允许两个设备通过advertising事件进行单向无连接沟通。

GAP角色应支持的模式或过程：
![Broadcast mode and observation procedure requirements](./assets/broadcast-mode-and-observation-procedure-requirements.png)
*其中E（Excluded）表示该模式或过程对当前角色不适用

**Broadcast Mode**

The broadcast mode provides a method for a device to send connectionless
data (ADV_NONCONN_IND or ADV_SCAN_IND) in advertising events.
The advertising data shall be formatted using the Advertising Data (AD) type
format.
A device in the broadcast mode shall not set the ‘LE General Discoverable Mode’
flag or the ‘LE Limited Discoverable Mode’ flag in the Flags AD Type.

Note: All data sent by a device in the broadcast mode is considered unreliable
since there is no acknowledgement from any device that may have received
the data.

**Observation Procedure**

The observation procedure provides a method for a device to receive
connectionless data from a device that is sending advertising events.
A device performing the observation procedure may use passive scanning or
active scanning (get SCAN_RSP data) to receive advertising events.

LE Privacy: When a device performing the observation procedure receives a resolvable
private address in the advertising event, the device may resolve the private address
by using the resolvable private address resolution procedure.

### 9.2 Discovery modes and procedures



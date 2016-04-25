
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

\*其中E（Excluded）表示该模式或过程对当前角色不适用

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

All devices shall be in either non-discoverable mode or one of the discoverable
modes (general/limited discoverable mode).

GAP角色应支持的模式或过程：
```c
Modes and procedures        Peripheral
--------------------------------------
1. Non-Discoverable mode       [M]
2. Limited Discoverable mode   [O]
3. General Discoverable mode   [C] if 2. is not supported then 3. is mandatory, otherwise optional.
4. Name Discovery procedure    [O]

Modes and procedures        Central
--------------------------------------
1. Limited Discovery procedure [O]
2. General Discovery procedure [M]
3. Name Discovery procedure    [O]
```

**Non-Discoverable Mode**

A Peripheral device in the non-connectable mode may send ADV_NONCONN_IND/ADV_SCN_IND advertising packets
or may not send advertising packets.
The advertising data shall not set ‘LE General/Limited Discoverable Mode’ flag in the Flags AD type.

**Limited/General Discoverable Mode**

The limited/general discoverable mode is typically used when the device is intending to be
discoverable for a limited/long period of time.

```c
Discoveralbe Time    a limited period of time         a long period of time
                     no longer than T_GAP(lim_adv_timeout) 180s
Can be discovered by    limited or general discovery procedure  general discovery procedure
Advertising Packets       ADV_NONCONN_IND/ADV_IND/ADV_SCAN_IND/SCAN_RSP
LE Limited Discoverable Mode flag        1             0
LE General Discoveralbe Mode flag        0             1
For LE-only device:
    BR/EDR Not Supported                      1
    Simultaneous LE and BR/EDR to Same Device Capable (Controller) 0
    Simultaneous LE and BR/EDR to Same Device Capable (Host) 0
Should also include for faster connectivity experience
    TX Power Level, Local Name, Service UUIDs, Slave Connection Interval Range
Advertising Filter Policy                Process SCAN_REQ and CONNECT_REQ from all devices
The device shall remain in general discoverable mode until a connection is
established or the Host terminates the mode.
Note:
    Data that change frequently should be placed in the advertising data and
static data should be placed in the scan response data.
    The choice of advertising interval is a trade-off between power
consumption and device discovery time.
```

**Limited/General Discovery Procedure**
```c
Receive data from device       in Limited discoverable mode    in Limited and Gernal discoverable mode
Shall set Sanner_Filter_Policy                   process all advertising packets
Should set scan interval
Should set scan window
Should configure controller                      use active scanning
Should continue scan           at least T_GAP(lim_disc_scan_min) 10.24s   at least T_GAP(gen_disc_scan_min) 10.24s
Shall accept advertising data when   LE Limited Discoverable Flag is 1   LE Limited or General Discoverable Flag is 1
```
???
The host shall ignore the 'Simultaneous LE and BR/EDR to Same Device
Capable (Controller)' and 'Simultaneous LE and BR/EDR to Same Device
Capable (Host)' bits in the Flags AD type.

**Name Discovery Procedure**

If the complete device name is not acquired while performing either the limited
discovery procedure or the general discovery procedure, then the name
discovery procedure may be performed.

The name discovery procedure shall be performed as follows:
- The Host shall establish a connection using one of the connection establishment procedures
- The Host shall read the device name characteristic using the GATT procedure - Read Using Characteristic UUID
- The connection may be terminated after the GATT procedure has completed

### 9.3 Connection Modes and Procedures

When devices are connected, the parameters of the connection can be
updated with the Connection Parameter Update procedure.

GAP角色应支持的模式或过程：
```c
Broadcaster和Observer这两个角色只支持Non-connectable Mode,其他连接模式和所有的连接过程都不支持。

Modes and Procedures                          Peripheral
--------------------------------------------------------
Non-connectable mode                          M
Undirected connectable mode                   M
Directed connectable mode                     O
Connection parameter update procedure         O
Terminate connection procedure                M

Modes and Procedures                          Central
--------------------------------------------------------
Auto connection establishment procedure       O
Selective connection establishment procedure  O
General connection establishment procedure    C *如果支持LE Privacy则Mandatory，否则Optional
Direct connection establishment procedure     M
Connection parameter update procedure         M
Terminate connection procedure                M
```

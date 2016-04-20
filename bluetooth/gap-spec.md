
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

![Broadcast mode and observation procedure requirements](./assets/broadcast-mode-and-observation-procedure-requirements.png)

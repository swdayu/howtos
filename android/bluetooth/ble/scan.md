

# 设备搜索参数配置（ScanSettings）

扫描方式（scan mode）
- SCAN_MODE_OPPORTUNISTIC (-1) 被动扫描（passive scan）
- SCAN_MODE_LOW_POWER (0) 功耗小但设备搜索效率也低
- SCAN_MODE_BALANCED (1) 平衡模式，功耗和效率相平衡
- SCAN_MODE_LOW_LATENCY (2) 低延时模式，使用最大的功耗最大效率的搜索设备

回调方式（callback type）
- CALLBACK_TYPE_ALL_MATCHES (1) 收到的每个满足过滤条件的advertisement包都会回报
- CALLBACK_TYPE_FIRST_MATCH (2) 满足条件的设备的相同advertisement包只会回报一次，不会重复回报
- CALLBACK_TYPE_MATCH_LOST (4) 满足条件的设备第一次回报之后，出现一段时间都没有收到这个设备的包时回调一次

保存相同匹配包的数量
- MATCH_NUM_ONE_ADVERTISEMENT (1) 满足条件的相同advertisement包只要保存一个
- MATCH_NUM_FEW_ADVERTISEMENT (2) 保存少量几个
- MATCH_NUM_MAX_ADVERTISEMENT (3) 尽可能多的保存，根据蓝牙芯片的能力尽可能多的保存

匹配方式
- MATCH_MODE_AGGRESSIVE (1) 收到满足过滤条件的包都回报，不管信号强度以及成功接收的频率
- MATCH_MODE_STICKY (2) 信号强度高以及成功接收频率高的包才回报

返回设备哪些信息
- SCAN_RESULT_TYPE_FULL (0) 尽可能返回设备的所有信息，包括设备名称、地址、信号强度值(RSSI)、时间戳、advertising数据，scan response数据
- SCAN_RESULT_TYPE_ABBREVIATED (1) 返回设备的名称、地址、信号强度、时间戳

回报延时
- mReportDelayMillis 如果设置为0表示收到立即回报，大于0表示延时回报，蓝牙芯片需要保存收到的结果，直到延时到期或缓存满时才回报

内部设置函数及默认值
```java
private ScanSettings(int scanMode, int callbackType, 
  int scanResultType, long reportDelayMillis, int matchMode, int numOfMatchesPerFilter);

public static final class Builder {
  private int mScanMode = SCAN_MODE_LOW_POWER;
  private int mCallbackType = CALLBACK_TYPE_ALL_MATCHES;
  private int mScanResultType = SCAN_RESULT_TYPE_FULL;
  private long mReportDelayMillis = 0;
  private int mMatchMode = MATCH_MODE_AGGRESSIVE;
  private int mNumOfMatchesPerFilter  = MATCH_NUM_MAX_ADVERTISEMENT;
  //...
}
```

# Bluedroid

References
- http://androidxref.com/

Bluedroid folders
- **android/external/bluetooth/bluedroid/** (L)
- **android/system/bt/** (M)
  - **audio_a2dp_hw**
  - **bta**: bluetooth application profile layer
  - **btif**: bluetooth interface between java and c
  - **conf**: config files for bluedroid
  - **doc**: some documents for bluedroid
  - **embdrv**: sbc encoder and decoder
  - **gki**: generic kernel interface, defined a tiny embedded os based on pthread
  - **hci**: interface between bluetooth host and controller
  - **include**: including files
  - **main**: core initialization function for bluedroid
  - **osi**: os interfaces for gki
  - **stack**: bluetooth stack protocols
  - **test**: a test tool for bluedroid
  - **tools**: helper scripts
  - **udrv**: implementation for uipc
  - **utils**: helper functions for bluedroid
  - **vnd**: implementation for vendor features
  - **wipowerif**
  - Android.mk: an android makefile for building bluedroid
  - CleanSpec.mk: an android makefile for cleaning

Bluedroid core modules
- **btif** (Communicate with Java using JNI)
- **bta** (BT Profiles)
- **stack** (BT Protocols)
- **hci** (Communicate with BT Controller)

Bluetooth related folders on Android
- android/frameworks/**base**/core/java/android/bluetooth/
- android/frameworks/**opt**/bluetooth/
- android/packages/apps/**bluetooth**/
- android/packages/apps/**settings**/src/com/android/settings/bluetooth/
- android/kernel/**net**/bluetooth/
- android/kernel/include/**net**/bluetooth/
- android/kernel/**drivers**/bluetooth/
- android/hardware/**libhardware**/include/hardware/
- android/**vendor**/[name]/(bluetooth_app)

Bluedroid run in the process of `com.android.bluetooth`.
There are 4 tasks: BTIF_TASK, BTU_TASK, A2DP_MEDIA_TASK, GKI_TIMER_TASK. 
There is a RX thread of `bt_hc_workder_thread` used to read data from lower layer such as uart.


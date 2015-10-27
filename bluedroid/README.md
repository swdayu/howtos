# Bluedroid

References:
- http://androidxref.com/

Bluedroid folder tree:
```
external/bluetooth/bluedroid/
- audio_a2dp_hw
- bta: bluetooth application profile layer
- btif: bluetooth interface between java and c
- conf: config files for bluedroid
- doc: some documents for bluedroid
- embdrv: sbc encoder and decoder
- gki: generic kernel interface, defined a tiny embedded os based on pthread
- hci: interface between bluetooth host and controller
- include: including files
- main: core initialization function for bluedroid
- osi: os interfaces for gki
- stack: bluetooth stack protocols
- test: a test tool for bluedroid
- tools: helper scripts
- udrv: implementation for uipc
- utils: helper functions for bluedroid
- vnd: implementation for vendor features
- wipowerif
- Android.mk: an android makefile for building bluedroid
- CleanSpec.mk: an android makefile for cleaning
```

Bluedroid layers:
```
--------------------------------------
Java World
--------------------------------------
btif (Communicate with Java using JNI)
--------------------------------------
bta (BT Profiles)
--------------------------------------
stack (BT Protocols)
--------------------------------------
hci (Communicate with BT Controller)
--------------------------------------
```


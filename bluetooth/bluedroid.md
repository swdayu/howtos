
Bluetooth Profiles and Protocols
- A2DP: Advanced Audio Distribution Profile  
  Roles - Source (SRC) and Sink (SNK)    
  Example - Phone (SRC) distributes music to  headset (SNK)  
  Protocol Stack - A2DP | AVDTP | L2CAP  
  AVDTP - Audio/Video Distribution Transport Protocol  
  
- AVRCP: Aduio/Video Remote Control Profile  
  Roles - Target (TG) and Controller (CT)  
  Example - Remote headset (CT) controls audio player's volumn on phone (TG)  
  Protocol Stack - AVRCP | AVCTP | L2CAP  
  AVCTP - Audio/Video Control Transport Protocol  

- HSP: Headset Profile  
  Roles - Audio Gateway (AG) and Headset (HS)  
  Example - Use a headset (HS) make a call on phone (AG)   
  Protocol Stack - HSP | RFCOMM | L2CAP    
  RFCOMM - Serial Cable Emulation Protocol based on ETSI TS 07.10

- HFP: Handsfree Profile  
  Roles - Audio Gateway (AG) and Handsfree (HF)   
  Example - Use a headset (HF) make a call on phone (AG)   
  Protocol Stack - HFP | RFCOMM | L2CAP   

- HID: Human Interface Device Profile   
  Roles - HID Device and HID Host   
  Example - Use a bluetooth mouse (Device) on PC (Host)   
  Protocol Stack - HID | L2CAP   

- HDP: Health Device Profile   
  Roles - Source and Sink   
  Example - Transfer data from blood pressure meter (Source) to phone (Sink)   
  Protocol Stack - HDP | MACP | L2CAP   

- MAP: Message Access Profile   
  Roles - Message Server and Client Equipment (MSE and MCE)   
  Example - PC (MCE) send/receive messages via a mobile phone (MSE)   
  Protocol Stack - MAP | GOEP | OBEX | L2CAP   

- PBAP: Phonebook Access Profile   
  Roles - Phonebook Server and Client Equipment (PSE and PCE)   
  Example - Carkit (PCE) read phonebook on a phone (PSE)   
  Protocol Stack - PBAP | GOEP | OBEX | L2CAP   

- SAP: SIM Access Profile   
  Roles - Client and Server   
  Example - a car phone (Client) uses mobile phone's SIM card (Server)   
  Protocol Stack - SAP | RFCOMM | L2CAP   

- GOEP: Generic Object Exchange Profile   
  Roles - Clinet and Server   
  Protocol Stack - GOEP | OBEX | L2CAP   

- PAN: Personal Area Networking Profile   
  Roles - Network Access Point (NAP) and PAN User (PANU)  
  Protocol Stack - PAN | BNEP | L2CAP   

- Profiles based on GOEP: OPP FTP MAP PBAP SYNCH  
  Profiles based on RFCOMM: HSP HFP SAP SPP DUN

Bluedroid Modules
- bta_ag: audio gatway, hfp AG role
- bta_ar: audio/video registration module
- bta_av: audio/video module
- bta_dm: device manager module
- bta_fs: file system module
- bta_gatt: generic attribute profile module
- bta_hd: hid device role
- bta_hf_client: handsfree client, hfp HF role
- bta_hh: hid host role
- bta_hl: health device profile module
- bta_jv: java api for JSR82 specification
- bta_mce: map mce role
- bta_pan: personal area networking profile module
- bta_pb: phone book access profile server module
- bta_sys: system manager module
- stack_a2dp: a2dp profile
- stack_avdt: avdtp protocol
- stack_avrc: avrcp profile
- stack_avct: avctp protocol
- stack_bnep: bnep protocol
- stack_btm: bluetooth manager
- stack_btu: bluetooth upper layer
- stack_gap: gap profile
- stack_gatt: gatt profile
- stack_hcic: hci command module
- stack_hid: hid profile
- stack_l2cap: l2cap protocol
- stack_mcap: multi-channel adaptation protocol
- stack_pan: pan profile
- stack_rfcomm: rfcomm protocol
- stack_sdp: sdp profile
- stack_smp: smp protocol
- stack_srvc: gatt services


# BLE (bluetooth low energy)

Use whitelist to connect
```c
[stack/btm/btm_ble_bgconn.c] btm_ble_start_auto_conn
[stack/hcic/hciblecmds.c] btsnd_hcic_ble_create_ll_conn
[stack/include/hcidefs.h] HCI_BLE_CREATE_LL_CONN
```

Use direct address to connect
```c
[stack/l2cap/l2c_ble.c] l2cble_init_direct_conn
[stack/hcic/hciblecmds.c] btsnd_hcic_ble_create_ll_conn
[stack/include/hcidefs.h] HCI_BLE_CREATE_LL_CONN
```

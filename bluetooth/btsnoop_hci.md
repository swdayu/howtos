
## 实现细节
- system/bt/hci/include/btsnoop.h
- system/bt/hci/include/btsnoop_mem.h
- system/bt/hci/src/btsnoop.c
- system/bt/hci/src/btsnoop_mem.c
- system/bt/hci/src/btsnoop_net.c

```c

const btsnoop_t* btsnoop_get_interface() {
  stack_config = stack_config_get_interface();
  return &interface;
}

static const btsnoop_t interface = {
  set_api_wants_to_log,
  capture
};


```

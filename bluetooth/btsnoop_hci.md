
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


//[hci_layer_get_interface]@system/bt/hci/src/hci_layer.c
const hci_t* hci_layer_get_interface() {
  buffer_allocator = buffer_allocator_get_interface();
  hal = hci_hal_get_interface();
  btsnoop = btsnoop_get_interface();                     // get btsnoop interface
  hci_inject = hci_inject_get_interface();
  packet_fragmenter = packet_fragmenter_get_interface();
  vendor = vendor_get_interface();
  low_power_manager = low_power_manager_get_interface();
  init_layer_interface();
  return &interface;
}

//[transmit_fragment]@system/bt/hci/src/hci_layer.c
static void transmit_fragment(BT_HDR* packet, bool send_transmit_finished) {
  uint16_t event = packet->event & MSG_EVT_MASK;
  serial_data_type_t type = event_to_data_type(event);
  btsnoop->capture(packet, false);                       // capture btsnoop tx log
  hal->transmit_data(type, packet->data + packet->offset, packet->len);
  if (event != MSG_STACK_TO_HC_HCI_CMD && send_transmit_finished)
    buffer_allocator->free(packet);
}

//[hal_says_data_ready]@system/bt/hci/src/hci_layer.c
static void hal_says_data_ready(serial_data_type_t type) {
  // ... ...
  if (incoming->state == FINISHED) {
      incoming->buffer->len = incoming->index;
      btsnoop->capture(incoming->buffer, true);          // capture btsnoop rx log
      if (type != DATA_TYPE_EVENT) {
        packet_fragmenter->reassemble_and_dispatch(incoming->buffer);
      } else if (!filter_incoming_event(incoming->buffer)) {
        // Dispatch the event by event code
        uint8_t *stream = incoming->buffer->data;
        uint8_t event_code;
        STREAM_TO_UINT8(event_code, stream);
        data_dispatcher_dispatch(
          interface.event_dispatcher,
          event_code,
          incoming->buffer
        );
      }
      // We don't control the buffer anymore
      incoming->buffer = NULL;
      incoming->state = BRAND_NEW;
      hal->packet_finished(type);
      // We return after a packet is finished for two reasons:
      // 1. The type of the next packet could be different.
      // 2. We don't want to hog cpu time.
      return;
    }
}

```


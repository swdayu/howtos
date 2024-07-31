
```c
#define BTA_AV_ENABLE_EVT       0       /* AV enabled */
#define BTA_AV_REGISTER_EVT     1       /* registered to AVDT */
#define BTA_AV_OPEN_EVT         2       /* connection opened */
#define BTA_AV_CLOSE_EVT        3       /* connection closed */
#define BTA_AV_START_EVT        4       /* stream data transfer started */
#define BTA_AV_STOP_EVT         5       /* stream data transfer stopped */
#define BTA_AV_PROTECT_REQ_EVT  6       /* content protection request */
#define BTA_AV_PROTECT_RSP_EVT  7       /* content protection response */
#define BTA_AV_RC_OPEN_EVT      8       /* remote control channel open */
#define BTA_AV_RC_CLOSE_EVT     9       /* remote control channel closed */
#define BTA_AV_REMOTE_CMD_EVT   10      /* remote control command */
#define BTA_AV_REMOTE_RSP_EVT   11      /* remote control response */
#define BTA_AV_VENDOR_CMD_EVT   12      /* vendor dependent remote control command */
#define BTA_AV_VENDOR_RSP_EVT   13      /* vendor dependent remote control response */
#define BTA_AV_RECONFIG_EVT     14      /* reconfigure response */
#define BTA_AV_SUSPEND_EVT      15      /* suspend response */
#define BTA_AV_PENDING_EVT      16      /* incoming connection pending:
                                         * signal channel is open and stream is not open
                                         * after BTA_AV_SIG_TIME_VAL ms */
#define BTA_AV_META_MSG_EVT     17      /* metadata messages */
#define BTA_AV_REJECT_EVT       18      /* incoming connection rejected */
#define BTA_AV_RC_FEAT_EVT      19      /* remote control channel peer supported features update */
#define BTA_AV_BROWSE_MSG_EVT   20      /* Browse MSG EVT */
#define BTA_AV_MEDIA_SINK_CFG_EVT    21      /* sending command to Media Task */
#define BTA_AV_MEDIA_DATA_EVT   22      /* sending command to Media Task */
#define BTA_AV_SM_PRIORITY_EVT  23       /* if priority of device is 0 then move back to idle */

void btif_rc_handler(tBTA_AV_EVT event, tBTA_AV *p_data):
  handle_rc_connect(&(p_data->rc_open));
  handle_rc_disconnect( &(p_data->rc_close) );
  handle_rc_passthrough_cmd( (&p_data->remote_cmd) );
  handle_rc_passthrough_rsp( (&p_data->remote_rsp) );
  handle_rc_features();
  handle_rc_metamsg_cmd(&(p_data->meta_msg));
  handle_rc_browsemsg_cmd(&(p_data->browse_msg));
```

```cpp
void InputReader::loopOnce()
  size_t count = mEventHub->getEvents(timeoutMillis, mEventBuffer, EVENT_BUFFER_SIZE);
  processEventsLocked(mEventBuffer, count);
  
struct RawEvent {
    nsecs_t when;
    int32_t deviceId;
    int32_t type;
    int32_t code;
    int32_t value;
};

void InputReader::processEventsLocked(const RawEvent* rawEvents, size_t count)
  int32_t deviceId = rawEvents->deviceId;
  processEventsForDeviceLocked(deviceId, rawEvent, batchSize);
  
void InputReader::processEventsForDeviceLocked(
  int32_t deviceId, const RawEvent* rawEvents, size_t count)
  device->process(rawEvents, count);
  
void InputDevice::process(const RawEvent* rawEvents, size_t count)
  for (size_t i = 0; i < numMappers; i++) {
    InputMapper* mapper = mMappers[i];
    mapper->process(rawEvent);
  }
  
InputDevice* InputReader::createDeviceLocked(int32_t deviceId, int32_t controllerNumber,
  const InputDeviceIdentifier& identifier, uint32_t classes)
  device->addMapper(new SwitchInputMapper(device));
  device->addMapper(new VibratorInputMapper(device));
  device->addMapper(new KeyboardInputMapper(device, keyboardSource, keyboardType));
  device->addMapper(new CursorInputMapper(device));
  device->addMapper(new MultiTouchInputMapper(device));
  device->addMapper(new SingleTouchInputMapper(device));
  device->addMapper(new JoystickInputMapper(device));
  
"android/frameworks/base/data/keyboards/AVRCP.kl"

```

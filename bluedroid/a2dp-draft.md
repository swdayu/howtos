
```c
struct audio_module HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .version_major = 1,
        .version_minor = 0,
        .id = AUDIO_HARDWARE_MODULE_ID,
        .name = "A2DP Audio HW HAL",
        .author = "The Android Open Source Project",
        .methods = &hal_module_methods, ////
    },
};

static struct hw_module_methods_t hal_module_methods = {
    .open = adev_open,                 ////
};

int adev_open(const hw_module_t* module, const char* name, hw_device_t** device):
  adev->device.common.tag = HARDWARE_DEVICE_TAG;
  adev->device.common.version = AUDIO_DEVICE_API_VERSION_2_0;
  adev->device.common.module = (struct hw_module_t *) module;
  adev->device.common.close = adev_close;
  adev->device.init_check = adev_init_check;
  adev->device.set_voice_volume = adev_set_voice_volume;
  adev->device.set_master_volume = adev_set_master_volume;
  adev->device.set_mode = adev_set_mode;
  adev->device.set_mic_mute = adev_set_mic_mute;
  adev->device.get_mic_mute = adev_get_mic_mute;
  adev->device.set_parameters = adev_set_parameters;
  adev->device.get_parameters = adev_get_parameters;
  adev->device.get_input_buffer_size = adev_get_input_buffer_size;
  adev->device.open_output_stream = adev_open_output_stream;    ////
  adev->device.close_output_stream = adev_close_output_stream;  ////
  adev->device.open_input_stream = adev_open_input_stream;      ////
  adev->device.close_input_stream = adev_close_input_stream;    ////
  adev->device.dump = adev_dump;
  *device = &adev->device.common;
  
int adev_open_output_stream(struct audio_hw_device *dev, ..., struct audio_stream_out **stream_out, ...):
  out->stream.common.get_sample_rate = out_get_sample_rate;
  out->stream.common.set_sample_rate = out_set_sample_rate;
  out->stream.common.get_buffer_size = out_get_buffer_size;
  out->stream.common.get_channels = out_get_channels;
  out->stream.common.get_format = out_get_format;
  out->stream.common.set_format = out_set_format;
  out->stream.common.standby = out_standby;               ////
  out->stream.common.dump = out_dump;
  out->stream.common.set_parameters = out_set_parameters; ////
  out->stream.common.get_parameters = out_get_parameters;
  out->stream.common.add_audio_effect = out_add_audio_effect;
  out->stream.common.remove_audio_effect = out_remove_audio_effect;
  out->stream.get_latency = out_get_latency;
  out->stream.set_volume = out_set_volume;
  out->stream.write = out_write;                          ////
  out->stream.get_render_position = out_get_render_position;
  *stream_out = &out->stream;
  a2dp_open_ctrl_path(&out->common):
    check_a2dp_ready(common);
int adev_open_input_stream(struct audio_hw_device *dev, ..., struct audio_stream_in **stream_in, ...):
  in->stream.common.get_sample_rate = in_get_sample_rate;
  in->stream.common.set_sample_rate = in_set_sample_rate;
  in->stream.common.get_buffer_size = in_get_buffer_size;
  in->stream.common.get_channels = in_get_channels;
  in->stream.common.get_format = in_get_format;
  in->stream.common.set_format = in_set_format;
  in->stream.common.standby = in_standby;
  in->stream.common.dump = in_dump;
  in->stream.common.set_parameters = in_set_parameters;
  in->stream.common.get_parameters = in_get_parameters;
  in->stream.common.add_audio_effect = in_add_audio_effect;
  in->stream.common.remove_audio_effect = in_remove_audio_effect;
  in->stream.set_gain = in_set_gain;
  in->stream.read = in_read;                              ////
  in->stream.get_input_frames_lost = in_get_input_frames_lost;
  *stream_in = &in->stream;
  a2dp_open_ctrl_path(&in->common):
    check_a2dp_ready(common);
  a2dp_read_audio_config(&in->common);
  
ssize_t out_write(struct audio_stream_out *stream, const void* buffer, size_t bytes):
ssize_t in_read(struct audio_stream_in *stream, void* buffer, size_t bytes):
  start_audio_datapath(&out->common or &in->common);
  
void adev_close_output_stream(struct audio_hw_device *dev, struct audio_stream_out *stream):
void adev_close_input_stream(struct audio_hw_device *dev, struct audio_stream_in *stream):
  stop_audio_datapath(&out->common or &in->common);

int out_set_parameters(struct audio_stream *stream, const char *kvpairs):
  retval = str_parms_get_str(parms, "closing", keyval, sizeof(keyval));
  out->common.state = AUDIO_A2DP_STATE_STOPPING;
  retval = str_parms_get_str(parms, "A2dpSuspended", keyval, sizeof(keyval));
  suspend_audio_datapath(&out->common, false);
  check_a2dp_stream_started(out);
int out_standby(struct audio_stream *stream):
  if (out->common.state != AUDIO_A2DP_STATE_SUSPENDED)
    retVal =  suspend_audio_datapath(&out->common, true);
```


```c
int check_a2dp_ready(struct a2dp_stream_common *common);
int check_a2dp_stream_started(struct a2dp_stream_out *out);
int start_audio_datapath(struct a2dp_stream_common *common);
int stop_audio_datapath(struct a2dp_stream_common *common);
int suspend_audio_datapath(struct a2dp_stream_common *common, bool standby);
int a2dp_read_audio_config(struct a2dp_stream_common *common);
```

A2DP COMMAND
```c
typedef enum {
    A2DP_CTRL_CMD_NONE,
    A2DP_CTRL_CMD_CHECK_READY,
    A2DP_CTRL_CMD_CHECK_STREAM_STARTED,
    A2DP_CTRL_CMD_START,
    A2DP_CTRL_CMD_STOP,
    A2DP_CTRL_CMD_SUSPEND,
    A2DP_CTRL_GET_AUDIO_CONFIG
} tA2DP_CTRL_CMD;
int a2dp_command(struct a2dp_stream_common *common, char cmd); //INFO("A2DP COMMAND %s", dump_a2dp_ctrl_event(cmd));
```

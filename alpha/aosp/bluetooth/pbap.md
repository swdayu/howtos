
# Phonebook Access Profile

## Contact Sharing
- 只有连上PBAP之后才会在蓝牙设备的信息列表里显示Contact Sharing CheckBox
- 去掉CheckBox的勾选会断掉PBAP连接，并且Reject之后的PBAP连接请求（表示Disable PBAP Profile）
- 只有再次勾选这个CheckBox后，PBAP才能再次连接成功（Enable PBAP Profile）
- M上改掉之后只有在PBAP_CONNECT_RECEIVED以及ACCESS_REJECT才显示Contact Sharing这一项

```
联系人需要设置电话号码，才能正确同步给对方设备
```

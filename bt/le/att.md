
## Attribute Protocol (ATT)

ATT allows a device referred to as the server to expose a set of attributes that describe the services the server support.
And using the ATT, these attributes can be discovered, read, written by a client, and can be indicated and notified by the server.
An attribute on server defined by: an attribute handle, an attribute type, an attribute value, and a set of attribute permissions.

ATT PDUs have six types:
- client send "Request" and require server's "Response"
- client send "Command" to server
- server send "Indication" and require client's "Confirmation"
- server send "Notification" to client

ATT PDUs summary:
```c
Exchange_MTU_Request (0x02)
[2B] Client_Rx_MTU_Size
Exchange_MTU_Response (0x03)
[2B] Server_Rx_MTU_Size
Error_Response (0x01)
[1B] Request_Opcode
[2B] Attribute_Handle
[1B] Error_Code

## obtain (attribute handle, attribute type) pairs in the handle range
Find_Info_Request (0x04)
[2B] Start_Handle
[2B] End_Handle
Find_Info_Response (0x05)
[1B] Format: 0x01 for (handle, 16-bit UUID) pair; 0x02 for (handle, 128-bit UUID) pair
[nB] Handle_Type_Pairs: [2B,2B]... or [2B,16B]...

## obtain (attribute handles) in the range have the attribute type and the attribute value
Find_By_Type_Value_Request (0x06)
[2B] Start_Handle
[2B] End_Handle
[2B] Attribute_Type
[nB] Attribute_Value
Find_By_Type_Value_Response (0x07)
[nB] List_Of_Handle_Info: [2B Found_Handle, 2B Group_End_Handle (or Found_Handle)] ...
```

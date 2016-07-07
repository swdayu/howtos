
## Attribute Protocol (ATT)

ATT allows a device referred to as the server to expose a set of attributes that describe the services the server support. And using the ATT, these attributes can be discovered, read, written by a client, and can be indicated and notified by the server. An attribute on the server contains following information: the attribute handle, the attribute type, the attribute value, and the attribute permissions.

The attribute has following permissions:
- Readable, Writeable, Readable and writable
- Authentication required, No authentication required
- Authorization required, No authorization required
- Encryption required, No encryption required

There are six types of ATT PDUs:
- client send "Request" and require server's "Response"
- client send "Command" to server
- server send "Indication" and require client's "Confirmation"
- server send "Notification" to client

**ExchangeMTU & ErrorResponse**
```c
Exchange_MTU_Request (0x02)
[2B] Client_Rx_MTU_Size
Exchange_MTU_Response (0x03)
[2B] Server_Rx_MTU_Size
Error_Response (0x01)
[1B] Request_Opcode
[2B] Attribute_Handle
[1B] Error_Code

Error Codes
-----------
0x01 - Invalid Handle
0x02 - Read Not Permitted
0x03 - Write Not Permitted
0x04 - Invalid PDU
0x05 - Insufficient Authentication
0x06 - Request Not Supported
0x07 - Invalid Offset
0x08 - Insufficient Authorization
0x09 - Prepare Queue Full
0x0A - Attribute Not Found
0x0B - Attribute Not Long (Read Blob Request)
0x0C - Insufficient Encryption Key Size
0x0D - Invalid Attribute Value Length
0x0E - Unlikely Error
0x0F - Insufficient Encryption
0x10 - Unsupported Group Type
0x11 - Insufficient Resources
0x80 - 0x9F: Application error code defined by a higher layer specification
0xE0 - 0xFF: Common Profile and Service Error Codes defined in CSS spec Part B
0x12 - 0x7F, 0xA0 - 0xDF: Reserved for future use
```

**Find Information**
```c
Find_Info_Request (0x04)
[2B] Start_Handle: started with 0x0001
[2B] End_Handle
Find_Info_Response (0x05)
[1B] Format: 0x01 for (handle, 16-bit UUID) pair; 0x02 for (handle, 128-bit UUID) pair
[nB] List_Of_Handle_Type_Pair: [2B,2B]... or [2B,16B]...

Find_By_Type_Value_Request (0x06)
[2B] Start_Handle: started with 0x0001
[2B] End_Handle
[2B] Attribute_Type
[nB] Attribute_Value
Find_By_Type_Value_Response (0x07)
[nB] List_Of_Handle_Info: [2B Found_Handle, 2B Group_End_Handle (or Found_Handle)] ...
```

**Read Attribute**
```c
Read_By_Type_Request (0x08)
[2B] Start_Handle
[2B] End_Handle
[nB] Attribute_Type: [2B 16-bit UUID] or [16B 128-bit UUID]
Read_By_Type_Response (0x09)
[1B] Length: shall be the size of a Handle_Value_Pair
[nB] List_Of_Handle_Value_Pair: [2B, nB] ...

Read_By_Group_Type_Request (0x10)
[2B] Start_Handle
[2B] End_Handle
[nB] Attribute_Group_Type: [2B 16-bit UUID] or [16B 128-bit UUID]
Read_By_Group_Type_Response (0x11)
[1B] Length: shall be the size of the a Handles_Value_Pair
[nB] List_Of_Handles_Value_Pair: [2B Handle, 2B End_Group_Handle, nB Attribute_Value] ...

Read_Request (0x0A)
[2B] Attribute_Handle
Read_Response (0x0B)
[nB] Attribute_Value

Read_Blob_Request (0x0C)
[2B] Attribute_Handle
[2B] Value_Offset: started from 0
Read_Blob_Response (0x0D)
[nB] Part_Attribute_Value: the length can be 0-byte if no more data

Read_Multiple_Request (0x0E)
[nB] List_Of_Handle
Read_Multiple_Response (0x0F)
[nB] List_Of_Value
```
Note: if the attribute is longer than (ATT_MTU-1) octets, the Read_Blob_Request is the only way to read the additional octets of a long attribute. The first (ATT_MTU-1) octets may be read using a Read_Request, an Handle_Value_Notification or an Handle_Value_Indication.

Note: Long attributes may or may not have their length specified by a higher layer specification. If the long attribute has a variable length, the only way to get to the end of it is to read it part by part until the value in the Read_Blob_Response has a length shorter than (ATT_MTU-1) or an Error Response with the error code «Invalid Offset».

Note: the value of a Long Attribute may change between one Read_Blob_Request and the next Read_Blob_Request. A higher layer specification should be aware of this and define appropriate behavior.

The part attribute value shall be set to part of the value of the attribute identified by the attribute handle and the value offset in the request. If the value offset is equal to the length of the attribute value, then the length of the part attribute value shall be zero. If the attribute value is longer than (Value_Offset + ATT_MTU-1) then (ATT_MTU-1) octets from Value Offset shall be included in this response.

**Write Attribute**
```c
Write_Request (0x12)
[2B] Attribute_Handle
[nB] Attribute_Value
Write_Response (0x13)
[0B] shall be sent after the attribute value is written

Prepare_Write_Request (0x16)
[2B] Attribute_Handle
[2B] Value_Offset: started from 0
[nB] Part_Attribute_Value
Prepare_Write_Response (0x17)
[2B] Attribute_Handle
[2B] Value_Offset: started from 0
[nB] Part_Attribute_Value

Execute_Write_Request (0x18)
[1B] Flags: 0x00 cancel, 0x01 write
Execute_Write_Response (0x19)
[0B] NULL
```

**Write Command**
```c
Write_Command (0x52)
[2B] Attribute_Handle
[nB] Attribute_Value

Signed_Write_Command (0xD2)
[2B] Attribute_Handle
[nB] Attribute_Value
[12B] Authentication_Signature
```

Attributes that cannot be read, but can only be written, notified or indicated are called control-point attributes. These control-point attributes can be used by higher layers to enable device specific procedures.

The Write Command is used to request the server to write the value of an attribute, typically into a control-point attribute. If the server cannot write the attribute for any reason, or the authentication signature verification fails,
then the server shall ignore the command.

An Attribute PDU that includes an Authentication Signature should not be sent on an encrypted link. Note: an encrypted link already includes authentication data on every packet and therefore adding more authentication data is not required.

**Server Initiated**
```c
Handle_Value_Notification (0x1B)
[2B] Attribute_Handle
[nB] Attribute_Value

Handle_Value_Indication (0x1D)
[2B] Attribute_Handle
[nB] Attribute_Value
Handle_Value_Confirmation (0x1E)
[0B] NULL
```


## Generic Attribute Profile (GATT)

GATT describes a service framework using the ATT
- exchange configuration
- discovery of services and characteristics on a device
- reading a characteristic value
- writing a characteristic value
- notification of a characteristic value
- indication of a characteristic value

GATT can be used with
- BT 1.2 or later when using the profile on the BER physical link, and
- BT 4.0 or later then using the profile on the BLE physical link

Profile Fundamentals
- the profile roles are not tied to the controller master/slave roles
- on the BLE phsical link, use fo security features such as authorization, authentication and encryption are optional.
  on a BER physical link encryption is mandatory.
- Multi-octet fields within the GATT profile shall be sent least significant octet first (little endian)

Gatt profile hierarchy
- a profile can have one or more services
- a service can contain zero or more service *Include*, and one or more *Characteristics*
- a characteristic contains *Properties*, a *Value*, and zero or more *Descriptors*
- a characteristic may be a mandatory or optional characteristic for a service
- there are two types of services: primary service and secondary service
- a primary service is a service that exposes the primary usable functionality of this device
- a primary can be included by another service, and it can be discovered using Primary_Service_Discovery procedure
- a secondary service is a service that is only intended to be referenced from a primary service
- or another secondary service or other higher layer specification
- a secondary service is only relevant in the context of the entity that references it

Gatt profile attribute types
- 0x2800 Primary Service
- 0x2801 Secondary Service
- 0x2802 Service Include
- 0x2803 Characteristic
- 0x2900 Characteristic Extended Properties
- 0x2901 Characteristic User Description
- 0x2902 Client Characteristic Configuration Descriptor
- 0x2903 Server Characteristic Configureation Descriptor
- 0x2904 Characteristic Format Descriptor
- 0x2905 Characteristic Aggregate Format Descriptor

Gatt defined features
- Server Configuration
- Primary Service Discovery
- Relationship Discovery
- Characteristic Discovery
- Characteristic Descriptor Discovery
- Reading a Characteristic Value
- Writing a Characteristic Value
- Notification of a Characteristic Value
- Indication of a Characteristic Value
- Reading a Characteristic Descriptor
- Writing a Characteristic Descriptor

**Server Configuration**

- it is used by the client to configure the ATT_MTU when the client supports a value greater than the default ATT_MTU
- the ExchangeMTURequest procedure shall not be used on BER physical link since L2CAP channel configuration procedures
- the client shall set Client Rx MTU to the maximum value it can receive
- the server shall respond with the Server Rx MTU set to the maximum MTU it can receive, or ErrorResponse
- if the ErrorResponse is sent by the server with error RequestNotSupported, the default MTU shall be used

```c
[Client] -> Exchange_MTU_Request(Client_Rx_MTU_Size)
         <- Exchange_MTU_Response(Server_Rx_MTU_Size)
```

**Primary Service Discovery**

- it is used by a client to discover primary services on a server
- once primary services are discovered, additional information of primary services can be accessed using other procedures



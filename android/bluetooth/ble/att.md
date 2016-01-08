# Attribute Protocol (ATT)

**INTRODUCTION**

The attribute protocol allows a device referred to as the server to expose a set
of attributes and their associated values to a peer device referred to as the
client. These attributes exposed by the server can be discovered, read, and
written by a client, and can be indicated and notified by the server.

An attribute is a discrete value that has the following three properties associated 
with it: attribute type, defined by a UUID; attribute handle; a set of permissions 
that are defined by each higher layer specification that utilizes the attribute, 
these permissions cannot be accessed using the Attribute Protocol.

The attribute type specifies what the attribute represents. Bluetooth SIG
defined attribute types are defined in the Bluetooth SIG assigned numbers
page, and used by an associated higher layer specification. Non-Bluetooth SIG
attribute types may also be defined.

A device can implement both client and server roles, and both roles can function 
concurrently in the same device and between the same devices. There shall be only 
one instance of a server on each Bluetooth device; this implies that the attribute 
handles shall be identical for all supported bearers. For a given client, the 
server shall have one set of attributes. The server can support multiple clients. 
Note: multiple services may be exposed on a single server by allocating separate 
ranges of handles for each service. The discovery of these handle ranges is defined 
by a higher layerspecification.

**SECURITY CONSIDERATIONS**

The attribute protocol can be used to access information that may require both
authorization and an authenticated and encrypted physical link before an
attribute can be read or written.

If such a request is issued when the client has not been authorized to access
this information, the server shall send an Error Response with the error code
set to «Insufficient Authorization». The authorization requirements for access
to a given attribute are not defined in this specification. Each device
implementation will determine how authorization occurs. Authorization
procedures are defined in GAP, and may be further refined in a higher layer
specification.

If such a request is issued when the physical link is unauthenticated, the server
shall send an Error Response with the error code set to «Insufficient
Authentication». A client wanting to read or write this attribute can then request
that the physical link be authenticated, and once this has been completed,
send the request again.

The attribute protocol can be used to notify or indicate the value of an attribute
that may require an authenticated and encrypted physical link before an
attribute notification or indication is performed. A server wanting to notify or
indicate this attribute can then request that the physical link be authenticated,
and once this has been completed, send the notification or indication.

The list of attributes that a device supports is not considered private or
confidential information, and therefore the Find Information Request shall
always be permitted. This implies that an «Insufficient Authorization» or
«Insufficient Authentication» error code shall not be used in an Error Response
for a Find Information Request .

Note: For example, if the authentication and authorization requirement checks
are not performed first then the size of an attribute could be determined by
performing repeated read blob requests on an attribute that a client does not
have access to, because either an «Invalid Offset» error code or «Insufficient
Authentication» error codes would be returned.

## Basic Concepts

Each attribute has an attribute type that identifies, by means of a UUID
(Universally Unique IDentifier), what the attribute represents so that a client
can understand the attributes exposed by a server.

An attribute value is accessed using its attribute handle. The attribute handles
are discovered by a client using attribute protocol PDUs (Protocol Data Unit).
Attributes that have the same attribute type may exist more than once in a
server. Attributes also have a set of permissions that controls whether they can
be read or written, or whether the attribute value shall be sent over an encrypted
link.

**ATTRIBUTE TYPE**

A universally unique identifier (UUID) is used to identify every attribute type. A
UUID is considered unique over all space and time. All 32-bit Attribute UUIDs shall 
be converted to 128-bit UUIDs when the Attribute UUID is contained in an ATT PDU.

**ATTRIBUTE HANDLE**

An attribute handle is a 16-bit value that is assigned by each server to its own
attributes to allow a client to reference those attributes. An attribute handle
shall not be reused while an ATT Bearer exists between a client and its server.
Attribute handles on any given server shall have unique, non-zero values.
Attributes are ordered by attribute handle.

An attribute handle of value 0x0000 is reserved, and shall not be used. An
attribute handle of value 0xFFFF is known as the maximum attribute handle.
Note: Attributes can be added or removed while an ATT Bearer is active,
however, an attribute that has been removed cannot be replaced by another
attribute with the same handle while an ATT Bearer is active.

Handle grouping is defined by a specific attribute placed at the beginning of 
a range of other attributes that are grouped with that attribute, as defined by 
a higher layer specification. Clients can request the first and last handles 
associated with a group of attributes.

**ATTRIBUTE VALUE**

An attribute value is an octet array that may be either fixed or variable length.
For example, it can be a one octet value, or a four octet integer, or a variable
length string. An attribute may contain a value that is too large to transmit in a
single PDU and can be sent using multiple PDUs. The values that are
transmitted are opaque to the attribute protocol. The encoding of these octet
arrays is defined by the attribute type.

The attribute value length is not sent in any field of the PDU. For a variable 
length value, the length of the packet that carries this PDU implies its length.
This implies that:
- only one attribute value can be placed in a single request,
response, notification or indication unless the attribute values
have lengths known by both the server and client, as defined by
the attribute type
- the bearer protocol (e.g. L2CAP) preserves datagram boundaries

Note: Some responses include multiple attribute values, for example when
client requests multiple attribute reads. For the client to determine the attribute
value boundaries, the attribute values must have a fixed size defined by the
attribute type.

**ATTRIBUTE PERMISSIONS**

An attribute has a set of permission values associated with it. The permissions
associated with an attribute specifies that it may be read and/or written, and 
specifies the security level required for read and/or write access, as well as 
notification and/or indication. The permissions of a given attribute are defined 
by a higher layer specification, and are not discoverable using the attribute protocol.

If access to a secure attribute requires an authenticated link, and the client is
not already authenticated with the server with sufficient security, then an error
response shall be sent with the error code «Insufficient Authentication». When
a client receives this error code it may try to authenticate the link, and if the
authentication is successful, it can then access the secure attribute.

If access to a secure attribute requires an encrypted link, and the link is not
encrypted, then an error response shall be sent with the error code
«Insufficient Encryption». When a client receives this error code it may try to
encrypt the link and if the encryption is successful, it can then access the
secure attribute.

If access to a secure attribute requires an encrypted link, and the link is
encrypted but with an encryption key size that is too short for the level of
security required, then an error response shall be sent with the error code
«Insufficient Encryption Key Size». When a client receives this error code it
may try to encrypt the link with a larger key size, and if the encryption is
successful, it can then access the secure attribute.

Attribute permissions are a combination of access permissions, encryption
permissions, authentication permissions and authorization permissions.
- Readable, Writeable, Readable and writable
- Encryption required, No encryption required
- Authentication required, No authentication required
- Authorization required, No authorization required

Access permissions are used by a server to determine if a client can read and/or 
write an attribute value. Authentication permissions are used by a server to 
determine if an authenticated physical link is required when a client attempts 
to access an attribute. Authentication permissions are also used by a server to 
determine if an authenticated physical link is required before sending a 
notification or indication to a client. Authorization permissions determine if a 
client needs to be authorized before accessing an attribute value.

**CONTROL-POINT ATTRIBUTES**

Attributes that cannot be read, but can only be written, notified or indicated are
called control-point attributes. These control-point attributes can be used by
higher layers to enable device specific procedures, for example the writing of a
command or the indication when a given procedure on a device has
completed.

**ATTRIBUTE MTU**

ATT_MTU is defined as the maximum size of any packet sent between a client
and a server. A higher layer specification defines the default ATT_MTU value.
The client and server may optionally exchange the maximum size of a packet
that can be received using the Exchange MTU Request and Response PDUs.
Both devices then use the minimum of these exchanged values for all further
communication.

A device that is acting as a server and client at the same time shall use the
same value for Client Rx MTU and Server Rx MTU. The ATT_MTU value is a per 
ATT Bearer value. Note: A device with multiple ATT Bearers may have a different 
ATT_MTU value for each ATT Bearer.

The longest attribute that can be sent in a single packet is (ATT_MTU-1) octets
in size. At a minimum, the Attribute Opcode is included in an Attribute PDU.
An attribute value may be defined to be larger than (ATT_MTU-1) octets in
size. These attributes are called long attributes. To read the entire value of 
an attributes larger than (ATT_MTU-1) octets, the read blob request is used. 
It is possible to read the first (ATT_MTU-1) octets of a long attribute value 
using the read request.

To write the entire value of an attribute larger than (ATT_MTU-3) octets, the
prepare write request and execute write request is used. It is possible to write
the first (ATT_MTU-3) octets of a long attribute value using the write request.
It is not possible to determine if an attribute value is longer than (ATT_MTU-3)
octets using this protocol. A higher layer specification will state that a given
attribute can have a maximum length larger than (ATT_MTU-3) octets.

The maximum length of an attribute value shall be 512 octets. Note: The protection 
of an attribute value changing when reading the value using multiple attribute 
protocol PDUs is the responsibility of the higher layer.

**ATOMIC OPERATIONS**

The server shall treat each request or command as an atomic operation that
cannot be affected by another client sending a request or command at the
same time. If a physical link is disconnected for any reason (user action or loss
of the radio link), the value of any modified attribute is the responsibility of the
higher layer specification. Long attributes cannot be read or written in a single 
atomic operation.


## Attribute PDU

Attribute PDUs are one of six method types:  
\- Requests - sent to a server by a client, and invoke responses  
\- Responses - sent to a client in response to a request to a server  
\- Commands - sent to a server by a client  
\- Notifications - sent to a client by a server  
\- Indications - sent to a client by a server, and invoke confirmations  
\- Confirmations - sent to a server to confirm receipt of an indication by a client  

A server shall be able to receive and properly respond to the following
requests: Find Information Request, Read Request. Support for all other PDU types 
in a server can be specified in a higher layer specification.

If a client sends a request, then the client shall support all possible responses
PDUs for that request. If a server receives a request that it does not support, then 
the server shall respond with the Error Response with the Error Code «Request Not
Supported», with the Attribute Handle In Error set to 0x0000. If the server receives 
an invalid request - for example, the PDU is the wrong length - then the server shall 
respond with the Error Response with the Error Code «Invalid PDU», with the Attribute 
Handle In Error set to 0x0000.

If a server does not have sufficient resources to process a request, then the
server shall respond with the Error Response with the Error Code «Insufficient
Resources», with the Attribute Handle In Error set to 0x0000. If a server cannot 
process a request because an error was encountered during the processing of this 
request, then the server shall respond with the Error Response with the Error Code 
«Unlikely Error», with the Attribute Handle In Error set to 0x0000.
If a server receives a command that it does not support, indicated by the
Command Flag of the PDU set to one, then the server shall ignore the
Command.

**PDU FORMART**

LSB  
Attribute_Opcode: 1-Byte [Method(012345) Command_Flag(6) Authentication_Signature_Flag(7)]  
Attribute_Parameters: 0 to ATT_MTU-1 Bytes or 0 to ATT_MTU-13 Bytes   
Authentication_Signature_Flag: 0-Byte or 12-Byte    
MSB  

Multi-octet fields within the attribute protocol shall be sent least significant octet
first (little endian) with the exception of the Attribute Value field in Attribute Parameters. 
The endian-ness of the Attribute Value field is defined by a higher layer specification.

The Attribute Opcode is composed of three fields, the Authentication Signature
Flag, the Command Flag, and the Method. The Method is a 6-bit value that
determines the format and meaning of the Attribute Parameters. If the Command Flag of 
the Attribute Opcode is set to one, the PDU shall be considered to be a Command.

If the Authentication Signature Flag of the Attribute Opcode is set to one, the
Authentication Signature value shall be appended to the end of the attribute PDU.
The Authentication Signature field is calculated as defined in Security Manager.
This value provides an Authentication Signature for the variable length message (m) 
consisting of the following values in this order: Attribute Opcode, Attribute Parameters.
An Attribute PDU that includes an Authentication Signature should not be sent
on an encrypted link. Note: an encrypted link already includes authentication
data on every packet and therefore adding more authentication data is not
required.

**TRANSACTION**

Many attribute protocol PDUs use a sequential request-response protocol.
Once a client sends a request to a server, that client shall send no other
request to the same server until a response PDU has been received.
Indications sent from a server also use a sequential indication-confirmation
protocol. No other indications shall be sent to the same client from this server
until a confirmation PDU has been received. The client, however, is free to
send commands and requests prior to sending a confirmation.

For notifications, which do not have a response PDU, there is no flow control
and a notification can be sent at any time. Commands that do not require a response 
do not have any flow control. Note: a server can be flooded with commands, and a 
higher layer specification can define how to prevent this from occurring.
Commands and notifications that are received but cannot be processed, due to
buffer overflows or other reasons, shall be discarded. Therefore, those PDUs
must be considered to be unreliable.

Note: Flow control for each client and a server is independent.
Note: It is possible for a server to receive a request, send notifications or/and 
receive commands, and then the response to the original request. The flow control 
of requests is not affected by the transmission of the notifications/commands.

An attribute protocol request and response or indication-confirmation pair is
considered a single transaction. A transaction shall always be performed on
one ATT Bearer, and shall not be split over multiple ATT Bearers.
On the client, a transaction shall start when the request is sent by the client. A
transaction shall complete when the response is received by the client.
On a server, a transaction shall start when a request is received by the server.
A transaction shall complete when the response is sent by the server.
On a server, a transaction shall start when an indication is sent by the server. A
transaction shall complete when the confirmation is received by the server.
On a client, a transaction shall start when an indication is received by the client.
A transaction shall complete when the confirmation is sent by the client.

A transaction not completed within 30 seconds shall time out. Such a
transaction shall be considered to have failed and the local higher layers shall
be informed of this failure. No more attribute protocol requests, commands,
indications or notifications shall be sent to the target device on this ATT Bearer.
Note: To send another attribute protocol PDU, a new ATT Bearer must be
established between these devices. The existing ATT Bearer may need to be
disconnected or the bearer terminated before the new ATT Bearer is
established. If the ATT Bearer is disconnected during a transaction, then the 
transaction shall be considered to be closed, and any values that were being modified 
on the server will be in an undetermined state, and any queue that was prepared
by the client using this ATT Bearer shall be cleared.

Note: Each Prepare Write Request is a separate request and is therefore a
separate transaction. Note: Each Read Blob Request is a separate request and is 
therefore a separate transaction.

## Error Handling

**Error_Response**, Request_Opcode, Attribute_Handle, Error_Code  
[0x01][0x00][0x0000][0x00]  

The Error Response is used to state that a given request cannot be performed,
and to provide the reason. If there was no attribute handle in the original 
request or if the request is not supported, then the value 0x0000 shall be used 
for this field.

The Error Code parameter shall be set to one of the following values:  
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


## MTU Exchange

**Exchange_MTU_Request**, Client_Receive_MTU_Size  
[0x02][0x0000]  
**Exchange_MTU_Response**, Server_Receive_MTU_Size  
[0x03][0x0000]  

This request shall only be sent once during a connection by the client. 
The Client/Server Rx MTU shall be greater than or equal to the default ATT_MTU.
The Client/Server Rx MTU parameter shall be set to the maximum size of the attribute
protocol PDU that the client/server can receive.

The server and client shall set ATT_MTU to the minimum of the Client Rx MTU
and the Server Rx MTU. The size is the same to ensure that a client can
correctly detect the final packet of a long attribute read. If Client or Server 
Rx MTU are incorrectly less than the default ATT_MTU, then the ATT_MTU shall not be 
changed and the ATT_MTU shall be the default ATT_MTU.

This ATT_MTU value shall be applied in the server after this response has
been sent and before any other attribute protocol PDU is sent.
This ATT_MTU value shall be applied in the client after this response has been
received and before any other attribute protocol PDU is sent.

If a device is both a client and a server, the following rules shall apply:  
- A device's Exchange MTU Request shall contain the same MTU as the  
  device's Exchange MTU Response (i.e. the MTU shall be symmetric);  
- If an Attribute Protocol Request is received after the MTU Exchange  
  Request is sent and before the MTU Exchange Response is received, the  
  associated Attribute Protocol Response shall use the default MTU (23);  
- Once the MTU Exchange Request has been sent, the initiating device shall  
  not send an Attribute Protocol Indication or Notification until after the MTU  
  Exchange Response has been received. Note: This stops the risk of a cross-over  
  condition where the MTU size is unknown for the Indication or Notification;  

## Find Information

**Find_Information_Request**, Starting_Handle, Ending_Handle  
[0x04][0x0000][0x0000]  
**Find_Information_Response**, Format, Infromation_Data  
[0x05][0x01|0x02][4 to ATT_MTU-2]  

The Find Information Request is used to obtain the mapping of attribute
handles with their associated types. This allows a client to discover the list of
attributes and their types on a server. Only attributes with attribute handles 
between and including the Starting Handle parameter and the Ending Handle parameter 
will be returned. To read all attributes, the Starting Handle parameter shall be 
set to 0x0001, and the Ending Handle parameter shall be set to 0xFFFF.

If no attributes will be returned, an Error Response shall be sent with the
«Attribute Not Found» error code; the Attribute Handle In Error parameter shall
be set to the Starting Handle parameter. If one or more attributes will be returned, 
a Find Information Response PDU shall be sent.

If a server receives a Find Information Request with the Starting Handle
parameter greater than the Ending Handle parameter or the Starting Handle
parameter is 0x0000, an Error Response shall be sent with the «Invalid
Handle» error code; the Attribute Handle In Error parameter shall be set to the
Starting Handle parameter. The server shall not respond to the Find Information Request 
with an Error Response with the «Insufficient Authentication», «Insufficient Authorization»,
«Insufficient Encryption Key Size» or «Application Error» error code.

The Find Information Response shall have complete handle-UUID pairs. Such
pairs shall not be split across response packets; this also implies that a handle-
UUID pair shall fit into a single response packet. The handle-UUID pairs shall
be returned in ascending order of attribute handles.

The Format parameter can contain one of two possible values.  
0x01 - A list of 1 or more handles with their 16-bit UUIDs, 2-byte 2-byte list;  
0x02 - A list of 1 or more handles with their 128-bit UUIDs, 2-byte 16-byte list;  

Note: If sequential attributes have differing UUID sizes, it may happen that a
Find Information Response is not filled with the maximum possible amount of
(handle, UUID) pairs. This is because it is not possible to include attributes with
differing UUID sizes into a single response packet. In that case, the following
attribute would have to be read using another Find Information Request with its
starting handle updated.

**Find_By_Type_Value_Request**, Starting/Ending_Handle, Attribute_Type/Value  
[0x06][0x0000][0x0000][0x0000][0 to ATT_MTU-7]  
**Find_By_Type_Value_Response**, Handles_Information_List  
[0x07][4 to ATT_MTU-1]  

The Find By Type Value Request is used to obtain the handles of attributes that
have a 16-bit UUID attribute type and attribute value.This allows the range of
handles associated with a given attribute to be discovered when the attribute
type determines the grouping of a set of attributes. Note: Generic Attribute
Profile defines grouping of attributes by attribute type.

Only attributes with attribute handles between and including the Starting
Handle parameter and the Ending Handle parameter that match the requested
attribute type and the attribute value that have sufficient permissions to allow
reading will be returned. To read all attributes, the Starting Handle parameter
shall be set to 0x0001, and the Ending Handle parameter shall be set to
0xFFFF. Note: Attribute values will be compared in terms of length and binary
representation. Note: It is not possible to use this request on an attribute 
that has a value longer than (ATT_MTU-7).

If no attributes will be returned, an Error Response shall be sent by the server
with the error code «Attribute Not Found». The Attribute Handle In Error
parameter shall be set to the starting handle. If one or more handles will be returned, 
a Find By Type Value Response PDU shall be sent.

If a server receives a Find By Type Value Request with the Starting Handle
parameter greater than the Ending Handle parameter or the Starting Handle
parameter is 0x0000, an Error Response shall be sent with the «Invalid
Handle» error code. The Attribute Handle In Error parameter shall be set to the
Starting Handle parameter. The server shall not respond to the Find By Type Value 
Request with an Error Response with the «Insufficient Authentication», 
«Insufficient Authorization», «Insufficient Encryption Key Size», «Insufficient Encryption» 
or «Application Error» error code.

The Handles Information List field is a list of one or more Handle Informations.
The Format of Handle Information: Found_Attribute_Handle 2-Byte, Group_End_Handle 2-Byte.

The Find By Type Value Response shall contain one or more complete
Handles Information. Such Handles Information shall not be split across
response packets. The Handles Information List is ordered sequentially based
on the found attribute handles. If a server receives a Find By Type Value Request, 
the server shall respond with the Find By Type Value Response containing as many 
handles for attributes that match the requested attribute type and attribute value 
that exist in the server that will fit into the maximum PDU size of (ATT_MTU-1).

For each handle that matches the attribute type and attribute value in the Find
By Type Value Request a Handles Information shall be returned. The Found
Attribute Handle shall be set to the handle of the attribute that has the exact
attribute type and attribute value from the Find By Type Value Request . If the
attribute type in the Find By Type Value Request is a grouping attribute as
defined by a higher layer specification, the Group End Handle shall be defined
by that higher layer specification. If the attribute type in the Find By Type Value
Request is not a grouping attribute as defined by a higher layer specification,
the Group End Handle shall be equal to the Found Attribute Handle. Note: The Group 
End Handle may be greater than the Ending Handle in the Find By Type Value Request.

## Reading Attribute

**Read_By_Type_Request**, Starting_Handle, Ending_Handle, Attribute_Type
[0x08][0x0000][0x0000][0x0000|0x00000000000000000000000000000000]
**Read By Type Response**, Length, Attribute_Data_List
[0x09][0x00][2 to ATT_MTU-2]

The Read By Type Request is used to obtain the values of attributes where the
attribute type is known but the handle is not known. Note: All attribute types 
are effectively compared as 128-bit UUIDs, even if a 16-bit UUID is provided 
in this request or defined for an attribute. If no attribute with the given type 
exists within the handle range, then no attribute handle and value will be 
returned, and an Error Response shall be sent with the error code 
«Attribute Not Found». The Attribute Handle In Error parameter shall be set to 
the starting handle.

The attributes returned shall be the attributes with the lowest handles within the
handle range. These are known as the requested attributes. If the attributes with 
the requested type within the handle range have attribute values that have the same 
length, then these attributes can all be read in a single request. The attribute 
server shall include as many attributes as possible in the response in order to 
minimize the number of PDUs required to read attributes of the same type.

Note: If the attributes with the requested type within the handle range have
attribute values with different lengths, then multiple Read By Type Request s
must be made.

When multiple attributes match, then the rules below shall be applied to each in turn.
- Only attributes that can be read shall be returned in a Read By Type Response;
- If an attribute in the set of requested attributes would cause an Error Response 
  then this attribute cannot be included in a Read By Type Response and the attributes 
  before this attribute shall be returned;
- If the first attribute in the set of requested attributes would cause an Error Response 
  then no other attributes in the requested attributes can be considered;

The server shall respond with a Read By Type Response if the requested
attributes have sufficient permissions to allow reading. If the client has insufficient 
authorization/security/encryption key size to read the requested attribute, or has not 
enabled encryption and encryption is required to read the requested attribute, then an 
Error Response shall be sent with the related error code. If the requested attribute’s 
value cannot be read due to permissions then an Error Response shall be sent with the 
error code «Read Not Permitted». The Attribute Handle In Error parameter shall be set 
to the handle of the attribute causing the error.

Note: if there are multiple attributes with the requested type within the handle
range, and the client would like to get the next attribute with the requested type,
it would have to issue another Read By Type Request with its starting handle
updated. The client can be sure there are no more such attributes remaining
once it gets an Error Response with the error code «Attribute Not Found».

The Read By Type Response shall contain complete handle-value pairs. Such
pairs shall not be split across response packets. The handle-value pairs shall
be returned sequentially based on the attribute handle. The Length parameter shall 
be set to the size of one attribute handle-value pair.
The maximum length of an attribute handle-value pair is 255 octets, bounded
by the Length parameter that is one octet. Therefore, the maximum length of
an attribute value returned in this response is (Length – 2) = 253 octets.

The attribute handle-value pairs shall be set to the value of the attributes
identified by the attribute type within the handle range within the request. If the
attribute value is longer than (ATT_MTU - 4) or 253 octets, whichever is
smaller, then the first (ATT_MTU - 4) or 253 octets shall be included in this
response. Note: the Read Blob Request would be used to read the remaining octets of 
a long attribute value.

**Read_Request**, Attribute_Handle
[0x0A][0x0000]
**Read_Response**, Attribute_Value
[0x0B][0 to ATT_MTU-1]

The Read Request is used to request the server to read the value of an
attribute and return its value in a Read Response. The attribute handle parameter 
shall be set to a valid handle. The server shall respond with a Read Response 
if the handle is valid and the attribute has sufficient permissions to allow reading.
If the handle is invalid, then an Error Response shall be sent with the error
code «Invalid Handle». If the attribute value cannot be read due to permissions then 
an Error Response shall be sent with the error code «Read Not Permitted».

if the client has insufficient authorization/security/encryption key size to read the 
requested attribute, or not enabled encryption and encryption is required to read the
requested attribute, then an Error Response shall be sent with the related error code.

The attribute value shall be set to the value of the attribute identified by the
attribute handle in the request. If the attribute value is longer than (ATT_MTU-1) 
then the first (ATT_MTU-1) octets shall be included in this response.
Note: the Read Blob Request would be used to read the remaining octets of a
long attribute value.


**Read_Blob_Request**, Attribute_Handle, Value_Offset
[0x0C][0x0000][0x0000]
**Read_Blob_Response**, Part_Attribute_Value
[0x0D][0 to ATT_MTU-1]

The Read Blob Request is used to request the server to read part of the value
of an attribute at a given offset and return a specific part of the value in a 
Read Blob Response. The attribute handle parameter shall be set to a valid handle.
The value offset parameter is based from zero; the first value octet has an
offset of zero, the second octet has a value offset of one, etc.
If the value offset of the Read Blob Request is equal to the length of the
attribute value, then the length of the part attribute value in the response shall
be zero. The server shall respond with a Read Blob Response if the handle is valid 
and the attribute and value offset is not greater than the length of the attribute
value and has sufficient permissions to allow reading.

if the client has insufficient authorization/security/encryption key size to read the 
requested attribute, or not enabled encryption and encryption is required to read the
requested attribute, then an Error Response shall be sent with the related error code.

If the handle is invalid, then an Error Response shall be sent with the error
code «Invalid Handle». If the attribute value cannot be read due to permissions then 
an Error Response shall be sent with the error code «Read Not Permitted». If the value 
offset of the Read Blob Request is greater than the length of the attribute value, 
an Error Response shall be sent with the error code «Invalid Offset».
If the attribute value has a fixed length that is less than or equal to
(ATT_MTU - 3) octets in length, then an Error Response can be sent with the
error code «Attribute Not Long».

Note: if the attribute is longer than (ATT_MTU-1) octets, the Read Blob
Request is the only way to read the additional octets of a long attribute. The
first (ATT_MTU-1) octets may be read using a Read Request , an Handle Value
Notification or an Handle Value Indication. Note: Long attributes may or may 
not have their length specified by a higher layer specification. If the long 
attribute has a variable length, the only way to get to the end of it is to 
read it part by part until the value in the Read Blob Response has a length 
shorter than (ATT_MTU-1) or an Error Response with the error code «Invalid Offset».
Note: the value of a Long Attribute may change between one Read Blob
Request and the next Read Blob Request. A higher layer specification should
be aware of this and define appropriate behavior.

The part attribute value shall be set to part of the value of the attribute identified
by the attribute handle and the value offset in the request. If the value offset is
equal to the length of the attribute value, then the length of the part attribute
value shall be zero. If the attribute value is longer than (Value_Offset +
ATT_MTU-1) then (ATT_MTU-1) octets from Value Offset shall be included in
this response.


**Read_Multiple_Request**, Sef_Of_Handles
[0x0E][4 to ATT_MTU-1]
**Read_Multiple_Response**, Set_Of_Values
[0x0F][0 to ATT_MTU-1]

The Read Multiple Request is used to request the server to read two or more
values of a set of attributes and return their values in a Read Multiple
Response. Only values that have a known fixed size can be read, with the
exception of the last value that can have a variable length. The knowledge of
whether attributes have a known fixed size is defined in a higher layer
specification. 

The attribute handles in the Set Of Handles parameter shall be valid handles.
The server shall respond with a Read Multiple Response if all the handles are
valid and all attributes have sufficient permissions to allow reading.
Note: The attribute values for the attributes in the Set Of Handles parameters
do not have to all be the same size. Note: The attribute handles in the 
Set Of Handles parameter do not have to be in attribute handle order; they are 
in the order that the values are required in the response.

The Set Of Values parameter shall be a concatenation of attribute values for
each of the attribute handles in the request in the order that they were
requested. If the Set Of Values parameter is longer than (ATT_MTU-1) then
only the first (ATT_MTU-1) octets shall be included in this response.
Note: a client should not use this request for attributes when the Set Of Values
parameter could be (ATT_MTU-1) as it will not be possible to determine if the
last attribute value is complete, or if it overflowed.


**Read_By_Group_Type_Request**, Starting/Ending_Handle, Attribute_Group_Type
[0x10][0x0000][0x0000][0x0000|0x00000000000000000000000000000000]
**Read_By_Group_Type_Response**, Length, Attribute_Data_List
[0x11][0x00][2 to ATT_MTU-2]

The Read By Group Type Request is used to obtain the values of attributes
where the attribute type is known, the type of a grouping attribute as defined by
a higher layer specification, but the handle is not known. Only the attributes with 
attribute handles between and including the Starting Handle and the Ending Handle 
with the attribute type that is the same as the Attribute Group Type given will be 
returned. To search through all attributes, the starting handle shall be set to 
0x0001 and the ending handle shall be set to 0xFFFF. Note: All attribute types are 
effectively compared as 128-bit UUIDs, even if a 16-bit UUID is provided in this 
request or defined for an attribute.

The starting handle shall be less than or equal to the ending handle. If a server
receives a Read By Group Type Request with the Starting Handle parameter
greater than the Ending Handle parameter or the Starting Handle parameter is 0x0000, 
an Error Response shall be sent with the «Invalid Handle» error code;
The Attribute Handle In Error parameter shall be set to the Starting Handle parameter.
If the Attribute Group Type is not a supported grouping attribute as defined by a
higher layer specification then an Error Response shall be sent with the error
code «Unsupported Group Type». The Attribute Handle In Error parameter
shall be set to the Starting Handle. If no attribute with the given type exists 
within the handle range, then no attribute handle and value will be returned, 
and an Error Response shall be sent with the error code «Attribute Not Found». 
The Attribute Handle In Error parameter shall be set to the starting handle.

The attributes returned shall be the attributes with the lowest handles within the
handle range. These are known as the requested attributes. If the attributes with 
the requested type within the handle range have attribute values that have the same 
length, then these attributes can all be read in a single request.
The attribute server shall include as many attributes as possible in the
response in order to minimize the number of PDUs required to read attributes
of the same type. Note: If the attributes with the requested type within the 
handle range have attribute values with different lengths, then multiple 
Read By Group Type Request s must be made.

When multiple attributes match, then the rules below shall be applied to each in turn.
- Only attributes that can be read shall be returned in a Read By Group Type Response;
- If an attribute in the set of requested attributes would cause an Error
  Response then this attribute cannot be included in a Read By Group Type
  Response and the attributes before this attribute shall be returned;
- If the first attribute in the set of requested attributes would cause an Error
  Response then no other attributes in the requested attributes can be considered;

The Read By Group Type Response shall contain complete Attribute Data. An
Attribute Data shall not be split across response packets. The Attribute Data
List is ordered sequentially based on the attribute handles
The Length parameter shall be set to the size of the one Attribute Data.
The format of Attribute Data: Attribute_Handle 2-Byte, End_Group_Handle 2-Byte,
Attribute_Value Length-4 Bytes. The maximum length of an Attribute Data is 255 octets, 
bounded by the Length parameter that is one octet. Therefore, the maximum length of 
an attribute value returned in this response is (Length – 4) = 251 octets.

The Attribute Data List shall be set to the value of the attributes identified by
the attribute type within the handle range within the request. If the attribute
value is longer than (ATT_MTU - 6) or 251 octets, whichever is smaller, then
the first (ATT_MTU - 6) or 251 octets shall be included in this response.
Note: the Read Blob Request would be used to read the remaining octets of a
long attribute value.


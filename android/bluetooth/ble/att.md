# Attribute Protocol (ATT)

INTRODUCTION

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

SECURITY CONSIDERATIONS

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

ATTRIBUTE TYPE

A universally unique identifier (UUID) is used to identify every attribute type. A
UUID is considered unique over all space and time. All 32-bit Attribute UUIDs shall 
be converted to 128-bit UUIDs when the Attribute UUID is contained in an ATT PDU.

ATTRIBUTE HANDLE

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

ATTRIBUTE VALUE

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

ATTRIBUTE PERMISSIONS

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

CONTROL-POINT ATTRIBUTES

Attributes that cannot be read, but can only be written, notified or indicated are
called control-point attributes. These control-point attributes can be used by
higher layers to enable device specific procedures, for example the writing of a
command or the indication when a given procedure on a device has
completed.

ATTRIBUTE MTU

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

ATOMIC OPERATIONS

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

PDU FORMART

```
LSB
Attribute_Opcode: 1-Byte [Method(012345) Command_Flag(6) Authentication_Signature_Flag(7)]  
Attribute_Parameters: 0 to ATT_MTU-1 Bytes or 0 to ATT_MTU-13 Bytes  
Authentication_Signature_Flag: 0-Byte or 12-Byte  
MSB
```

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

TRANSACTION

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



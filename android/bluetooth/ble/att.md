# Attribute Protocol (ATT)

1 INTRODUCTION

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

2 SECURITY CONSIDERATIONS

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

1 ATTRIBUTE TYPE

A universally unique identifier (UUID) is used to identify every attribute type. A
UUID is considered unique over all space and time. All 32-bit Attribute UUIDs shall 
be converted to 128-bit UUIDs when the Attribute UUID is contained in an ATT PDU.

2 ATTRIBUTE HANDLE

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

3 ATTRIBUTE VALUE

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

4 ATTRIBUTE PERMISSIONS

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

Access permissions are used by a server to determine if a client can read and/
or write an attribute value.

Authentication permissions are used by a server to determine if an
authenticated physical link is required when a client attempts to access an
attribute. Authentication permissions are also used by a server to determine if
an authenticated physical link is required before sending a notification or
indication to a client.

Authorization permissions determine if a client needs to be authorized before
accessing an attribute value.

5 CONTROL-POINT ATTRIBUTES

Attributes that cannot be read, but can only be written, notified or indicated are
called control-point attributes. These control-point attributes can be used by
higher layers to enable device specific procedures, for example the writing of a
command or the indication when a given procedure on a device has
completed.

6 ATTRIBUTE MTU


## Protocol PDUs


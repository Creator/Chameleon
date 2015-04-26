# libnet protocol

libnet is a CC real-world network stack, TARDIX uses netd which uses the libnet
specification and library.

## Layers

### TCP implementation (header)

TCP/IP is a popular protocol used in almost all modern applications in the
real world.

**Limitations**:

  * no data offset (currently)
  * no window size
  * only [FIN]() and [ACK]() flags are supported currently.


**Special**:

  * sequence is seq number of the packet.

**Notes**:

  * `checksum` is a fcs16 checksum.

```
#layer:tcp,version:101,source:65535,dest:65535,seq:0,ack:0,fin:0,checksum:70708,;
```

### IPv4 implementation (header)

From [Wikipedia](https://en.wikipedia.org/wiki/IPv4)

> Internet Protocol version 4 (IPv4) is the fourth version in the development
of the Internet Protocol (IP) Internet, and routes most traffic on the Internet.

**Limitations**:

  * no [DSCP](https://en.wikipedia.org/wiki/IPv4#DSCP)
  * no [ECN](https://en.wikipedia.org/wiki/IPv4#ECN)

**Special**:

  * protocols do not *normally* conform to real-world ones.
  * protocol `0xFF` is for normal traffic over libnet.
  * protocol `0x01` is for ICMP. (not special, but noteworthy)

**Notes**:

  * `ttl` is in seconds.
  * `checksum` is a fcs16 checksum.
  * `id` is a 24 long int

```
#layer:ipv4,version:100,ttl:1,id:0xfff,flag:0,
source:192.168.1.1,protocol:0xFF,
dest:192.168.1.2,checksum:16bits,;
```

### IPv6 implementation (header)

**NOTICE:** This isn't implemented!

From [Wikipedia](https://en.wikipedia.org/wiki/IPv6)

> Internet Protocol version 6 (IPv6) is the most recent version of the
Internet Protocol (IP), the communications protocol that provides an
identification and location system for computers on networks and routes
traffic across the Internet.

**Limitations**:

  * Should be none, everything is in the headers!

```
#layer:ipv6,version:000,tclass:00000000,flabel:00000000000000000000,
plength:000000000000000,nextheader:type,hop:0,
source:128bits,dest:128bits,;
```

### ICMP implementation (header)

From [Wikipedia](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)

> The Internet Control Message Protocol (ICMP) is one of the
main protocols of the Internet Protocol Suite. It is used by
network devices, like routers, to send error messages indicating,
for example, that a requested service is not available or that a
host or router could not be reached. ICMP can also be used to
relay query messages.

**Limitations**:

  * doesn't return the 8 bits causing an error

```
#layer:icmp,type:0,code:0,checksum:70608,;
```

### Data transfer

First, the tranfer layer is injected, then the network layer (ICMP, IPv4, or
IPv6) is added on, lastly the data is injected __*RIGHT*__ after the header. The
packet should always have no linebreaks.

The data has it's own layer, but it's special:

```
layer:data,data:<data>
```

The data is base64 encoded to prevent any character issues; attempting to modify
any packets incorrectly *always* results in them being dropped.

**Example** (linebreaks for readability):

```
#layer:tcp,version:101,source:65535,dest:65535,seq:0,checksum:70708,
ack:0,fin:0,;
layer:ipv4,version:100,ttl:10000,id:0xfff,flag:0,
source:192.168.1.1,protocol:0xFF,
dest:192.168.1.2,checksum:16bits,;#
layer:data,data:GDh==
```

## Stacking the layers

Each layer has a purpose and a level they belong to on the OSI model, for example:
when using the TCP (Transport) layer with the (IPv4) layer it would look like this
(remember, no linebreaks!)

```
#layer:tcp,version:101,source:65535,dest:65535,seq:0,checksum:70708,
ack:0,fin:0,;
layer:ipv4,version:100,ttl:10000,id:0xfff,flag:0,
source:192.168.1.1,protocol:0xFF,
dest:192.168.1.1,checksum:16bits,;#
```

for each new layer, end it with a `;`, then when it's completed (unless it's a
data layer) add a # at the end.


### Data layer

```
#layer:tcp,version:101,source:65535,dest:65535,seq:0,checksum:70708,
ack:0,fin:0;
layer:ipv4,version:100,ttl:10000,id:0xfff,flag:0,
source:192.168.1.1,protocol:0xFF,
dest:192.168.1.2,checksum:16bits;#
layer:data,data:<data>
```

**Why?** Data has no defined length, therefore it uses a special format to avoid
any issues that could arise.


## Implementing rules

* You *MUST* remove `#` on parsing, they are nothing but for visual looks.

# libnet

## What is libnet?

libnet is a library and implementation for a TCP/IP fork for computercraft.

## What does libnet do?

libnet implements UDP and TCP like connections, it provides stable & reliable
data transfer throughout computers. It also allows connecting to computer through
various machines (switches, routers, hubs, etc).

## Where is the standards?

They are currently not drafted, however when the protocol is finished a complete
document on the standards will be available.

## How can I use libnet?

Sending traffic:

```lua
  libnet:registerInterfaces()
  libnet.inf[side].ip = "ip"
  libnet:send("ip", "side", "message")
```


Receiving traffic is impelmented, however it is not documented due to the API
changing constantly in that area currently.

# General
Kea is an IPv4 DHCP server developed by Internet Systems Consortium providing a very high-performance with PostgreSQL, MySQL, and memfile backends. 

This container provides the dockerized Dynamic DNS service for updating DNS mapping based on DHCP lease events using ISC maintained packages to compensate lag behind official ISC releases for Debian 10 (Buster).

# Details
Currently, the image supports the following CPU architectures:
 - x86_64 (amd64);
 - armhf (arm32v6);
 - arm7l (arm32v6);
 - aarch6 (arm64v8).

This means that the image can be used on regular PC's with Intel CPU as well as on single-board computers like Raspberry Pi with ARM CPU.

# Usage
To run container you need to execute command listed below:
```
docker run -d serhiymakarenko/isc-kea-dhcp-ddns-server:latest
```

# Related
- [Kea build on Debian](https://kb.isc.org/docs/kea-build-on-debian);
- [Installing Kea](https://kb.isc.org/docs/installing-kea).
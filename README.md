# General
Kea is an IPv4 DHCP server developed by Internet Systems Consortium providing a very high-performance with PostgreSQL, MySQL and memfile backends. 

This container provides the IPv4 DHCP server dockerized using ISC maintained packages to compensate lag behind official ISC releases for Debian 10 (Buster).

# Usage
To run container you need to execute command listed below:
```
docker run -d serhiymakarenko/isc-kea-dhcp4-server:latest
```

# Related
- [Debian Repository Setup](https://cloudsmith.io/~isc/repos/kea-1-6/setup/#formats-deb);
- [Kea packages maintened by ISC](https://cloudsmith.io/~isc/repos/kea-1-6/packages/).
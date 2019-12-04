# General
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/SerhiyMakarenko/isc-kea-dockerized/blob/isc-kea-dhcp4-server/stable/LICENSE)

Kea is an IPv4 DHCP server developed by Internet Systems Consortium providing a very high-performance with PostgreSQL, MySQL and memfile backends. 

This container provides the IPv4 DHCP server dockerized using ISC maintained packages to compensate lag behind official ISC releases for Debian 10 (Buster).

# Usage
To run container you need to execute command listed below:
```
docker run -d --name isc-kea-dhcp4-server --net=host -v /path/to/kea/configs:/etc/kea serhiymakarenko/isc-kea-dhcp4-server:latest
```

# Related
- [Debian Repository Setup](https://cloudsmith.io/~isc/repos/kea-1-6/setup/#formats-deb);
- [Kea packages maintened by ISC](https://cloudsmith.io/~isc/repos/kea-1-6/packages/).
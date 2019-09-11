# The MIT License
#
# Copyright (c) 2019, Serhiy Makarenko

FROM debian:10-slim
MAINTAINER Serhiy Makarenko <serhiy@makarenko.me>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    curl debian-keyring debian-archive-keyring apt-transport-https && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/gpg/gpg.0607E2621F1564A6.key' | apt-key add - && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/setup/config.deb.txt?distro=debian&codename=buster' > /etc/apt/sources.list.d/isc-kea-1-6.list && \
    apt-get update && \
    apt-get install -y isc-kea-dhcp-ddns-server && \
    rm -rf /etc/apt/sources.list.d && \
    apt-get purge -y --auto-remove --allow-remove-essential curl debian-keyring debian-archive-keyring apt-transport-https && \
    rm -rf /var/log/apt && \
    mkdir /var/run/kea

ENTRYPOINT ["/usr/sbin/kea-dhcp-ddns"]
CMD ["-c", "/etc/kea/kea-dhcp-ddns.conf"]
# The MIT License
#
# Copyright (c) 2019, Serhiy Makarenko

FROM debian:10-slim
MAINTAINER Serhiy Makarenko <serhiy@makarenko.me>

ARG DEBIAN_FRONTEND=noninteractive

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    apt-utils gnupg curl debian-keyring apt-transport-https ca-certificates && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/gpg/gpg.0607E2621F1564A6.key' | apt-key add - && \
    curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-1-6/cfg/setup/config.deb.txt?distro=debian&codename=buster' > /etc/apt/sources.list.d/isc-kea-1-6.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests isc-kea-dhcp4-server && \
    apt-get purge -y --auto-remove apt-utils gnupg curl debian-keyring apt-transport-https ca-certificates && \
    apt-get clean && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/kea

ENTRYPOINT ["/usr/sbin/kea-dhcp4"]
CMD ["-c", "/etc/kea/kea-dhcp4.conf"]
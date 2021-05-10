# The MIT License
#
# Copyright (c) 2021, Serhiy Makarenko

FROM debian:10-slim AS builder

ARG KEA_VERSION=1.8.2
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    bison flex automake libtool pkg-config build-essential ccache \
    libboost-dev libboost-system-dev liblog4cplus-dev libssl-dev \
    default-libmysqlclient-dev postgresql-server-dev-all libpq-dev \
    python3-sphinx python3-sphinx-rtd-theme \
    apt-utils gnupg curl debian-keyring apt-transport-https ca-certificates && \
    c_rehash && \
    curl -RL -O "https://ftp.isc.org/isc/kea/${KEA_VERSION}/kea-${KEA_VERSION}.tar.gz" && \
    tar xvzf kea-${KEA_VERSION}.tar.gz

ARG PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig
ARG PATH="/usr/lib64/ccache:$PATH"

RUN cd kea-${KEA_VERSION} && \
    autoreconf --install && \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --with-openssl \
        --with-mysql \
        --with-pgsql \
        --with-boost-libs=-lboost_system \
        --enable-generate-docs \
        --enable-shell \
        --disable-static \
        --disable-rpath \
        --enable-generate-parser \
        --disable-dependency-tracking \
        --without-werror && \
    make -j3 && \
    make install-strip && \
    echo "/usr/local/lib/hooks" > /etc/ld.so.conf.d/kea.conf && \
    ldconfig

RUN cd /usr/lib && \
    mkdir isc-kea-dhcp-ddns-libs && \
    for lib in asiodns asiolink cc cfgclient cryptolink database dhcp++ dhcp_ddns dhcpsrv dns++ eval exceptions hooks http log mysql pgsql process stats threads util-io util; do for libso in `ls libkea-${lib}.so*`; do mv ${libso} isc-kea-dhcp-ddns-libs/; done; done && \
    cd /usr/lib/kea/hooks && \
    mkdir isc-kea-dhcp-ddns-hooks && \
    for hook in libdhcp_ha libdhcp_lease_cmds libdhcp_mysql_cb libdhcp_stat_cmds; do mv ${hook}.so isc-kea-dhcp-ddns-hooks/; done && \
    cd /usr/lib && \
    mkdir isc-kea-ctrl-agent-libs && \
    for lib in asiodns asiolink cc cfgclient cryptolink database dhcp++ dhcp_ddns dhcpsrv dns++ eval exceptions hooks http log mysql pgsql process stats threads util-io util; do for libso in `ls libkea-${lib}.so*`; do mv ${libso} isc-kea-ctrl-agent-libs/; done; done && \
    cd /usr/lib/kea/hooks && \
    mkdir isc-kea-ctrl-agent-hooks && \
    for hook in libdhcp_ha libdhcp_lease_cmds libdhcp_mysql_cb libdhcp_stat_cmds; do mv ${hook}.so isc-kea-ctrl-agent-hooks/; done && \
    cd /usr/lib && \
    mkdir isc-kea-dhcp4-libs && \
    for lib in asiodns asiolink cc cfgclient cryptolink database dhcp++ dhcp_ddns dhcpsrv dns++ eval exceptions hooks http log mysql pgsql process stats threads util-io util; do for libso in `ls libkea-${lib}.so*`; do mv ${libso} isc-kea-dhcp4-libs/; done; done && \
    cd /usr/lib/kea/hooks && \
    mkdir isc-kea-dhcp4-hooks && \
    for hook in libdhcp_ha libdhcp_lease_cmds libdhcp_mysql_cb libdhcp_stat_cmds; do mv ${hook}.so isc-kea-dhcp4-hooks/; done



FROM debian:10-slim as isc-kea-dhcp-ddns-server
LABEL maintainer="serhiy.makarenko@me.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    liblog4cplus-1.1-9 libssl1.1 libboost-system1.67.0 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/kea && mkdir /var/lib/kea && mkdir /etc/kea

COPY --from=builder /usr/lib/isc-kea-dhcp-ddns-libs /usr/lib/
COPY --from=builder /usr/lib/kea/hooks/isc-kea-dhcp-ddns-hooks /usr/lib/kea/hooks
COPY --from=builder /usr/sbin/kea-lfc /usr/sbin
COPY --from=builder /usr/sbin/kea-dhcp-ddns /usr/sbin
COPY --from=builder /etc/kea/kea-dhcp-ddns.conf /etc/kea
COPY --from=builder /usr/share/man/man8/kea-lfc.8 /usr/share/man/man8
COPY --from=builder /usr/share/man/man8/kea-dhcp-ddns.8 /usr/share/man/man8

ENTRYPOINT ["/usr/sbin/kea-dhcp-ddns"]
CMD ["-c", "/etc/kea/kea-dhcp-ddns.conf"]

FROM debian:10-slim as isc-kea-ctrl-agent
LABEL maintainer="serhiy.makarenko@me.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    liblog4cplus-1.1-9 libssl1.1 libboost-system1.67.0 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/kea && mkdir /var/lib/kea && mkdir /etc/kea

COPY --from=builder /usr/lib/isc-kea-ctrl-agent-libs /usr/lib/
COPY --from=builder /usr/lib/kea/hooks/isc-kea-ctrl-agent-hooks /usr/lib/kea/hooks
COPY --from=builder /usr/sbin/kea-lfc /usr/sbin
COPY --from=builder /usr/sbin/kea-shell /usr/sbin
COPY --from=builder /usr/sbin/kea-ctrl-agent /usr/sbin
COPY --from=builder /etc/kea/kea-ctrl-agent.conf /etc/kea
COPY --from=builder /usr/share/man/man8/kea-lfc.8 /usr/share/man/man8
COPY --from=builder /usr/share/man/man8/kea-shell.8 /usr/share/man/man8
COPY --from=builder /usr/share/man/man8/kea-ctrl-agent.8 /usr/share/man/man8

ENTRYPOINT ["/usr/sbin/kea-ctrl-agent"]
CMD ["-c", "/etc/kea/kea-ctrl-agent.conf"]

FROM debian:10-slim as isc-kea-dhcp4-server
LABEL maintainer="serhiy.makarenko@me.com"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    liblog4cplus-1.1-9 libssl1.1 libboost-system1.67.0 libmariadb3 libpq5 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/kea && mkdir /var/lib/kea && mkdir /etc/kea

COPY --from=builder /usr/lib/isc-kea-dhcp4-libs /usr/lib/
COPY --from=builder /usr/lib/kea/hooks/isc-kea-dhcp4-hooks /usr/lib/kea/hooks
COPY --from=builder /usr/sbin/kea-lfc /usr/sbin
COPY --from=builder /usr/sbin/kea-dhcp4 /usr/sbin
COPY --from=builder /etc/kea/kea-dhcp4.conf /etc/kea
COPY --from=builder /usr/share/man/man8/kea-lfc.8 /usr/share/man/man8
COPY --from=builder /usr/share/man/man8/kea-dhcp4.8 /usr/share/man/man8

ENTRYPOINT ["/usr/sbin/kea-dhcp4"]
CMD ["-c", "/etc/kea/kea-dhcp4.conf"]

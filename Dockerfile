FROM ubuntu:16.04

RUN sed -i "s/archive.ubuntu.com/10.147.137.47/g" /etc/apt/sources.list
RUN apt-get -y update \
 && apt-get -y --no-install-recommends install \
    curl wget vim vnstat htop iputils-ping tcpdump mtr-tiny git ca-certificates \
    quagga strongswan python python-setuptools \
 && apt-get -y clean \ 
 && rm -rf /var/lib/apt/lists/*

ADD shadowsocks /shadowsocks
ADD build /build
RUN chmod 755 /build/build.sh
RUN /build/build.sh

EXPOSE 4500/udp 500/udp 8083 8083/udp

CMD ["/run.sh"]

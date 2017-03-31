FROM ubuntu:zesty

MAINTAINER Dong Zhu <bluezhudong@gmail.com>

RUN apt-get update && \
    apt-get install -y python-pip && \
    pip install --upgrade pip && \
    pip install shadowsocks

COPY etc/shadowsocks/config.json /etc/shadowsocks/config.json

CMD /usr/local/bin/ssserver -c /etc/shadowsocks/config.json -d start && tail -f /var/log/shadowsocks.log

#!/bin/bash

# 生成密码
passwd=$(openssl rand -base64 8 | md5sum | head -c12)

# 创建镜像

cat << _EOF_ >Dockerfile
FROM ubuntu:14.04
RUN apt-get update && apt-get install -y \
    python-software-properties \
    software-properties-common \
 && add-apt-repository ppa:chris-lea/libsodium \
 && echo "deb http://ppa.launchpad.net/chris-lea/libsodium/ubuntu trusty main" >> /etc/apt/sources.list \
 && echo "deb-src http://ppa.launchpad.net/chris-lea/libsodium/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y libsodium-dev python-pip

RUN pip install shadowsocks
RUN ssserver -p 443 -k ${passwd} -m aes-256-cfb
_EOF_

cf ic build -t ub:v1 . 

# 运行容器
cf ic ip bind $(cf ic ip request | cut -d \" -f 2 | tail -1) $(cf ic run -m 1024 -p 443 registry.ng.bluemix.net/`cf ic namespace get`/ub:v1)

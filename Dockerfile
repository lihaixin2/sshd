# Start with Ubuntu base image
FROM ubuntu:16.04
MAINTAINER Haixin Lee <docker@lihaixin.name>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV ROOT_PW passWord
ENV TZ "UTC"

# Install OpenSSH
RUN    apt-get update -y && apt-get install -y  apt-utils  && apt-get install -y --no-install-recommends openssh-server
# Set password

RUN  mkdir /var/run/sshd && \
         echo "root:`echo $ROOT_PW`" | chpasswd && \
         : Allow root login with password && \
        sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
         : Prevent user being kicked off after login && \
        sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

#other use pag
RUN apt-get install -y --no-install-recommends gettext-base wget curl  iputils-ping iproute2 mtr net-tools supervisor

# config timezone

RUN  echo $TZ > /etc/timezone && \
         dpkg-reconfigure --frontend noninteractive tzdata && \
         apt-get upgrade --yes

# 删除不必要的软件和Apt缓存包列表
RUN apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Docker's supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose SSH port
# EXPOSE 22

# Run SSH server without detaching

CMD ["/usr/bin/supervisord"]

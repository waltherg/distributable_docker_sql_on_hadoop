ARG hadoop_image_name
ARG image_version
FROM ${hadoop_image_name}:${image_version}
MAINTAINER Georg Walther (contact@georg.io)

ARG apache_mirror
ARG zookeeper_version
ARG zookeeper_root

ENV ZOOKEEPER_HOME=$zookeeper_root
ENV PATH=$ZOOKEEPER_HOME/bin:$PATH

RUN echo "Install system requirements ..." \
    && apt-get update \
    && apt-get --yes install \
        openssh-server \
    && mkdir -p /run/sshd

RUN echo "Download and extract ZooKeeper package ..." \
    && wget ${apache_mirror}/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz \
    && tar xvf zookeeper-${zookeeper_version}.tar.gz --gzip \
    && mv zookeeper-${zookeeper_version} ${zookeeper_root} \
    && rm zookeeper-${zookeeper_version}.tar.gz

ADD ./configurations/zoo.cfg ${zookeeper_root}/conf/zoo.cfg
ADD ./ssh_keys/id_rsa.pub /root/.ssh/authorized_keys

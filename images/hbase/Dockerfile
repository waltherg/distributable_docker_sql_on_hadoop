ARG hadoop_image_name
ARG image_version
FROM ${hadoop_image_name}:${image_version}
MAINTAINER Georg Walther (contact@georg.io)

ARG apache_mirror
ARG hbase_version
ARG hbase_root

ENV HBASE_HOME=$hbase_root
ENV PATH=$HBASE_HOME/bin:$PATH

RUN echo "Install system requirements ..." \
    && apt-get update \
    && apt-get --yes install \
        openssh-server \
    && mkdir -p /run/sshd

RUN echo "Download and extract HBase package ..." \
    && wget ${apache_mirror}/hbase/${hbase_version}/hbase-${hbase_version}-bin.tar.gz \
       -O hbase-${hbase_version}-bin.tar.gz \
    && tar xvf hbase-${hbase_version}-bin.tar.gz --gzip \
    && mv hbase-${hbase_version} ${hbase_root} \
    && rm hbase-${hbase_version}-bin.tar.gz

ADD ./configurations/hbase-site.xml ${hbase_root}/conf/hbase-site.xml
ADD ./configurations/hbase-env.sh ${hbase_root}/conf/hbase-env.sh
ADD ./configurations/regionservers ${hbase_root}/conf/regionservers

ADD ./ssh_keys/id_rsa.pub /root/.ssh/authorized_keys
ADD ./ssh_keys/id_rsa /root/.ssh/id_rsa
ADD ./configurations/ssh_config /root/.ssh/config

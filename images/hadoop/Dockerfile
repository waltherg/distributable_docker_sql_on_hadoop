FROM ubuntu:17.10
MAINTAINER Georg Walther (contact@georg.io)

ARG apache_mirror
ARG hadoop_version
ARG hadoop_root

ENV HADOOP_PREFIX=$hadoop_root
ENV HADOOP_HOME=$HADOOP_PREFIX
ENV HADOOP_COMMON_HOME=$HADOOP_PREFIX
ENV HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
ENV HADOOP_HDFS_HOME=$HADOOP_PREFIX
ENV HADOOP_MAPRED_HOME=$HADOOP_PREFIX
ENV HADOOP_YARN_HOME=$HADOOP_PREFIX

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

USER root

RUN echo "Install required system packages ..." \
    && apt-get update \
    && apt-get --yes install \
        openjdk-8-jre \
        openssh-client \
        python3 \
        wget \
    && ln -s /usr/bin/python3 /usr/bin/python

RUN echo "Download and extract Hadoop source ..." \
    && wget ${apache_mirror}/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz \
    && tar xvf hadoop-${hadoop_version}.tar.gz --gzip \
    && mv hadoop-${hadoop_version} ${hadoop_root} \
    && rm hadoop-${hadoop_version}.tar.gz

RUN echo "Create directories for HDFS nodes and logging ..." \
    && mkdir -p /hdfs_logs \
    && mkdir -p /hdfs_data \
    && mkdir -p ${hadoop_root}/logs \
    && chown -R 755 ${hadoop_root}/logs

ADD ./configurations/core-site.xml ${hadoop_root}/etc/hadoop/core-site.xml
ADD ./configurations/hdfs-site.xml ${hadoop_root}/etc/hadoop/hdfs-site.xml
ADD ./configurations/yarn-site.xml ${hadoop_root}/etc/hadoop/yarn-site.xml

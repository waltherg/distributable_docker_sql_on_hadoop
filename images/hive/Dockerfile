ARG hadoop_image_name
ARG image_version
FROM ${hadoop_image_name}:${image_version}
MAINTAINER Georg Walther (contact@georg.io)

ARG apache_mirror
ARG hive_version
ARG hive_root

ENV HIVE_HOME=$hive_root
ENV PATH=$HIVE_HOME/bin:$PATH

RUN echo "Download and extract Hive package ..." \
    && wget ${apache_mirror}/hive/hive-${hive_version}/apache-hive-${hive_version}-bin.tar.gz \
    && tar xvf apache-hive-${hive_version}-bin.tar.gz --gzip \
    && mv apache-hive-${hive_version}-bin ${hive_root} \
    && rm apache-hive-${hive_version}-bin.tar.gz

ADD ./configurations/hive-site.xml ${hive_root}/conf/hive-site.xml

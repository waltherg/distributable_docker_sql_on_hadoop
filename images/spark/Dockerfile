ARG hadoop_image_name
ARG image_version
FROM ${hadoop_image_name}:${image_version}
MAINTAINER Georg Walther (contact@georg.io)

ARG apache_mirror
ARG spark_version
ARG spark_root

ENV SPARK_HOME=$spark_root
ENV PATH=$SPARK_HOME/bin:$PATH

RUN echo "Download and extract Spark package ..." \
    && wget ${apache_mirror}/spark/spark-${spark_version}/spark-${spark_version}-bin-without-hadoop.tgz \
       -O spark-${spark_version}-bin-without-hadoop.tgz \
    && tar xvf spark-${spark_version}-bin-without-hadoop.tgz --gzip \
    && mv spark-${spark_version}-bin-without-hadoop ${spark_root} \
    && rm spark-${spark_version}-bin-without-hadoop.tgz

ADD ./configurations/spark-env.sh ${spark_root}/conf/spark-env.sh

#!/usr/bin/env sh

cwd=$(pwd)

cd ./images/hadoop
docker build \
    --tag $hadoop_image_name:$image_version \
    --build-arg apache_mirror=$apache_mirror \
    --build-arg hadoop_version=$hadoop_version \
    --build-arg hadoop_root=$hadoop_root \
    .

cd $cwd

cd ./images/hive
docker build \
    --tag $hive_image_name:$image_version \
    --build-arg hadoop_image_name=$hadoop_image_name \
    --build-arg image_version=$image_version \
    --build-arg apache_mirror=$apache_mirror \
    --build-arg hive_version=$hive_version \
    --build-arg hive_root=$hive_root \
    .

cd $cwd

cd ./images/hue
docker build \
    --no-cache \
    --tag $hue_image_name:$image_version \
    --build-arg hue_root=$hue_root \
    .

cd $cwd

mkdir -p ./images/ssh_keys
yes n | ssh-keygen -f ./images/ssh_keys/id_rsa

cd ./images/hbase
cp -R ../ssh_keys .
docker build \
    --tag $hbase_image_name:$image_version \
    --build-arg hadoop_image_name=$hadoop_image_name \
    --build-arg image_version=$image_version \
    --build-arg apache_mirror=$apache_mirror \
    --build-arg hbase_version=$hbase_version \
    --build-arg hbase_root=$hbase_root \
    .

cd $cwd

cd ./images/zookeeper
cp -R ../ssh_keys .
docker build \
    --tag $zookeeper_image_name:$image_version \
    --build-arg hadoop_image_name=$hadoop_image_name \
    --build-arg image_version=$image_version \
    --build-arg apache_mirror=$apache_mirror \
    --build-arg zookeeper_version=$zookeeper_version \
    --build-arg zookeeper_root=$zookeeper_root \
    .

cd $cwd

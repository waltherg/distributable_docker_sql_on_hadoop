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

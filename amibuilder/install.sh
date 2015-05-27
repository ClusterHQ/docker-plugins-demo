#!/bin/bash

# this is the second stage where we install everything onto
# a running Amazon instance
export DEBIAN_FRONTEND=noninteractive
set -e

# vars
FLOCKER_ZPOOL_SIZE='10G'
FLOCKER_PREFIX='/var/opt/flocker'

DOCKER_NAME="1.7.0-dev-experimental"

BASE_DEB_FOLDER="http://build.clusterhq.com/results/omnibus/storage-driver-configuration-FLOC-1925/ubuntu-14.04"
CGROUPSFS_FOLDER="http://ftp.uk.debian.org/debian/pool/main/c/cgroupfs-mount"
CGROUPSFS_BINARY="cgroupfs-mount_1.2_all.deb"

# deps
add-apt-repository -y ppa:zfs-native/stable
add-apt-repository -y ppa:james-page/docker
add-apt-repository -y "deb $BASE_DEB_FOLDER /"
apt-get -qq update

apt-get install -y \
  apt-transport-https \
  software-properties-common \
  cgroup-lite \
  xz-utils \
  libc6-dev \
  zfsutils

# there is no package for cgroupfs-mount on Ubuntu 14.04 so we install manually
cd ~ && wget $CGROUPSFS_FOLDER/$CGROUPSFS_BINARY && dpkg -i $CGROUPSFS_BINARY

# zpool
mkdir -p $FLOCKER_PREFIX
truncate --size $FLOCKER_ZPOOL_SIZE $FLOCKER_PREFIX/pool-vdev
zpool create flocker $FLOCKER_PREFIX/pool-vdev

# install flocker
apt-get -y --force-yes install clusterhq-flocker-node clusterhq-flocker-cli

# copy weave script
cp /vagrant/compiled/files/weave /usr/bin/
chmod a+x /usr/bin/weave

# setup docker
service docker.io stop
cp /vagrant/compiled/files/docker /usr/bin/docker
chmod a+x /usr/bin/docker
groupadd docker || true
usermod -a -G docker vagrant
cp /vagrant/docker.conf /etc/init/
start docker
sleep 2

# import docker images (created by the compiler)
for i in /vagrant/compiled/files/*.tar
do docker load -i $i
done

docker pull busybox:latest redis:latest python:2.7 errordeveloper/iojs-minimal-runtime:v1.0.1
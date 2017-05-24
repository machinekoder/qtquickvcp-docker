#!/usr/bin/env bash

set -e # Halt on errors
set -x # Be verbose

##########################################################################
# GET DEPENDENCIES
##########################################################################
# select fastet mirror
apt-get update
apt-get install -y netselect-apt
netselect-apt
mv sources.list /etc/apt/sources.list

# add Machinekit repository
apt-key adv --keyserver keyserver.ubuntu.com --recv 43DDF224
sh -c \
   "echo 'deb http://deb.machinekit.io/debian jessie main' > \
    /etc/apt/sources.list.d/machinekit.list"

apt update
# basic dependencies (needed by Docker image)
apt install -y sudo git wget automake unzip gcc g++ binutils bzip2
# remove sudo pw
echo "ALL            ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/unlock_all
# QtQuickVcp's dependencies:
apt-get install -y pkg-config libprotobuf-dev protobuf-compiler libzmq3-dev
apt-get install -y build-essential gdb dh-autoreconf libgl1-mesa-dev libxslt1.1 git
# dependencies of qmlplugindump
apt-get install -y libfontconfig1 libxrender1 libdbus-1-3 libegl1-mesa
# test dependencies
apt-get install -y xvfb libxi6
# cleanup afterwards
apt-get clean

# Build AppImageKit
[ -d "AppImageKit" ] || git clone --branch 6 https://github.com/probonopd/AppImageKit.git
cd AppImageKit/
bash -ex build.sh

 cd ..

 [ -d "Qt-Deployment-Scripts" ] || git clone --depth 1 https://github.com/machinekoder/Qt-Deployment-Scripts.git
 cd Qt-Deployment-Scripts
 make install
 cd ..

# install Qt
mkdir -p qt5 && wget -q -O qt5.tar.bz2 http://ci.roessler.systems/files/qt-bin/Qt-5.8-Linux-x64.tar.bz2
tar xjf qt5.tar.bz2 -C qt5
rm qt5.tar.bz2

# make directories accessible by all users
chmod -R a+rw /qt5

# mark image as prepared
touch /etc/system-prepared

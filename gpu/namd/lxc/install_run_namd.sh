#!/bin/bash

# inside the lxc container
apt-get update && apt-get install perl vim wget --fix-missing

mkdir /usr/local/CUDA-build
sh NVIDIA-Linux-x86_64-375.26.run --extract=/usr/local/CUDA-build/
cd /usr/local/CUDA-build
sh NVIDIA-Linux-x86_64-375.26.run --no-kernel-module

nvidia-smi

cd /usr/local

tar -xvf NAMD_CVS-2017-03-16_Linux-x86_64-multicore-CUDA.tar.gz
cd NAMD_CVS-2017-03-16_Linux-x86_64-multicore-CUDA
mv ../apoa1.tar.gz .
mv ../f1atpase.tar .
mv ../stmv.tar .
tar -xvf apoa1.tar.gz
tar -xvf f1atpase.tar
tar -xvf stmv.tar
mkdir /tmp/test/results /usr/tmp
cd apoa1
for i in {1..10}; do ../namd2 +idlepoll +p8 apoa1.namd 2>&1 > /tmp/test/results/namd.lxd.apoa1_$i.out; done
cd ../f1atpase
for i in {1..10}; do ../namd2 +idlepoll +p8 f1atpase.namd 2>&1 > /tmp/test/results/namd.lxd.f1atpase_$i.out; done
cd ../stmv
for i in {1..10}; do ../namd2 +idlepoll +p8 stmv.namd 2>&1 > /tmp/test/results/namd.lxd.stmv_$i.out; done
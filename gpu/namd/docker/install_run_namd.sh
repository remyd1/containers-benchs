#!/bin/bash

# inside the docker container
apt-get update && apt-get -y install vim wget
cd /usr/local
wget ftp://ngsisem.mbb.univ-montp2.fr/mbbteam/datadir/namd_install_with_samples.sh
bash namd_install_with_samples.sh
cd NAMD_CVS-2017-03-16_Linux-x86_64-multicore-CUDA/apoa1
mkdir -p /tmp/test/results /usr/tmp
for i in {1..10}; do ../namd2 +idlepoll +p8 apoa1.namd 2>&1 > /tmp/test/results/namd.docker.apoa1_$i.out; done
cd ../f1atpase
for i in {1..10}; do ../namd2 +idlepoll +p8 f1atpase.namd 2>&1 > /tmp/test/results/namd.docker.f1atpase_$i.out; done
cd ../stmv
for i in {1..10}; do ../namd2 +idlepoll +p8 stmv.namd 2>&1 > /tmp/test/results/namd.docker.stmv_$i.out; done

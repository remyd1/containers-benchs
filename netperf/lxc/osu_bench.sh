#!/bin/bash
#LXC and Baremetal .sh osu_benchmark 
#RUN sudo osu_bench.sh

        apt-get update
        apt-get install -y bash wget build-essential gcc time libc6-dev libgcc-5-dev
        apt-get install -y libopenmpi-dev openmpi-common openmpi-bin openmpi-doc libatlas3-base libatlas-base-dev libatlas-dev libatlas-doc
	wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.3.2.tar.gz
	tar -xf osu-micro-benchmarks-5.3.2.tar.gz
	cd osu-micro-benchmarks-5.3.2
	./configure CC=/usr/local/bin/mpicc CXX=/usr/local/bin/mpicxx
	make && make install
	echo "Osu_Benchmark Build!"

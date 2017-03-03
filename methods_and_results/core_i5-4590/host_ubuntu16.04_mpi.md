# Benchmark on the 4 nodes

Host :
  - 1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
  - kernel: `4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux`
  - release: xenial Ubuntu 16.04.2 LTS

In order to be able to check the consistency of other benchmarks, I run an overall test with the HPL Linpack full version locally on the 4 nodes.


## method

```bash
wget http://www.netlib.org/benchmark/hpl/hpl-2.2.tar.gz
tar -xvf hpl-2.2.tar.gz
ln -s hpl-2.2 hpl
cd hpl
cp setup/Make.UNKNOWN ./Make.Linux
# installing atlas lib (it contains the blas lib needed for HPL) and openmpi
apt-get install -y libopenmpi-dev openmpi-common openmpi-bin openmpi-doc libatlas3-base libatlas-base-dev libatlas-dev libatlas-doc

vim Make.Linux
# modifications
  ARCH         = Linux
  MPdir        = /usr/lib/openmpi
  MPinc        = /usr/lib/openmpi/include
  LAdir        = /usr/lib/atlas-base/

make arch=Linux clean_arch_all
make arch=Linux

# now, main binary is bin/<arch>/xhpl => bin/Linux/xhpl
sha1sum bin/Linux/xhpl
137cfbf0f5efea91d1909d93e4d670e9bfcff8f1  bin/Linux/xhpl

# setting HPL values N / P / Q / NB
# using http://www.clusterkit.co.th/cluster_cal.php

#clearing cache
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
for i in {1..4}; do echo "localhost" >> nodes; done
mpirun -np 4 -hostfile nodes ./xhpl | tee HPL.out
```


## Results

```
N      :    1280
NB     :     128
PMAP   : Row-major process mapping
P      :       2
Q      :       2
PFACT  :   Right
NBMIN  :       4
NDIV   :       2
RFACT  :   Crout
BCAST  :  1ringM
DEPTH  :       1
SWAP   : Mix (threshold = 64)
L1     : transposed form
U      : transposed form
EQUIL  : yes
ALIGN  : 8 double precision words

================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR11C2R4        1280   128     2     2               0.06              2.403e+01
HPL_pdgesv() start time Fri Mar  3 09:49:31 2017

HPL_pdgesv() end time   Fri Mar  3 09:49:31 2017
```

24,03 GFlops for the 4 cores

Then, for single core tests, I should have about 6 GFlops by core (a bit more is possible (without mpi communication, and some additionnal libs))

# Benchmark on the 4 cores

Host :
  - 1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
  - kernel: `4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux`
  - release: xenial Ubuntu 16.04.2 LTS

In order to be able to check the consistency of other benchmarks, I run an overall test with the HPL Linpack full version locally on the 4 nodes.


## method

I will use the same method as the bare-metal. But the the HPL basics stuffs will be directly in the [singularity spec file](../../linpack/HPL/defs_dockerfiles/singularity/xenial_docker_hpllinpack.def)

```
BootStrap: docker
From: ubuntu:16.04
IncludeCmd: yes

%post
    sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
    apt-get update
    apt-get install -y bash wget build-essential gcc time libc6-dev libgcc-5-dev
    apt-get install -y libopenmpi-dev openmpi-common openmpi-bin openmpi-doc libatlas3-base libatlas-base-dev libatlas-dev libatlas-doc
    cd /usr/local
    wget http://www.netlib.org/benchmark/hpl/hpl-2.2.tar.gz
    tar -xvf hpl-2.2.tar.gz
    mkdir -p $HOME
    ln -s /usr/local/hpl-2.2 $HOME/hpl
    cd /usr/local/hpl-2.2/setup \
    && sh make_generic
    cp /usr/local/hpl-2.2/setup/Make.UNKNOWN /usr/local/hpl-2.2/Make.Linux
    cd /usr/local/hpl-2.2 \
    && sed -i "s|UNKNOWN|Linux|" Make.Linux \
    && sed -ri "s|MPdir.+=|MPdir        = /usr/lib/openmpi|" Make.Linux \
    && sed -ri "s|MPinc.+=|MPinc        = /usr/lib/openmpi/include|" Make.Linux \
    && sed -ri "s|LAdir.+=|LAdir        = /usr/lib/atlas-base/|" Make.Linux \
    && make arch=Linux clean_arch_all \
    && make arch=Linux

```

The other things will be done in the singularity shell as root.

```bash
# on the host
sudo singularity create --2048 linpack.img
sudo singularity bootstrap linpack.img xenial_docker_hpllinpack.def
# setting HPL values N / P / Q / NB
# using http://www.clusterkit.co.th/cluster_cal.php
# I have 16GB of memory
# root homedir is share with the container if launched with sudo
sudo cp $HOME/hpl/bin/Linux/HPL.dat /root/
sudo singularity shell -w linpack.img

# within container
cd /usr/local/hpl-2.2

# we have the same sha1sum that we have on the host side
sha1sum bin/Linux/xhpl
137cfbf0f5efea91d1909d93e4d670e9bfcff8f1  bin/Linux/xhpl

cp /root/HPL.dat ./bin/Linux/

#clearing cache
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
cd bin/Linux
for i in {1..4}; do echo "localhost" >> nodes; done
mpirun --allow-run-as-root -np 4 -hostfile nodes ./xhpl | tee HPL.out
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
--------------------------------------------------------------------------------

- The matrix A is randomly generated for each test.
- The following scaled residual check will be computed:
      ||Ax-b||_oo / ( eps * ( || x ||_oo * || A ||_oo + || b ||_oo ) * N )
- The relative machine precision (eps) is taken to be               1.110223e-16
- Computational tests pass if scaled residuals are less than                16.0

================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR11C2R4        1280   128     2     2               0.06              2.438e+01
HPL_pdgesv() start time Wed Mar  8 11:05:40 2017

HPL_pdgesv() end time   Wed Mar  8 11:05:40 2017
```

24,38 GFlops for the 4 cores

Tests are quite similar than the tests on the host, even slightly better. In fact, I launched it many times and I get results between 16 and 24 GFlops, but it is the same on the host.

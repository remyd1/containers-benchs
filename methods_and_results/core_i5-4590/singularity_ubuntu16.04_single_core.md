# Benchmarks with singularity and ubuntu xenial

Host :
  - 1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
  - kernel: `4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 - x86_64 x86_64 x86_64 GNU/Linux`
  - release: xenial Ubuntu 16.04.2 LTS

## Singularity Install

`singularity requirements: autoconf, gcc, make, automake, libtool`

```bash
git clone https://github.com/singularityware/singularity.git
cd singularity
./autogen.sh
./configure --prefix=/usr/local --sysconfdir=/etc
make
sudo make install
```

Firstly we create an empty image

```
sudo singularity create --size 2048 linpack_simple.img
```

Then we are using debootstrap to fill it with a specification singularity file

cat `xenial_linpack.def`

```
BootStrap: debootstrap
OSVersion: xenial
MirrorURL: http://fr.archive.ubuntu.com/ubuntu/
Include: bash wget gcc build-essential time libc6-dev libgcc-5-dev

%post
    mkdir /usr/local/test
    cd /usr/local/test
    wget --no-check-certificate  https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
    wget --no-check-certificate  https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
    gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

%runscript
    /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /usr/local/test/results_simple_linpack.o
```

BootStraping image :

```bash
sudo singularity bootstrap linpack_simple.img xenial_linpack.def
```


## First results

Initial bootstrap can take a while (about 20 minutes locally).

To be faster, we can make our bootstrap from a docker image :

```
BootStrap: docker
From: ubuntu:16.04
IncludeCmd: yes

%post
    sed -i 's/main/main restricted universe/g' /etc/apt/sources.list
    apt-get update
    apt-get install -y bash wget build-essential gcc time libc6-dev libgcc-5-dev
    mkdir /usr/local/test
    cd /usr/local/test
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
    gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

%runscript
    /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /usr/local/test/results_simple_linpack.o
```


Then, results are quite similar than bare-metal results :

```bash
sudo singularity shell -w linpack_simple.img
Singularity.linpack_simple.img> # /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /tmp/results_simple_linpack.o
Singularity.linpack_simple.img> # bash /usr/local/test/get_flops.sh /usr/local/test/results_simple_linpack.o
 min:5782417.504
 max:6515941.653
 average:6.33008e+06
Singularity.linpack_simple.img> # sha1sum /usr/local/test/linpack_simple
 413ccc1dae31a108733e4252ae6b57fc8393d15c  /usr/local/test/linpack_simple
```

By the way, it is also possible to launch the same exact command from the runscript `/singularity` inside the container generated (`%runscript` part in the specification file) :

```bash
sudo singularity -w run linpack_simple.img
sudo singularity exec linpack_simple.img bash /usr/local/test/get_flops.sh /usr/local/test/results_simple_linpack.o
 min:5765307.787
 max:6532316.065
 average:6.34296e+06

sudo singularity exec linpack_simple.img
cat /usr/local/test/time_simple_linpack.o
 Command exited with non-zero status 36
 146.32user 2.41system 2:28.76elapsed 99%CPU (0avgtext+0avgdata 1640maxresident)k
 376inputs+8outputs (1major+152minor)pagefaults 0swaps

 singularity exec linpack_simple.img gcc --version
 gcc (Ubuntu 5.3.1-14ubuntu2) 5.3.1 20160413
 ...
```

The binary is different, but the gcc version also differs (5.3 vs 5.4 on the host)

## About singularity and root

The process is owned by root on the host :

```bash
ps aufx |grep linpack
remy      6238  0.0  0.0  14264  1036 pts/4    S+   13:59   0:00          |       |   |   |   \_ grep --color=auto linpack
root      5504  0.0  0.0  75496  4356 pts/7    S+   13:58   0:00          |       |   |       \_ sudo singularity run -w linpack_simple.img
root      5515  0.0  0.0   4364   772 pts/7    S+   13:58   0:00          |       |   |                   \_ /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple
root      5516  100  0.0   4680  1332 pts/7    R+   13:58   1:16          |       |   |                       \_ /usr/local/test/linpack_simple
```

However, we could the same as a single user :

```bash
singularity shell linpack_simple.img
Singularity.linpack_simple.img> pwd
Singularity.linpack_simple.img> ls
# you should see your home / the directory you were previously.
# this one is available and writable on the container, like /tmp
# uid are the same inside and outside container
Singularity.linpack_simple.img> cp /usr/local/test/* .
# then you can your runs normaly, changing just your paths
/usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o
```

Results are then available in your home directory (inside and outside the container, because it is bind mounted).


## Go back to tests

```bash
# 3rd run
sudo singularity run -w linpack_simple.img             
sudo singularity exec linpack_simple.img cat /usr/local/test/time_simple_linpack.o
 Command exited with non-zero status 130
 148.83user 0.53system 2:29.36elapsed 100%CPU (0avgtext+0avgdata 1548maxresident)k
 368inputs+8outputs (1major+147minor)pagefaults 0swaps
sudo singularity exec linpack_simple.img bash /usr/local/test/get_flops.sh /usr/local/test/results_simple_linpack.o
 min:5785953.407
 max:6486216.554
 average:6.31071e+06
```

Runs average: 6.328 GFlops

Less than 1% lower than bare-metal (0.08%).

After a gcc upgrade from apt and a new compilation we could check that we have the same binary :

```bash
apt-get update && apt-get dist-upgrade
gcc --version
 gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
...
cd /usr/local/test/
ls
 get_flops.sh  linpack_simple  linpack_simple_timeout.c  results_simple_linpack.o  time_simple_linpack.o
gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c
cat /etc/apt/sources.list
 deb http://fr.archive.ubuntu.com/ubuntu xenial main restricted universe
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial main restricted
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial universe
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial universe
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates universe
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial-updates universe
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial multiverse
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial multiverse
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates multiverse
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial-updates multiverse
 deb http://fr.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
 deb-src http://fr.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse
 deb http://security.ubuntu.com/ubuntu xenial-security main restricted
 deb-src http://security.ubuntu.com/ubuntu xenial-security main restricted
 deb http://security.ubuntu.com/ubuntu xenial-security universe
 deb-src http://security.ubuntu.com/ubuntu xenial-security universe
 deb http://security.ubuntu.com/ubuntu xenial-security multiverse
 deb-src http://security.ubuntu.com/ubuntu xenial-security multiverse

sha1sum linpack_simple
   7e9f602eba17fd404ced912d0d48c80e82e7978e  linpack_simple

# 4th run avec le nouveau binaire
bash /singularity
bash get_flops.sh results_simple_linpack.o
 min:5770860.140
 max:6537729.186
 average:6.34508e+06
cat time_simple_linpack.o
 Command exited with non-zero status 45
 148.22user 0.57system 2:28.80elapsed 100%CPU (0avgtext+0avgdata 1604maxresident)k
 0inputs+8outputs (0major+143minor)pagefaults 0swaps

# 5th run
bash /singularity                                                                       
cat time_simple_linpack.o                                                               
 Command exited with non-zero status 136
 147.96user 0.80system 2:28.83elapsed 99%CPU (0avgtext+0avgdata 1604maxresident)k
 0inputs+8outputs (0major+144minor)pagefaults 0swaps
bash get_flops.sh results_simple_linpack.o
 min:5790939.706
 max:6541888.115
 average:6.34671e+06

# 6th run
cat time_simple_linpack.o                                                               
 Command exited with non-zero status 209
 148.16user 0.61system 2:28.78elapsed 99%CPU (0avgtext+0avgdata 1700maxresident)k
 0inputs+8outputs (0major+144minor)pagefaults 0swaps
bash get_flops.sh results_simple_linpack.o                                              
 min:5815635.392
 max:6516713.032
 average:6.33934e+06

```

Runs average: 6.344 GFlops

Less than 1% lower than bare-metal (0.06%).

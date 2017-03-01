# Benchmarks with singularity et centos

1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz

Firstly we will create and empty image

```
sudo singularity create --size 2048 centos_linpack.img
# we will have to install yum, otherwise the centos debootstrap from myu ubuntu host won't work (except by using a docker image; see later)
apt-get install -y yum
```

## BootStraping image

Then, we will use debootstrap to fill our image with a singularity specification file

cat `centos_linpack.def`

```
BootStrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum wget time gcc.x86_64 glibc-devel g++ vim

%post
    yum -y groupinstall "Development Tools"
    mkdir /usr/local/test
    cd /usr/local/test
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
```


```bash
sudo singularity bootstrap centos_linpack.img centos_linpack.def
```


## First results

The yum debootstrap is slow but really faster than a real debootstrap (1mn38 locally).

```bash
sudo singularity shell -w linpack_simple.img
Singularity.centos_linpack.img> gcc --version
gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-11)
...
Singularity.centos_linpack.img> cd /usr/local/test/
Singularity.centos_linpack.img> ls
get_flops.sh  linpack_simple_timeout.c
Singularity.centos_linpack.img> gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c
Singularity.centos_linpack.img> sha1sum linpack_simple
 c1a5362a2f173cc8c4e48b9f20ebfe1a6659e19d  linpack_simple

# 1st run
Singularity.centos_linpack.img> /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /usr/local/test/results_simple_linpack.o
Singularity.centos_linpack.img> cat time_simple_linpack.o && bash get_flops.sh results_simple_linpack.o
 121.66user 4.24system 2:05.92elapsed 99%CPU (0avgtext+0avgdata 1752maxresident)k
 0inputs+8outputs (0major+153minor)pagefaults 0swaps
 min:4849287.356
 max:6540899.225
 average:5.53725e+06

# 2nd run
Singularity.centos_linpack.img> cat time_simple_linpack.o && bash get_flops.sh results_simple_linpack.o
 122.05user 0.58system 2:02.63elapsed 99%CPU (0avgtext+0avgdata 1840maxresident)k
 0inputs+8outputs (0major+155minor)pagefaults 0swaps
 min:4849287.356
 max:6540899.225
 average:5.76609e+06

# 3rd run
Singularity.centos_linpack.img> cat time_simple_linpack.o && bash get_flops.sh results_simple_linpack.o
 121.52user 0.53system 2:02.05elapsed 100%CPU (0avgtext+0avgdata 1752maxresident)k
 0inputs+8outputs (0major+153minor)pagefaults 0swaps
 min:5514875.817
 max:5984226.950
 average:5.79928e+06
```

Runs average : 5.701 GFlops

Performances results show a decrease of 10.65% compare to runs on my host (ubuntu).

## Compiling with gcc5.1 and results

```bash
Singularity.centos_linpack.img> rpm -qa
# empty -> yum database is corrupted
Singularity.centos_linpack.img> cat << EOF > /etc/yum.repos.d/Fedora-Core23.repo                                                
[warning:fedora]
name=fedora
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-23&arch=\$basearch
enabled=1
gpgcheck=0
EOF

Singularity.centos_linpack.img> yum install -y gcc --enablerepo=warning:fedora
Singularity.centos_linpack.img> cd /usr/local/test
Singularity.centos_linpack.img> gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c
Singularity.centos_linpack.img> sha1sum linpack_simple
282768f0bae9b0a0f731c8ed6eabc70bd7f3e03e  linpack_simple
Singularity.centos_linpack.img> gcc --version
gcc (GCC) 5.1.1 20150618 (Red Hat 5.1.1-4)
...
```

To get a consistent rpm database, I will use a docker bootstrap (in fact, the database of yum is built from the host and is different for the container).

 `cat centos_docker_linpack.def`
```
BootStrap: docker
From: centos:centos7
IncludeCmd: yes

%post
    yum -y install epel-release
    yum -y install wget time gcc.x86_64 glibc-devel
    mkdir /usr/local/test
    cd /usr/local/test
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
    wget --no-check-certificate https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
    gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

%runscript
    /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /usr/local/test/results_simple_linpack.o
```

Note : it does not change from a performance point of view : 5.828 GFlops for the average on 3 runs (8.7% lower than bare-metal results).


```bash

# 1st run
Singularity.centos_linpack.img> /usr/bin/time -o /usr/local/test/time_simple_linpack.o /usr/local/test/linpack_simple > /usr/local/test/results_simple_linpack.o
Singularity.centos_linpack.img> cat time_simple_linpack.o && bash get_flops.sh
 118.83user 0.45system 1:59.28elapsed 100%CPU (0avgtext+0avgdata 1980maxresident)k
 0inputs+8outputs (0major+156minor)pagefaults 0swaps
 min:5805468.695
 max:5812531.570
 average:5.80925e+06
 118.83user 0.45system 1:59.28elapsed 100%CPU (0avgtext+0avgdata 1980maxresident)k
 0inputs+8outputs (0major+156minor)pagefaults 0swaps
 min:5805468.695
 max:5812531.570
 average:5.80925e+06

# 2nd run
Singularity.centos_linpack.img> cat time_simple_linpack.o && bash get_flops.sh results_simple_linpack.o
 158.34user 0.59system 2:38.94elapsed 99%CPU (0avgtext+0avgdata 1868maxresident)k
 0inputs+8outputs (0major+151minor)pagefaults 0swaps
 min:5764412.723
 max:5820104.643
 average:5.80711e+06

# 3rd run
cat time_simple_linpack.o && bash get_flops.sh results_simple_linpack.o             
 138.64user 0.65system 2:19.30elapsed 99%CPU (0avgtext+0avgdata 1860maxresident)k
 0inputs+8outputs (0major+153minor)pagefaults 0swaps
 min:5728638.269
 max:5811537.725
 average:5.79044e+06

```

Runs average : 5.802 GFlops

9.6% lower than bare-metal.

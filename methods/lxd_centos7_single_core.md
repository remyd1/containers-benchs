# Benchmarks with Centos7 single core and LXD on an ubuntu host

1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz

## Local tests with LXD (different distro from the host)

Package lxd 2.0.9-0ubuntu1~16.04.1

This is the same method as this [one](lxd_ubuntu16_single_core.md) but with centos7 in the container.

```bash
lxc stop ubuntu64
lxc image list images: |grep -i centos/7
lxc launch images:centos/7/amd64 centos7
lxc file push linpack_simple centos7/tmp/
#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
lxc exec centos7 -- /bin/bash
uname -a
    Linux centos7 4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
yum install -y time gcc.x86_64 glibc-devel
/usr/bin/time -o /tmp/time_simple_linpack.o /tmp/linpack_simple > /tmp/results_simple_linpack.o
```

## Results without compilation


```bash
[root@centos7 tmp]# ./get_flops.sh results_simple_linpack.o                                                        min:5461333.333
max:6465716.475
average:5.89563e+06


cat /tmp/time_simple_linpack.o
158.15user 0.79system 2:38.98elapsed 99%CPU (0avgtext+0avgdata 1496maxresident)k
40inputs+8outputs (0major+147minor)pagefaults 0swaps
```

The perf loss is around 9.2%, with more different results (big standard deviation).



## With compilation

```bash
lxc file push linpack_simple.c centos7/tmp/
#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
lxc exec centos7 -- /bin/bash
gcc --version
    gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-11)
```


### First tests with gcc4.8

```bash
lxc exec centos7 -- gcc -O3 -march=native -o /tmp/linpack_simple_2 -lm /tmp/linpack_simple.c
lxc exec centos7 -- /bin/bash
/usr/bin/time -o time_simple_linpack_2.o ./linpack_simple_2 > results_simple_linpack_2.o

cat time_simple_linpack_2.o
121.39user 0.79system 2:02.18elapsed 100%CPU (0avgtext+0avgdata 1712maxresident)k
0inputs+8outputs (0major+154minor)pagefaults 0swaps

[root@centos7 tmp]# ./get_flops.sh results_simple_linpack_2.o
min:5022476.190
max:6859967.480
average:5.88482e+06
```

This results are almost the same. 9.2% less powerful than bare-metal.


## After a compilation with gcc5.1

gcc5.4 is not avalaible. I will use gcc5.1.

```bash
cat << EOF > /etc/yum.repos.d/Fedora-Core23.repo                                                [warning:fedora]
name=fedora
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-23&arch=\$basearch
enabled=1
gpgcheck=0
EOF

yum update gcc g++ --enablerepo=warning:fedora
gcc --version
```

```bash
gcc -O3 -march=native -o linpack_simple_gcc5.1 -lm linpack_simple.c
gcc -O3 -march=native -o linpack_simple -lm linpack_simple.c

cat time_simple_linpack_3.o
138.84user 0.99system 2:19.84elapsed 99%CPU (0avgtext+0avgdata 1900maxresident)k
0inputs+8outputs (0major+155minor)pagefaults 0swaps
```

```bash
[root@centos7 tmp]# ./get_flops.sh results_simple_linpack_3.o
min:5759048.167
max:5772102.195
average:5.76867e+06
```

The standard deviation is lower than previously, however main results, e.g. the average is quite similar 9% lower than bare-metal.


## Results after a static compilation on the host

We will copy the binary created on the host to check if results are related to gcc (once again) or the dynamic libraries.

```bash
gcc -O3 -march=native -static -o linpack_simple_static -lm linpack_simple.c
lxc file push linpack_simple_static centos7/tmp/
#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
lxc exec centos7 -- /bin/bash
cd /tmp/
[root@centos7 tmp]# ldd ./linpack_simple_static
        not a dynamic executable
# ok, it is not dynamically linked
# 1st run
[root@centos7 tmp]# /usr/bin/time -o time_simple_linpack_static.o ./linpack_simple_static > results_simple_linpack_static.o
[root@centos7 tmp]# cat time_simple_linpack_static.o
120.42user 1.01system 2:01.48elapsed 99%CPU (0avgtext+0avgdata 880maxresident)k
1744inputs+8outputs (9major+116minor)pagefaults 0swaps
[root@centos7 tmp]# bash get_flops.sh results_simple_linpack_static.o
min:5622119.117
max:5806103.119
average:5.67841e+06

# 2nd run
[root@centos7 tmp]# bash get_flops.sh results_simple_linpack_static.o                                              min:5649006.492
max:5785394.036
average:5.70224e+06

```

So there is not any improvement, worst, we loose another 2%, that is to say 11% lower than bare-metal.

## sha1sum

```binaries
sha1sum linpack_simple*
44684923a09fabad27ca0b1f63b900f144f1038e  linpack_simple
91773372022ad32e27e5a633b348c3e4d9f36fa6  linpack_simple_2
0e9e2ac4a326889da7c3e335f956ead0e9c946cf  linpack_simple_gcc5.1
0cf0b4853ff3a3cfbb0287dffc13d62be7289f52  linpack_simple_static
```

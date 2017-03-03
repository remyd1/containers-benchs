# Benchmarks on docker with a centos7 container on an ubuntu host

Host :
  - 1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
  - kernel: `4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux`
  - release: xenial Ubuntu 16.04.2 LTS

## Local test / preparing machine

`Package docker.io 1.12.3-0ubuntu4~16.04.2`

```bash
docker --version
Docker version 1.12.3, build 6b644ec
```

A Dockerfile allows you to reproduce easily these benchmarks :

```
FROM centos:centos7
RUN yum update; yum clean all;
#RUN yum -y install epel-release; yum clean all
RUN yum -y install wget time gcc.x86_64 glibc-devel; yum clean all;
WORKDIR /usr/local/test
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
RUN gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

# run the benchs
#RUN /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o

# CMD bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
```

### Compiling with gcc4.8

```bash
docker build -t centos_simple_linpack .
docker run -ti f4f72904eac8
[root@b44203d0baa0 test]# ls
get_flops.sh  linpack_simple  linpack_simple_timeout.c
[root@b44203d0baa0 test]# uname -a
Linux b44203d0baa0 4.4.0-64-generic #85-Ubuntu SMP Mon Feb 20 11:50:30 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
[root@b44203d0baa0 test]# cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)
[root@b44203d0baa0 test]# cat /etc/issue
\S
Kernel \r on an \m

[root@b44203d0baa0 test]# gcc --version
gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-11)
...
[root@b44203d0baa0 test]# sha1sum linpack_simple
c1a5362a2f173cc8c4e48b9f20ebfe1a6659e19d  linpack_simple
[root@b44203d0baa0 test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o
min:5306767.296
max:6392242.424
average:5.71667e+06
[root@b44203d0baa0 test]# cat time_simple_linpack.o
122.74user 1.15system 2:03.90elapsed 99%CPU (0avgtext+0avgdata 1984maxresident)k
0inputs+8outputs (0major+155minor)pagefaults 0swaps


## 2nd run
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o
min:5208493.827
max:6114318.841
average:5.73066e+06
[root@b44203d0baa0 test]# cat time_simple_linpack.o
122.13user 1.24system 2:03.38elapsed 99%CPU (0avgtext+0avgdata 1956maxresident)k
0inputs+8outputs (0major+156minor)pagefaults 0swaps


## 3rd run
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o
min:5208493.827
max:6114318.841
average:5.68573e+06
[root@b44203d0baa0 test]# cat time_simple_linpack.o
122.41user 1.32system 2:03.74elapsed 99%CPU (0avgtext+0avgdata 1976maxresident)k
0inputs+8outputs (0major+156minor)pagefaults 0swaps

```

Average: 5.711 GFlops


### With gcc5.1

```bash
# after an upgrade to gcc 5.1 ([see here on how to achieve that](docker_centos7_single_core.md)) and compiling the binary with the same options

[root@afab94ea70b0 test]# gcc -O3 -march=native -o linpack_simple_gcc5.1 -lm linpack_simple_timeout.c
[root@afab94ea70b0 test]# sha1sum linpack_simple_gcc5.1
0daf0c6ad66a434e466127ee1b70fcb34d0decd3  linpack_simple_gcc5.1

# 1st run
[root@afab94ea70b0 test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple_gcc5.1 > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5461333.333
max:6696634.921
average:5.86561e+06
138.38user 1.38system 2:19.76elapsed 100%CPU (0avgtext+0avgdata 1944maxresident)k
0inputs+8outputs (0major+156minor)pagefaults 0swaps

# 2nd run
[root@afab94ea70b0 test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple_gcc5.1 > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5113793.939
max:5984226.950
average:5.71699e+06
119.36user 1.20system 2:00.59elapsed 99%CPU (0avgtext+0avgdata 1928maxresident)k
0inputs+8outputs (0major+156minor)pagefaults 0swaps

# 3rd run
[root@afab94ea70b0 test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple_gcc5.1 > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5306767.296
max:6320419.476
average:5.76555e+06
119.01user 1.30system 2:00.34elapsed 99%CPU (0avgtext+0avgdata 1744maxresident)k
0inputs+8outputs (0major+154minor)pagefaults 0swaps
[root@afab94ea70b0 test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple_gcc5.1 > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5306767.296
max:6320419.476
average:5.76555e+06
119.01user 1.30system 2:00.34elapsed 99%CPU (0avgtext+0avgdata 1744maxresident)k
0inputs+8outputs (0major+154minor)pagefaults 0swaps


## without the 'lm' option at the compilation time

# 1st run
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o
min:5357307.937
max:5984226.950
average:5.73078e+06
[root@b44203d0baa0 test]# cat time_simple_linpack.o
119.74user 1.05system 2:00.80elapsed 99%CPU (0avgtext+0avgdata 1652maxresident)k
0inputs+8outputs (0major+148minor)pagefaults 0swaps

# 2nd run
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5306767.296
max:6250192.593
average:5.73805e+06
119.60user 1.24system 2:00.85elapsed 99%CPU (0avgtext+0avgdata 1444maxresident)k
0inputs+8outputs (0major+144minor)pagefaults 0swaps

# 3rd run
[root@b44203d0baa0 test]# bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o                   
min:5022476.190
max:6250192.593
average:5.77002e+06
118.80user 1.93system 2:00.74elapsed 99%CPU (0avgtext+0avgdata 1552maxresident)k
0inputs+8outputs (0major+146minor)pagefaults 0swaps
```

With 'lm' option, the average is 5.783 GFlops, without, it is 5.746 GFlops. So the results are very close but higher than the results obtained after a gcc4.8 compilation.


### With a static compilation from the host



- On the host side:
```bash
docker run -ti f4f72904eac8
# on another term
gcc -O3 -march=native -o linpack_simple.1 -static -lm linpack_simple_timeout.c
# bellow linpack_simple.1 is the binary compiled statically, contrary
# to linpack_simple
sha1sum linpack_simple.1 linpack_simple
160ee13cb425be708938cf9321839a36a6eed38f  linpack_simple.1
7e9f602eba17fd404ced912d0d48c80e82e7978e  linpack_simple
# retrieving generated container id
docker ps
docker cp linpack_simple.1 21c14287040f:/usr/local/test/linpack_simple.static
```

- On the  container side:
```bash
# 1st run
[root@21c14287040f test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple.static > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5660603.048
max:5770604.098
average:5.70967e+06
120.12user 1.15system 2:01.28elapsed 100%CPU (0avgtext+0avgdata 916maxresident)k
0inputs+8outputs (0major+121minor)pagefaults 0swaps

# 2nd run
[root@21c14287040f test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple.static > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5663584.471
max:5812318.360
average:5.70405e+06
119.80user 1.30system 2:01.10elapsed 100%CPU (0avgtext+0avgdata 920maxresident)k
0inputs+8outputs (0major+121minor)pagefaults 0swaps

# 3rd run
[root@21c14287040f test]# /usr/bin/time -o time_simple_linpack.o ./linpack_simple.static > results_simple_linpack.o ; bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
min:5623671.813
max:5806184.772
average:5.69836e+06
119.98user 1.37system 2:01.35elapsed 100%CPU (0avgtext+0avgdata 924maxresident)k
0inputs+8outputs (0major+123minor)pagefaults 0swaps

```

Average: 5.704 GFlops. It is lower than a dynamic compilation inside the container, even if results are very close.

#### About docker and root

For information, on the host, we can check that the docker daemon and our script is running as root:

```bash
ps aufx |grep linpack
root     12318  0.0  0.0   4304   692 pts/5    S+   14:37   0:00              \_ /usr/bin/time -o time_simple_linpack.o ./linpack_simple_timeout_gcc5.1
root     12319  100  0.0   4620  1284 pts/5    R+   14:37   1:25                  \_ ./linpack_simple_timeout_gcc5.1
remy     12413  0.0  0.0  14264  1088 pts/9    S+   14:38   0:00          |       |           \_ grep --color=auto linpack
```


## Conclusion

Results are similar between LXD and docker. Performance are lower than running directly on the host (between 8 and 10%).

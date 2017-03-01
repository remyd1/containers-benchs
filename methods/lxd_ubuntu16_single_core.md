# Benchmarks with LXD on / with ubuntu




## Same image as the local distro

Package lxd 2.0.9-0ubuntu1~16.04.1

```bash
lxd --version
2.0.9
```

Firstly, the test will download the same image as the local distro and we will compile the C code inside the container.

```bash
lsb_release -a
    No LSB modules are available.
    Distributor ID: Ubuntu
    Description:    Ubuntu 16.04.2 LTS
    Release:        16.04
    Codename:       xenial

lxc image list images: |grep -i xenial
lxc launch images:ubuntu/xenial/amd64 ubuntu64
lxc file push linpack_simple ubuntu64/tmp/
#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
lxc exec ubuntu64 -- apt-get install -y time libc6-dev libgcc-5-dev
lxc exec ubuntu64 -- /bin/bash

uname -a
    Linux ubuntu64 4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

# same release and same kernel
lsb_release -a
    No LSB modules are available.
    Distributor ID: Ubuntu
    Description:    Ubuntu 16.04.2 LTS
    Release:        16.04
    Codename:       xenial

/usr/bin/time -o /tmp/time_simple_linpack.o /tmp/linpack_simple > /tmp/results_simple_linpack.o
```

By the way, we can see that the process is running with a very high UID (this is normal. LXD is doing this to avoid duplicates UID with the local system). The process is saw as a standard process from the host point of view, son of lxd (a root daemon).

```
    root      3047  0.0  0.0  64932 11460 ?        Sl   15:25   0:00  \_ /usr/bin/lxd forkexec ubuntu64 /var/lib/lxd/containers /var/log/lxd/ubuntu64/lxc.conf -- env HOME=/root TERM=xterm USER=root PATH=/usr/local/sbin:/usr/local/bin:/usr
    296608    3052  0.0  0.0  18248  3288 pts/5    Ss   15:25   0:00      \_ /bin/bash
    296608    8062  0.0  0.0   4364   656 pts/5    S+   16:56   0:00          \_ /usr/bin/time -o time_simple_linpack_2.o ./linpack_simple_2
    296608    8063 82.6  0.0   4684   648 pts/5    R+   16:56   0:02              \_ ./linpack_simple_2
```



## Results without compiling



```bash

# 1er run
root@ubuntu64:~# bash /tmp/get_flops.sh /tmp/results_simple_linpack.o                                              
min:5798833.912
max:6491690.700
average:6.31564e+06

# 2eme run
root@ubuntu64:~# bash /tmp/get_flops.sh /tmp/results_simple_linpack_2.o
min:5798514.114
max:6515352.980
average:6.33455e+06



root@ubuntu64:~# cat /tmp/time_simple_linpack.o
Command exited with non-zero status 30
147.71user 0.96system 2:28.69elapsed 99%CPU (0avgtext+0avgdata 1696maxresident)k
40inputs+8outputs (0major+145minor)pagefaults 0swaps
```

Les benchmarks indiquent entre 5.79 et 6.49 GFlops, avec une average de 6.31 GFlops soit quasiment pareil qu'en bare-metal (1% de perte en average).


## With compiling

```bash
lxc file push linpack_simple.c ubuntu64/tmp/
#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

lxc exec ubuntu64 -- apt-get install -y gcc

# checking gcc versions
gcc --version
gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
...
lxc exec ubuntu64 -- gcc --version
gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
...

# compilation
lxc exec ubuntu64 -- gcc -O3 -march=native -o /tmp/linpack_simple_2 -lm /tmp/linpack_simple.c
lxc exec ubuntu64 -- /bin/bash

# executing...
/usr/bin/time -o /tmp/time_simple_linpack_2.o /tmp/linpack_simple_2 > /tmp/results_simple_linpack_2.o


cat time_simple_linpack_2.o
Command exited with non-zero status 1
148.37user 1.00system 2:29.37elapsed 100%CPU (0avgtext+0avgdata 1652maxresident)k
0inputs+8outputs (0major+144minor)pagefaults 0swaps

# 1st run
root@ubuntu64:~# bash /tmp/get_flops.sh /tmp/results_simple_linpack_2.o
min:5745083.275
max:6497471.936
average:6.32382e+06

# 2nd run
root@ubuntu64:~# bash /tmp/get_flops.sh /tmp/results_simple_linpack_2.o                                            min:5827407.690
max:6533901.872
average:6.35536e+06
```

Benchmarks indicate between 5.74 and 6.53 GFlops that is to say values which quite similar that bare-metal; The average is also similar than previous runs. With LXD on an ubuntu host and an ubuntu container we have about 1% of perf loss.


## sha1sum

```bash
sha1sum linpack_simple*
44684923a09fabad27ca0b1f63b900f144f1038e  linpack_simple
44684923a09fabad27ca0b1f63b900f144f1038e  linpack_simple_2
```

As you can see, I get the same sha1sum as the binary generated on the host.

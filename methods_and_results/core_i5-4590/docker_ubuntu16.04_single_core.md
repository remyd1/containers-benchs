# Benchmarks with Ubuntu 16.04 container on an ubuntu host

Host :
  - 1 core CPU Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
  - kernel: `4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux`
  - release: xenial Ubuntu 16.04.2 LTS


## Test with docker on the same distro image

Package docker.io 1.12.3-0ubuntu4~16.04.2

```bash
docker --version
Docker version 1.12.3, build 6b644ec
```

A Dockerfile allows you to reproduce these benchmarks easily:

```
FROM ubuntu:16.04
RUN apt-get update && apt-get install -y gcc wget time libc6-dev libgcc-5-dev
WORKDIR /usr/local/test
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
RUN gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

# run the benchs
#RUN /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o

#CMD bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o
```

```bash
docker build -t linpack_simple .
docker run -ti linpack_simple
root@831f4257e6c2:/usr/local/test# cd /usr/local/test/
root@831f4257e6c2:/usr/local/test# ls
get_flops.sh  linpack_simple  linpack_simple_timeout.c
root@831f4257e6c2:/usr/local/test# uname -a
Linux 831f4257e6c2 4.4.0-64-generic #85-Ubuntu SMP Mon Feb 20 11:50:30 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
root@831f4257e6c2:/usr/local/test# cat /etc/debian_version
stretch/sid
root@831f4257e6c2:/usr/local/test# cat /etc/issue          
Ubuntu 16.04.1 LTS \n \l
root@831f4257e6c2:/usr/local/test# gcc --version
gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609
...
root@831f4257e6c2:/usr/local/test# sha1sum linpack_simple
7e9f602eba17fd404ced912d0d48c80e82e7978e  linpack_simple

# 1st run
root@831f4257e6c2:/usr/local/test# /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o
root@831f4257e6c2:/usr/local/test# bash get_flops.sh results_simple_linpack.o
min:5749559.299
max:6474053.680
average:6.28643e+06
root@831f4257e6c2:/usr/local/test# cat time_simple_linpack.o
Command exited with non-zero status 254
129.25user 1.50system 2:10.77elapsed 99%CPU (0avgtext+0avgdata 1692maxresident)k
40inputs+8outputs (0major+145minor)pagefaults 0swaps

## 2nd run
root@831f4257e6c2:/usr/local/test# bash get_flops.sh results_simple_linpack.o
min:5805695.633
max:6511860.868
average:6.31038e+06
root@831f4257e6c2:/usr/local/test# cat time_simple_linpack.o
Command exited with non-zero status 205
148.04user 1.76system 2:29.81elapsed 99%CPU (0avgtext+0avgdata 1624maxresident)k
0inputs+8outputs (0major+143minor)pagefaults 0swaps

## 3rd run
root@831f4257e6c2:/usr/local/test# bash get_flops.sh results_simple_linpack.o
min:5779313.401
max:6481256.591
average:6.29467e+06
root@831f4257e6c2:/usr/local/test# cat time_simple_linpack.o                                                        
Command exited with non-zero status 208
128.96user 1.86system 2:10.83elapsed 99%CPU (0avgtext+0avgdata 1628maxresident)k
0inputs+8outputs (0major+142minor)pagefaults 0swaps
```

The average on these 3 runs is 6.297 GFlops

```bash
wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
--2017-02-24 11:57:20--  https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
Résolution de gist.githubusercontent.com (gist.githubusercontent.com)… 151.101.120.133
Connexion à gist.githubusercontent.com (gist.githubusercontent.com)|151.101.120.133|:443… connecté.
requête HTTP transmise, en attente de la réponse… 200 OK
Taille : 22402 (22K) [text/plain]
Enregistre: «linpack_simple_timeout.c»

linpack_simple_timeout.c     100%[==============================================>]  21,88K  --.-KB/s    in 0s      

2017-02-24 11:57:26 (45,2 MB/s) - «linpack_simple_timeout.c» enregistré [22402/22402]

gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c
sha1sum linpack_simple
7e9f602eba17fd404ced912d0d48c80e82e7978e  linpack_simple
```

Ok, the sha1sum is the same. The file has been modified...

```bash
# 1st run
bash get_flops.sh results_simple_linpack.o
min:5786405.743
max:6494756.247
average:6.30606e+06
cat time_simple_linpack.o
Command exited with non-zero status 227
148.82user 0.82system 2:29.65elapsed 99%CPU (0avgtext+0avgdata 1688maxresident)k
0inputs+0outputs (0major+147minor)pagefaults 0swaps

# 2nd run
/usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o
bash get_flops.sh results_simple_linpack.o                         
min:5727457.126
max:6505753.029
average:6.3299e+06
cat time_simple_linpack.o
Command exited with non-zero status 187
128.83user 0.74system 2:09.57elapsed 99%CPU (0avgtext+0avgdata 1528maxresident)k
0inputs+0outputs (0major+143minor)pagefaults 0swaps

# 3rd run
bash get_flops.sh results_simple_linpack.o
min:5770268.909
max:6495401.205
average:6.30512e+06
cat time_simple_linpack.o
Command exited with non-zero status 136
148.76user 0.88system 2:29.66elapsed 99%CPU (0avgtext+0avgdata 1596maxresident)k
0inputs+0outputs (0major+145minor)pagefaults 0swaps
```

The average on these 3 runs is 6.313 GFlops

There are almost no performance loss (between 0 and 2%) 

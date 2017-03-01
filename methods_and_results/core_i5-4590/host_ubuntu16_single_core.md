# benchmarks with linpack on a single core

## Local tests

My CPU is the following: Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz

```bash
uname -a
Linux atlas 4.4.0-62-generic #83-Ubuntu SMP Wed Jan 18 14:10:15 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 16.04.2 LTS
Release:        16.04
Codename:       xenial
```

Using "linpackc.new" a lightweight release of the famous HPL linpack which does not require anything special :
http://www.netlib.org/benchmark/linpackc.new

I am setting the array size to 200*200 (default).

glibc libc6-dev 2.23 (contains math.h, stdio.h, stdlib.h)
float.h is distributed with libgcc-4.8-dev, libgcc-5-dev and libstdc++-5-dev

Single core computing

## Downloading, building and a bit of methods

Changing elapsed time does not change the results (tests = 1mn, 2mn, 4mn, 8mn).

Array 200*200 (40000)

```bash
wget http://www.netlib.org/benchmark/linpackc.new
cp linpackc.new linpack_simple.c
vim linpack_simple.c
# Modifying arsize to 200 without asking the user
# Modifying while 1 to 2mn wall time

 diff -Ebw linpackc.new linpack_simple.c
75c75,81
<     while (1)
---
>     time_t start, end;
>     double elapsed;  // seconds
>     start = time(NULL);
>     int terminate = 1;
>
>     //while (1)
>     while (terminate)
77c83,90
<         printf("Enter array size (q to quit) [200]:  ");
---
>         end = time(NULL);
>         elapsed = difftime(end, start);
>         if (elapsed >= 120.0 /* seconds */)
>             {
>             terminate = 0;
>             }
>         else
>             /*printf("Enter array size (q to quit) [200]:  ");
84c97,99
<             arsize=atoi(buf);
---
>                 arsize=atoi(buf);*/
>             {
>             arsize=200;
111a127
>             }


gcc -O3 -march=native -o linpack_simple -lm linpack_simple.c

#sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
/usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o
```

Modified version of this file could be retrieved here: https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c


## Results

Little piece of script to extract results :

```
cat get_flops.sh
#!/bin/bash

min=`awk '$1 ~ "[0-9]+" {print $6}' $1 |sort -k6 |head -1`
max=`awk '$1 ~ "[0-9]+" {print $6}' $1 |sort -k6 |tail -1`

echo "min:"$min
echo "max:"$max
echo -n "average:"
awk '$1 ~ "[0-9]+" {total=total+$6;n=n+1;} END{print total/n;}' $1
```

I get between 5.815 and 6.541 GFlops with 6.38 GFlops as average on the CPU described in the beginning.


### 1st run

```bash
cat time_simple_linpack.o
Command exited with non-zero status 105
147.93user 0.55system 2:28.48elapsed 99%CPU (0avgtext+0avgdata 1692maxresident)k
40inputs+0outputs (0major+149minor)pagefaults 0swaps

bash get_flops.sh results_simple_linpack.o                        
min:5823172.857
max:6532885.046
average:6.35465e+06
```

### 2nd run

```bash
bash get_flops.sh results_simple_linpack_2.o                      
min:5815382.876
max:6540960.071
average:6.35823e+06

cat time_simple_linpack_2.o
Command exited with non-zero status 136
147.88user 0.57system 2:28.45elapsed 100%CPU (0avgtext+0avgdata 1600maxresident)k
40inputs+0outputs (0major+146minor)pagefaults 0swaps
```

### For 4 and 8 minutes :

```
bash get_flops.sh results_simple_linpack_240s.o
min:5822512.097
max:6535192.330
average:6.41443e+06

bash get_flops.sh results_simple_linpack_480s.o
min:5804074.124
max:6544120.873
average:6.4696e+06
```


## sha1sum

```bash
# binaries on the host
sha1sum ./linpack_simple*
44684923a09fabad27ca0b1f63b900f144f1038e  linpack_simple
2a4aa88a660ee56315c4fe63cdd0f6f554724e48  linpack_simple_240s
3c593a4754e00a18c164500999c108aa39abcffc  linpack_simple_480s
0cf0b4853ff3a3cfbb0287dffc13d62be7289f52  linpack_simple_static
```

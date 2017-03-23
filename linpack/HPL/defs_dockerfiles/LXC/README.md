# HPL-Benchmark for LXC
LXC image for HPL-Benchmark
This LXC file assumes you have a working [LXC](https://linuxcontainers.org/) on your host

# Create image
```
lxc-create -t download -n my-container
```
The download template will show you a list of distributions, versions and architectures to choose from.

This bash script was tested on "ubuntu", "xenial" (16.04 LTS)

```
lxc-start -n my-container
```

```
lxc-attach -n my-container
```
Once inside the container clone the repo with

```
wget 'https://raw.githubusercontent.com/remyd1/containers-benchs/master/linpack/HPL/defs_dockerfiles/singularity/hpl_install.sh' -O hpl_make.sh
```

```
chmod +x hpl_make.sh
```
```
./hpl_make.sh
```
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

# Run
```
mpirun -np ##  ./xhpl
```

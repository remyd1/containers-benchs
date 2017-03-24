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

There are two scripts here; One is optimized with the OpenMPI sources. The 'simple' version will use the openMPI packages from ubuntu.

Sha1sums for the simple version :
```bash
sha1sum xhpl
d654a8727970203d1d66aafa8e3335fccd4474a1  xhpl
```
Sha1sums for the optimized version :
```bash
sha1sum xhpl
56399930b86b5a6de4649480508df0a3e08737d5  xhpl
```


```
chmod +x hpl_install.sh
```
```
./hpl_install.sh
```
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

# Run
```
mpirun -np ##  ./xhpl
```

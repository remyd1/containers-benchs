# HPL-Benchmark for Singularity
Singularity image for HPL-Benchmark
This .def file assumes you have a working OpenMPI on your host

# Create image
```
sudo singularity create -s 2048 /tmp/hplbenchmark.img
```
#Bootstrap

There are two bootstrap files here; One is optimized with the OpenMPI sources. The 'simple' version will use the openMPI packages from ubuntu.

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
sudo singularity bootstrap /tmp/hplbenchmark.img xenial_docker_hpllinpack.def
```
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

# Run
```
mpirun -np ## singularity exec ./xhpl
```

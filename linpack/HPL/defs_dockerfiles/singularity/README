# HPL-Benchmark for Singularity
Singularity image for HPL-Benchmark
This .def file assumes you have a working OpenMPI on your host

# Create image
```
sudo singularity create -s 2048 /tmp/hplbenchmark.img
```
#Bootstrap

```
sudo singularity bootstrap /tmp/hplbenchmark.img xenial_docker_hpllinpack.def
```
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

# Run
```
mpirun -np ## singularity exec ./xhpl 
```

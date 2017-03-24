# HPL-Benchmark for Docker
Docker image for HPL-Benchmark

There are 3 Dockerfiles :
  - Dockerfile : built on a top of a Docker/OpenMPI image
  - Dockerfile_optimized should is also built from a Docker/openMPI image with an install of OpenMPI from sources
  - Dockerfile_simple : used to build a Docker from a Ubuntu basic image

# Create image
```
docker build -t hpldocker .
```
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

# Run
```
docker run -it hpldocker /bin/bash
```
```
mpirun -np ## ./xhpl
```

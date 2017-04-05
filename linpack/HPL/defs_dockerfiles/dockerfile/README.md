# HPL-Benchmark for Docker
Docker image for HPL-Benchmark

There are 3 Dockerfiles :
  - Dockerfile : built on a top of a Docker/OpenMPI image
  ```bash
  sha1sum xhpl
  56399930b86b5a6de4649480508df0a3e08737d5  xhpl
  ```
  - Dockerfile_optimized should is also built from a Docker/openMPI image with an install of OpenMPI from sources
  ```bash
  sha1sum xhpl
  56399930b86b5a6de4649480508df0a3e08737d5  xhpl
  ```  
  - Dockerfile_simple : used to build a Docker from a Ubuntu basic image
  ```bash
  sha1sum xhpl
  d654a8727970203d1d66aafa8e3335fccd4474a1  xhpl
  ```

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

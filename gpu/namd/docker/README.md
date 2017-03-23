## nvidia-docker


Install nvidia-docker :
    https://github.com/NVIDIA/nvidia-docker/wiki/Installation
    with docker-ce insteaf of docker.io ( https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository )




## test

nvidia-docker run --rm nvidia/cuda nvidia-smi

## Launching and running some tests with NAMD
nvidia-docker run -ti -v /usr/local/NAMD_CVS-2017-03-16_Linux-x86_64-multicore-CUDA/test:/tmp/test nvidia/cuda bash


# inside the docker container

[See install and run namd bash script](install_run_namd.sh)

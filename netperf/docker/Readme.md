# Docker osu benchmar
Dockerfile image for osu benchmarks

# build
```
docker build -t osu_bench .
```

# Run

> Step 1
```
$ docker swarm init
```
> Step 2
```
$ docker network create --driver overlay --subnet 172.17.9.0/24 uchuva-net
```
> Step 3
```
$ docker service create --replicas 2 \
--name osu_bench \
--network uchuva-net \
--publish 5000:22 ashael/openmpi:V2
```
> Step 4
```
docker exec -it image_name sudo -u mpirun mpirun -np 2 --machinefile machinefile osu_bw
```

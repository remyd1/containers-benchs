# Docker osu benchmar
Dockerfile image for osu benchmarks

# build
```docker build -t osu_bench .
```

# Run

1.
```
$ docker swarm init
```
```
$ docker network create --driver overlay --subnet 172.17.9.0/24 uchuva-net
```
```
$ docker service create --replicas 2 \
--name test \
--network uchuva-net \
--publish 5000:22 ashael/openmpi:V2
```
docker exec -it image_name sudo -u mpirun mpirun -np 2 --machinefile machinefile osu_bw
```

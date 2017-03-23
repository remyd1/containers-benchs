FROM ubuntu:16.04
MAINTAINER Eduardo Arango <carlos.arango.gutierrez@correounivalle.edu.co>

RUN apt-get update
RUN apt-get install -y bash wget build-essential gcc time hdparm 
WORKDIR /tmp/
RUN wget 'http://www.iozone.org/src/current/iozone3_465.tar' 
RUN tar -xf iozone3_465.tar
WORKDIR /tmp/iozone3_465/src/current/
RUN make linux-AMD64

CMD bash


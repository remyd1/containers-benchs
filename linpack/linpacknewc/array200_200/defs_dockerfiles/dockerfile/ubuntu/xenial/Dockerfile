FROM ubuntu:16.04
RUN apt-get update && apt-get install -y gcc wget time libc6-dev libgcc-5-dev
WORKDIR /usr/local/test
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
RUN gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

# run the benchs
RUN /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o

CMD bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o

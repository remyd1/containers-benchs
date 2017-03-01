FROM centos:centos7
RUN yum update; yum clean all;
#RUN yum -y install epel-release; yum clean all
RUN yum -y install wget time gcc.x86_64 glibc-devel; yum clean all;
WORKDIR /usr/local/test
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/linpack_simple_timeout.c
RUN wget https://gist.githubusercontent.com/remyd1/7711c3e6e5a12e674f6b6d773fe37472/raw/1b30a5bf88ec6098bc6a534ac7e4361abe4d3efe/get_flops.sh
RUN gcc -O3 -march=native -o linpack_simple -lm linpack_simple_timeout.c

# run the benchs
#RUN /usr/bin/time -o time_simple_linpack.o ./linpack_simple > results_simple_linpack.o

#CMD bash get_flops.sh results_simple_linpack.o && cat time_simple_linpack.o

Here you fill find :

[Dockerfiles](defs_dockerfiles/dockerfile/README.md)

[bootstrap singularity.def files](defs_dockerfiles/singularity/README.md)

[Bash script for LXC and Bare-metal](defs_dockerfiles/LXC/README.md)


With a setup to run the HPL on Docker and Singularity, For Benchmark purposes only.

==================================================================================
HPL is a software package that solves a (random) dense linear system in double precision (64 bits) arithmetic on distributed-memory computers. It can thus be regarded as a portable as well as freely available implementation of the High Performance Computing Linpack Benchmark.

The algorithm used by HPL can be summarized by the following keywords: Two-dimensional block-cyclic data distribution - Right-looking variant of the LU factorization with row partial pivoting featuring multiple look-ahead depths - Recursive panel factorization with pivot search and column broadcast combined - Various virtual panel broadcast topologies - bandwidth reducing swap-broadcast algorithm - backward substitution with look-ahead of depth 1.

The HPL package provides a testing and timing program to quantify the accuracy of the obtained solution as well as the time it took to compute it. The best performance achievable by this software on your system depends on a large variety of factors. Nonetheless, with some restrictive assumptions on the interconnection network, the algorithm described here and its attached implementation are scalable in the sense that their parallel efficiency is maintained constant with respect to the per processor memory usage.

The HPL software package requires the availibility on your system of an implementation of the Message Passing Interface MPI (1.1 compliant). An implementation of either the Basic Linear Algebra Subprograms BLAS or the Vector Signal Image Processing Library VSIPL is also needed. Machine-specific as well as generic implementations of MPI, the BLAS and VSIPL are available for a large variety of systems.

Acknowledgements: This work was supported in part by a grant from the Department of Energy's Lawrence Livermore National Laboratory and Los Alamos National Laboratory as part of the ASCI Projects contract numbers B503962 and 12187-001-00 4R.

======================================================================
#Setup and configure the HPL.dat
[HPL.dat tuning](http://www.netlib.org/benchmark/hpl/tuning.html)

======================================================================
 -- High Performance Computing Linpack Benchmark (HPL)                
    HPL - 2.1 - October 26, 2012                        
    Antoine P. Petitet                                                
    University of Tennessee, Knoxville                                
    Innovative Computing Laboratory                                 
    (C) Copyright 2000-2008 All Rights Reserved      
Blocking size (NB) recommendation
---------------------------------


Recommended blocking sizes (NB in HPL.dat) are listed below for various Intel(R)
architectures:

Intel(R) Xeon(R) Processor X56*/E56*/E7-*/E7*/X7*                             : 256

Intel(R) Xeon(R) Processor E26*/E26* v2                                       : 256

Intel(R) Xeon(R) Processor E26* v3/E26* v4                                    : 192

Intel(R) Core(TM) i3/5/7-6* Processor                                         : 192

Intel(R) Xeon Phi(TM) Processor 72*                                           : 336

Intel(R) Xeon(R) Processor supporting Intel(R) Advanced Vector Extensions 512
         (Intel(R) AVX-512) (codename Skylake Server)                         : 384

# containers-benchs

This repository contains some scripts, methods and results to compare benchmarks between containers type.

To put your own results, fork this repository and ask for pull request.

Then:
  - Please create a subdirectory in method\_and\_results with your CPU or GPU type and create a detailed markdown file by type of container and distro to be able to rerun your benchs.
    - If you made heterogeneous tests with MPI, create a subdirectory in method\_and\_results with your mpi version and with every details (operations/commands, latency, bandwith, CPU types on nodes...) of your runs.
  - Rename the new markdown file(s) with \<container\_type\>\_\<distro\>\_\<type\_of\_test\>.md
  with \<type\_of\_test\> = [single\_core or mpi or openmp or cuda]
  e.g. singularity\_centos6\_mpi.md
  - In the markdown file, you have to inform every details to be able to rerun your benchs

About:
  - For every runs, please create a markdown file with bare-metal results and name it  host\_\<distro\>\_\<type\_of\_test\>.
  - For single core tests, please use [this file](linpack/array200_200/linpack_1_core_timeout.c). It is [linpacknew.c](http://www.netlib.org/benchmark/linpackc.new) with a timeout at 2mn in a non-interactive mode.
    - If you want another array size, please create a subdirectory in linpack and put the modified file you used.
  - For docker and singularity, please create a Dockerfile or a singularity definition file for bootstrap (if you do not use those supplied). For lxd, inform us with the commands you used by filling the markdown file you created before.

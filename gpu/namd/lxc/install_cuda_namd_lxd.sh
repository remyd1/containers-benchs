# install cuda LXD


lxc launch images:ubuntu/xenial/amd64 ubuntu64
lxc config device add ubuntu64 nvidia0 unix-char path=/dev/nvidia0
lxc config device add ubuntu64 nvidiactl unix-char path=/dev/nvidiactl
lxc config device add ubuntu64 nvidia-uvm unix-char path=/dev/nvidia-uvm
lxc config device add ubuntu64 nvidia-uvm-tools unix-char path=/dev/nvidia-uvm-tools

lxc config set ubuntu64 security.privileged true

lxc file push apoa1.tar.gz ubuntu64/usr/local/
lxc file push f1atpase.tar ubuntu64/usr/local/
lxc file push stmv.tar ubuntu64/usr/local/
lxc file push NAMD_CVS-2017-03-16_Linux-x86_64-multicore-CUDA.tar.gz ubuntu64/usr/local/
lxc file push NVIDIA-Linux-x86_64-375.26.run ubuntu64/usr/local/

lxc exec ubuntu64 -- /bin/bash
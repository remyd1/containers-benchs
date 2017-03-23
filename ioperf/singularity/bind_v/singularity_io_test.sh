#!/bin/bash
echo "Iozone: Performance Test of File I/O" > singularity_io.out
echo "Version $Revision: 3.465 $" >> singularity_io.out
echo "Compiled for 64 bit mode." >> singularity_io.out
echo "Build: linux-AMD64" >> singularity_io.out
echo "	" >> singularity_io.out
echo "                                                              random    random     bkwd    record    stride                                    
              kB  reclen    write  rewrite    read    reread    read     write     read   rewrite      read   fwrite frewrite    fread  freread" >> singularity_io.out
for i in {1..10}
do
	singularity exec ../iozone.img iozone –Ra –g 2G > tmp.out && sed -n '26,27 p' tmp.out >> singularity_io.out
done


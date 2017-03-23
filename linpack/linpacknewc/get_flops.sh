#!/bin/bash

min=`awk '$1 ~ "[0-9]+" {print $6}' $1 |sort -k6 |head -1`
max=`awk '$1 ~ "[0-9]+" {print $6}' $1 |sort -k6 |tail -1`

echo "min:"$min
echo "max:"$max
echo -n "moyenne:"
awk '$1 ~ "[0-9]+" {total=total+$6;n=n+1;} END{print total/n;}' $1
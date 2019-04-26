#!/bin/bash

sfxcss=$1
size=106G

#primary disk
for i in $(seq 1 3);
do
echo "n
p
$i

+$size
w
" | fdisk $sfxcss
done

#extend disk
echo "n
e
4


w
" | fdisk $sfxcss

#logical disk

for i in $(seq 5 16);
do
echo "n
l
$i

+$size
w
" | fdisk $sfxcss
done


#!/bin/bash

sfxcss=/dev/sfd0n1
#sfxcss=/dev/sfd1n1
#sfxcss=/dev/sfd2n1

for i in $(seq 1 16);
do
echo "d


w
" | fdisk $sfxcss
done


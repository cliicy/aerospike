lsblk 
service aerospike stop
rm -rf /opt/aerospike/data/*.dat
umount /dev/sfd0n1
mkfs.ext4  /dev/sfd0n1

rm -rf /opt/aerospike/xfsdata/*.dat
umount /dev/sfd1n1
mkfs -t xfs /dev/sfd1n1

umount /dev/sfd2n1
nvme format /dev/sfd2n1


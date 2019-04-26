service aerospike stop

rm -rf /opt/aerospike/data/*.dat

umount /dev/sfd0n1

mkfs.ext4 /dev/sfd0n1

mount /dev/sfd0n1 /opt/aerospike/data

service aerospike restart


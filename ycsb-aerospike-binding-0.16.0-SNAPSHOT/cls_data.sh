# $1 sfd0n1
service aerospike stop
rm -rf /opt/aerospike/data/*.dat
umount /dev/$1
mkfs.ext4 /dev/$1
mount /dev/$1 /opt/aerospike/data/
mkdir /opt/aerospike/data/log
service aerospike start
service aerospike status

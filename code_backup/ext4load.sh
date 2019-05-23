service aerospike stop
service aerospike status
rm -rf /opt/aerospike/data/*.dat
umount /dev/sfd2n1
mkfs.ext4 /dev/sfd2n1
mount /dev/sfd2n1 /opt/aerospike/log
service aerospike restart
asinfo -v service
service aerospike status
#bin/ycsb load aerospike -P workloads/workloada_load -p as.host=192.168.10.202 -p as.port=3000 -p as.namespace=css_sfx -threads 100 -p recordcount=270000000 -s

#bin/ycsb load aerospike -P workloads/workloada_load -p as.host=192.168.10.202 -p as.port=3000 -p as.namespace=css_sfx -threads 100 -p recordcount=70000000 -s

#./bin/ycsb load aerospike -s -P workloads/workloada_load -p as.timeout=5000 -threads 100

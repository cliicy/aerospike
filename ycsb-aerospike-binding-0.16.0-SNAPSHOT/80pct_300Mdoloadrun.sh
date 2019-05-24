logpath=output/aerospike/YCSB_$1_$2
#as_ip=192.168.3.87
#as_gxip=10.0.2.87
as_ip=192.168.10.202
as_gxip=10.0.0.12
mkdir -p $logpath
port=3000
rcount=300000000
threads=100
bin/ycsb load aerospike -P workloads/workloada_ext4load -p as.host=$as_gxip -p as.port=$port -p as.namespace=css_sfx -threads $threads -p maxexecutiontime=5400 -p recordcount=$rcount -s >> $logpath/load.has_journal.ext4.result 2>&1
echo>ycsb.loading
scp ycsb.loading root@$as_ip:/tmp/ycsb_gx/
bin/ycsb run aerospike -P workloads/workloada_run -p as.host=$as_gxip -p as.port=$port -p as.namespace=css_sfx -threads $threads -p maxexecutiontime=5400 -p recordcount=$rcount -s >> $logpath/run.has_journal.ext4.result 2>&1
echo>ycsb.running
scp ycsb.running root@$as_ip:/tmp/ycsb_gx/

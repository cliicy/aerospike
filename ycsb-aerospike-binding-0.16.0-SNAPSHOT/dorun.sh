logpath=output/aerospike/YCSB_$1_$2
mkdir -p $logpath
bin/ycsb run aerospike -P workloads/workloada_ext4load -p as.host=10.0.0.12 -p as.port=3000 -p as.namespace=css_sfx -threads 256 -p maxexecutiontime=7200 -p recordcount=340871086 -s >> $logpath/load.has_journal.ext4.result 2>&1
echo>ycsb.loading
scp ycsb.loading root@192.168.10.202:/tmp/ycsb_gx/
bin/ycsb run aerospike -P workloads/workloada_run -p as.host=10.0.0.12 -p as.port=3000 -p as.namespace=css_sfx -threads 256 -p maxexecutiontime=7200 -p recordcount=340871086 -s >> $logpath/run.has_journal.ext4.result 2>&1
echo>ycsb.running
scp ycsb.running root@192.168.10.202:/tmp/ycsb_gx/

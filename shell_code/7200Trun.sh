sudo ./bin/ycsb run aerospike -s -P workloads/workloada 

sudo bin/ycsb run aerospike -P workloads/workloada_run -p as.host=192.168.10.202 -p as.port=3000 -p as.namespace=css_sfx -threads 100 -p maxexecutiontime=7200 -p recordcount=200000000 -s

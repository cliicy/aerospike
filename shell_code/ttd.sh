#!/bin/bash

for i in $(seq 1 100)
do
echo "bin/ycsb load aerospike -P workloads/workloada -p as.host=localhost -p as.namespace=$2 -threads $i -p recordcount=50000000 -s >./outputload/$i"_load".txt";
done


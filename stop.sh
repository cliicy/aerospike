#!/bin/bash

function stop_aerospike_instances() {
    sudo service aerospike stop
    sleep_sec=3
    for i in {0..100};
    do
        if [ "" ==  "`ps aux | grep asd | grep -v grep`" ];
        then echo "stopped"; break;
        else echo "stopping aerospike - waited $((${i}*${sleep_sec})) second(s)"; sleep ${sleep_sec};
        fi
    done
}

stop_aerospike_instances

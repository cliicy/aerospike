cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\tt_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

sudo service aerospike stop
rm -rf ${as_datadir}/bar.dat
sudo service aerospike start

if [ "${output_dir}" == "" ];
then
        export output_dir=${result_dir}/ycsb_as-`date +%Y%m%d_%H%M%S`${case_id}
fi

echo "test output will be saved in ${output_dir}"

if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi

bin/ycsb load aerospike -P workloads/workloada -t -p as.host=192.168.10.202 -p as.port=3021 -p as.namespace=tycsb -threads 15 -p recordcount=50000 -s -p measurementtype=$2  >> ${output_dir}/$2_load.ret 2>&1
du -h ${as_datadir}/bar.dat >> ${output_dir}/$2_load.ret
./bin/ycsb run aerospike -s -P workloads/workloada -p as.namespace=tycsb -p as.host=192.168.10.202 -p as.port=3021 -p recordcount=50000 -p operationcount=50000 -p threadcount=15 -p measurementtype=$2  >> ${output_dir}/$2_run.ret 2>&1
du -h ${as_datadir}/bar.dat >> ${output_dir}/$2_run.ret

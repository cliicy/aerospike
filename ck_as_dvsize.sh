cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\tt_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

function ck_cs_data_size() {
    while true
    do
        du -h ${as_datadir}/bar.dat
        sleep 30
    done
}

ck_cs_data_size 

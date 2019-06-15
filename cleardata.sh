cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\tt_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

sudo service aerospike stop
sudo rm -rf ${as_datadir}/bar.dat
sudo service aerospike start

if [ "${as_logdir}" != "" ];    then sudo mkdir -p ${as_logdir};    sudo chown -R `whoami`:`whoami` ${as_logdir};    fi


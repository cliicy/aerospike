conf_dir=/etc/aerospike
default_conf=aerospike.conf
prefix=`date +%d%m%y`
root_dir=`pwd`
action=load
ret=y


while getopts :a:b:l:n:m:d:h:c:w:t:r: vname 
do
    case "$vname" in
       a) #echo "$OPTARG: load | run"
          action=$OPTARG
          ;;
       w) #echo "$OPTARG: using the workloads/workloada totally? y|n"
          ret=$OPTARG 
          ;;
       t) #echo "threads=$OPTARG"
          thread=$OPTARG
          ;;
       r)
          recount=$OPTARG
          ;;
       l) #echo $OPTARG 
          if [ "$OPTARG" = "show" ];then
              echo "showing the logs information used by aerospike server" &&  asinfo -v 'logs'
          elif [ "$OPTARG" = "edit" ];then
              echo "only enable the critical logs information"
              asinfo -v 'log-set:id=1;server=critical'
              service aerospike restart
              service aerospike status
          elif [ "$OPTARG" = "add" ];then
              echo "will add the debug_logs information"
              #asinfo -v --config-file /etc/aerospike/aerospike.conf
              service aerospike restart
              service aerospike status
          fi
          ;;
       c)
          device=$OPTARG
          if [ "$OPTARG" = "device" ];then
             echo cp -P $conf_dir/sfx_aerospike/bld_$default_conf $conf_dir/$default_conf
             cp -P $conf_dir/sfx_aerospike/bld_$default_conf $conf_dir/$default_conf
          elif [ "$OPTARG" = "file" ];then
             echo cp -P $conf_dir/sfx_aerospike/file_$default_conf $conf_dir/$default_conf
             cp -P $conf_dir/sfx_aerospike/file_$default_conf $conf_dir/$default_conf
          fi
          ;;

       n)
          echo "namespace: $OPTARG" && asinfo -v "namespaces"
          namespace=$OPTARG
          if [ "$namespace" = "" ];then
              echo 'Please input the correct namespace: '
              read namespace
              if [ $namespace ="" ];then
                  echo "Error namespace" && exit 1
              fi
          fi
          ;;
       b)
          echo "block device: $OPTARG" 
          bldevice=$OPTARG
          ;;
       m) namespace=$OPTARG
          if [ "$namespace" = "" ];then
              echo 'Please input the correct namespace: '
              read namespace
              if [ $namespace ="" ];then
                  echo "Error namespace" && exit 1
              fi
          fi
          echo "Before Edit parameters for namespace: $namespace"
          asinfo -v "get-config:context=namespace;id=$namespace" -l
          echo "Please input the value of memory-size: "
          read memory
          asinfo -v "set-config:context=namespace;id=$namespace;memory-size=$memory" 
          echo "After Edit parameters for namespace: $namespace"
          asinfo -v "get-config:context=namespace;id=$namespace" -l
          ;;
       d) namespace=$OPTARG
          if [ "$namespace" = "" ];then
              echo 'Please input the correct namespace: '
              read namespace
              if [ $namespace ="" ];then
                  echo "Error namespace" && exit 1
              fi
          fi
          echo "Before Edit parameters for namespace: $namespace"
          asinfo -v "get-config:context=namespace;id=$namespace" -l
          echo "Please input the value of data file: "
          read datafile
          asinfo -v "set-config:context=namespace;id=$namespace;storage-engine.device[0]=$datafile" 
          echo "After Edit parameters for namespace: $namespace"
          asinfo -v "get-config:context=namespace;id=$namespace" -l
          ;;
       h) echo "-a for phrase: load | run" 
          echo "-b : the name of block device"
          echo "-w : using the workloads/workloada totally? y|n"
          echo "-h for help"
          echo "-l: show|edit|add the logs information"
          echo "-n: show the name of namespace"
          echo "-d: set the name of namespace and also change the configuration value of datafile"
          echo "-m: set the name of namespace and also change the configuration value of memory-size"
          echo "-c: storage-engine: device|file"
          echo "-t: thread count: 100|50|200"
          echo "-r: recordcount: 50000000|100000000"
          ;;
       *) echo "Unknown option: $vname";;
esac
done



echo "Options:"
echo "  -threads n: execute using n threads (default: 1) - can also be specified as the \n" +
echo "        \"threadcount\" property using -p"
echo "  -target n: attempt to do n operations per second (default: unlimited) - can also\n" +
echo "       be specified as the \"target\" property using -p"
echo "  -load:  run the loading phase of the workload"
echo "  -t:  run the transactions phase of the workload (default)"
echo "  -db dbname: specify the name of the DB to use (default: com.yahoo.ycsb.BasicDB) - \n" +
echo "        can also be specified as the \"db\" property using -p"
echo "  -P propertyfile: load properties from the given file. Multiple files can"
echo "           be specified, and will be processed in the order specified"
echo "  -p name=value:  specify a property to be passed to the DB and workloads;"
echo "          multiple properties can be specified, and override any"
echo "          values in the propertyfile"
echo "  -s:  show status during run (default: no status)"
echo "  -l label:  use label for status (e.g. to label one experiment out of a whole batch)"

echo "action=$action storage-engine=$device using_workloads/workloada=$ret bldevice=$bldevice thread=$thread recordcount=$recount namespace=$namespace"

dsfxmessage=/var/log/sfx_messages

if [ "$action" = "load" ];then
    doutputload=$root_dir/outputLoad/$prefix
    mkdir -p $doutputload
    echo $doutputload
    ctime=`date +%S%M%H`
    sfxdriver_log=$doutputload/$ctime.sfxd_message
    sfxdriver_pid=$doutputload/$ctime.tail_sfxd.pid
    echo -e "sfxdriver_message starts at: " $prefix $ctime "\n"  > $sfxdriver_log
    tail -f -n 0 $dsfxmessage >> $sfxdriver_log &
    echo $! > $sfxdriver_pid
    if [ $device = "file" ];then
        echo "will clean the data from aerospike server"
        service aerospike stop && rm -rf /opt/aerospike/data/*.dat
    fi
    if [ $device = "device" ];then
        if [ -z "$bldevice" ];then
            echo "will clean all of the no-mountpoint block device list: "
            lsblk | grep sfd | awk '{if (!$7) {print $1}}' 
            lsblk | grep sfd | awk '{if (!$7) {cmd="nvme format /dev/"$1;system(cmd)}}'
        else
            echo "nvme format /dev/$bldevice"
            nvme format /dev/$bldevice
        fi
    fi
 
    service aerospike restart
    service aerospike status
    #echo "using the workloads/workloada totally? y|n "
    #read ret
    ctime=`date +%S%M%H`
    outfile=$ctime"_load.txt"
    iostat_log=$doutputload/$ctime.iostat
    iostat_pid=$iostat_log.pid
    iostat -txdm 1 >> $iostat_log &
    echo $! > $iostat_pid
    if [ "$ret" = "n" ];then
        echo "characterize parameters......namespace=$namespace threads=$thread  recordcount=$recount"
        bin/ycsb load aerospike -P workloads/workloada -p as.host=localhost -p as.namespace=$namespace -threads $thread -p recordcount=$recount -s >$doutputload/$outfile
    elif [ "$ret" = "y" ];then
       echo "workloada....."
       ./bin/ycsb load aerospike -s -P workloads/workloada -p as.timeout=5000 >$doutputload/$outfile
    fi
    cat $iostat_pid | xargs kill -9
    cat $sfxdriver_pid | xargs kill -9
elif [ "$action" = "run" ];then
    doutputRun=$root_dir/outputRun/$prefix
    mkdir -p $doutputRun
    echo $doutputRun
    ctime=`date +%S%M%H`
    outfile=$ctime"_Run.txt"

    iostat_log=$doutputRun/$ctime.iostat
    iostat_pid=$iostat_log.pid

    iostat -txdm 1 >> $iostat_log &
    echo $! > $iostat_pid

    sfxdriver_log=$doutputRun/$ctime.sfxd_message
    sfxdriver_pid=$doutputRun/$ctime.tail_sfxd.pid
    echo -e "sfxdriver_message starts at: " $prefix $ctime "\n"  > $sfxdriver_log
    tail -f -n 0 $$dsfxmessage >> $sfxdriver_log &
    echo $! > $sfxdriver_pid

    ./bin/ycsb run aerospike -s -P workloads/workloada > $doutputRun/$outfile
     
    cat $iostat_pid | xargs kill -9
    cat $sfxdriver_pid | xargs kill -9
else
    echo "Run sudo bin/ycsb load aerospike -P workloads/workloada -p as.host=localhost -p as.namespace=$ -threads 100 -p recordcount=50000000 -s to star load phrase: " 
    echo "Run sudo ./bin/ycsb run aerospike -s -P workloads/workloada to start run phrase"
fi

# some tips:
# service aerospike status
# systemctl restart nfs
# mount /dev/sfd0n1 /opt/aerospike/data/


# sudo rpm -ivh aerospike-server-community-4.5.1.5-1.el7.x86_64.rpm
# sudo rpm -ivh aerospike-tools-3.18.1-1.el7.x86_64.rpm
# https://www.aerospike.com/docs/operations/install/linux/el6 

# sudo mkfs.ext4 /dev/sfd1n1
# sudo mkfs.ext4 /dev/sfd1n1
# sudo mount /dev/sfd1n1 /opt/aerospike/data/

#asinfo -v "set-config:context=namespace;id=css_bar;conflict-resolution-policy=last-update-time"
# mvn -pl com.yahoo.ycsb:aerospike-binding -am clean package
# for f in `ls -a *.pid`; do cat $f; done

conf_dir=/etc/aerospike
default_conf=aerospike.conf
sfxd=("sfd2n1" "sfd0n1" "sfd1n1")
#sfxd=("sfd0n1")
host=192.168.10.202

oneY=100000000
#exetime=43200
exetime=7200

#ret=y means always use the configure file of workloads/workloada 
ret=y 

function ycsb_options()
{
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
}


function prepare_conf()
{
    echo $1
    if [ "$1" = "all" ];then
       echo "will reset config file later: "
       tune2fs -O has_journal /dev/sfd0n1
       mount /dev/sfd0n1 /opt/aerospike/data/
    else
       confpath=$conf_dir/sfx_aerospike/
       if [ "$recount" = "$oneY" ];then
           confpath=$confpath"1Y"
       fi
       echo "cp -P $confpath/$1_$default_conf $conf_dir/$default_conf"
       cp -P $confpath/$1_$default_conf $conf_dir/$default_conf
    fi
}


while getopts :a:b:l:n:m:d:h:c:w:t:r:o:s:g:p: vname 
do
    case "$vname" in
       a) #echo "$OPTARG: load | run"
          action=$OPTARG
          ;;
       g) 
          echo $OPTARG
          ;;
       p)
          echo $OPTARG
          port=$OPTARG
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
          prepare_conf $OPTARG 
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
          #define bldevice=sfd0n1 to only test sfd0n1
          bldevice=sfd0n1
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
       o) echo "YCSB OPtions"
          ycsb_options
          exit 0
          ;;
       h) echo "-a for phrase: load | run" 
          echo "-b : the name of block device"
          echo "-w : using the workloads/workloada totally? y|n"
          echo "-h for help"
          echo "-l: show|edit|add the logs information"
          echo "-n: show the name of namespace"
          echo "-d: set the name of namespace and also change the configuration value of datafile"
          echo "-m: set the name of namespace and also change the configuration value of memory-size"
          echo "-c: storage-engine: device|ext4|xfs"
          echo "-t: thread count: 100|50|200"
          echo "-r: recordcount: 50000000|100000000"
          echo "-g: test "
          echo "-o: YCSB Options: "
          ;;
       *) echo "Unknown option: $vname";;
esac
done


function cls_data()
{
   fs=$1
   if [ $fs = "xfs" ];then
       echo "will clean the data from aerospike server"
       #service aerospike stop && rm -rf /opt/aerospike/xfsdata/*.dat
       service aerospike stop
       service aerospike status
       rm -rf /opt/aerospike/xfsdata/*.dat
       umount /dev/${sfxd[2]}
       mkfs -t xfs /dev/${sfxd[2]}
       mount /dev/${sfxd[2]} /opt/aerospike/xfsdata
   fi
   if [ $fs = "ext4" ];then
       #service aerospike stop && rm -rf /opt/aerospike/data/*.dat
       service aerospike stop
       service aerospike status
       rm -rf /opt/aerospike/data/*.dat
       umount /dev/${sfxd[1]}
       mkfs.ext4 /dev/${sfxd[1]}
       mount /dev/${sfxd[1]} /opt/aerospike/data
   fi
   if [ $fs = "device" ];then
       service aerospike stop
       if [ -z "$bldevice" ];then
           echo "will clean all of the no-mountpoint block device list: "
           lsblk | grep sfd | awk '{if (!$7) {print $1}}'
           lsblk | grep sfd | awk '{if (!$7) {cmd="nvme format /dev/"$1;system(cmd)}}'
       else
           echo "nvme format /dev/$bldevice"
           nvme format /dev/$bldevice
           source ./autoAnyCSSdisk.sh /dev/sfd0n1
       fi
   fi
}

flag=YCSB_
prefix=$flag`date +%d%m%y_%H%M%S`
logctime=$flag`date +%d%m%y_%H:%M:%S`
root_dir=`pwd`
presult=$root_dir/output/aerospike/$prefix
mkdir -p $presult/csv
#action=load
dsfxmessage=/var/log/sfx_messages
running=$presult/$action

echo "action=$action storage-engine=$device using_workloads/workloada=$ret bldevice=$bldevice thread=$thread recordcount=$recount namespace=$namespace port=$port"

iostat2csv()
{
    echo "will save files in $presult to csv"
    for f in `ls $presult/*.iostat`;
    do
        cat $f | grep -m 1 Device | sed -r 's/\s+/,/g' > $f.csv
        cat $f | grep sfd | sed -r 's/\s+/,/g' >> $f.csv
        mv $f.csv $presult/csv/
    done
}

result2csv()
{
    echo "will save files in $presult to csv"
    for f in `ls $presult/*.result`;
    do
        cat $f | grep Throughput | sed -r 's/\s+/,/g' > $f.csv
        cat $f | grep RunTime | sed -r 's/\s+/,/g' >> $f.csv
        cat $f | grep Latency | sed -r 's/\s+/,/g' >> $f.csv
        mv $f.csv $presult/csv/
    done
}

flagjournal=journal.statue

function doload()
{
    device=$1
    io_sfx=$2
    echo device=$1 io_sfx=$2
    ppath=$running
    
    if [ "$device" = "ext4" ];then
        dumpe2fs /dev/sfd0n1 | grep 'Filesystem features' | grep 'has_journal' | awk '{print $1 $2 $3}' > $flagjournal
        #cat $flagjournal
        if [ `grep "has_journal" $flagjournal` ];then
            echo "enable journal"
            #running=$running.has_journal
            ppath=$running.has_journal
        else
            echo "disabled journal"
            #running=${running/has_journal/no_journal}
            ppath=$running.no_journal
        fi
    fi

    sfxdriver_log=$ppath.$device.sfxd_message
    sfxdriver_pid=$sfxdriver_log.pid
    echo -e "$device sfxdriver_message starts at: " $logctime "\n"  > $sfxdriver_log
    tail -f -n 0 $dsfxmessage  >> $sfxdriver_log &
    echo $! > $sfxdriver_pid

    iostat_log=$ppath.$device.iostat
    iostat_pid=$iostat_log.pid

    #iostat all of the sfdx devie, will change it later
    #lsblk | grep sfd | awk '{print "/dev/"$1}' | xargs iostat -txdm 1 >> $iostat_log &
    echo iostat -txdm /dev/$io_sfx 3 >> $iostat_log &
    iostat -txdm /dev/$io_sfx 3 >> $iostat_log &
    
    echo $! > $iostat_pid

    outfile=$ppath.$device.result

    service aerospike restart
    #echo "loading data from /dev/$bldevice"
    #sleep 60

    service aerospike status

    echo -e "$device $action phrase starts at:  "$logctime "\n"  > $outfile
    if [ "$ret" = "n" ];then
        echo "characterize parameters......namespace=$namespace threads=$thread  recordcount=$recount p=$port"
        #bin/ycsb load aerospike -P workloads/workloada -p as.host=$host -p as.port=$port -p as.namespace=$namespace -threads $thread -p recordcount=$recount -s >> $outfile
        echo "bin/ycsb load aerospike -P workloads/workloada_load -p as.host=$host -p as.port=$port -p as.namespace=$namespace -threads $thread -p recordcount=$recount -s >> $outfile 2>&1 " >>$outfile
        bin/ycsb load aerospike -P workloads/workloada_load -p as.host=$host -p as.port=$port -p as.namespace=$namespace -threads $thread -p recordcount=$recount -s >> $outfile 2>&1
    elif [ "$ret" = "y" ];then
       echo "workloada....." >>$outfile
       ./bin/ycsb load aerospike -s -P workloads/workloada_load -p as.timeout=5000 >> $outfile 2>&1
    fi

    cendtime=$flag`date +%d%m%y_%H:%M:%S`
    echo -e "\n$device $action phrase ends at: "$cendtime "\n"  >> $outfile &
    echo -e "\n$device sfxdriver_message ends at: "$cendtime "\n"  >> $sfxdriver_log &
    cat $iostat_pid | xargs kill -9 &
    cat $sfxdriver_pid | xargs kill -9 &
    rm -rf $presult/*pid
}

function dorun()
{
    device=$1
    io_sfx=$2
    echo device=$1 io_sfx=$2
    action=run
    pp=$presult/$action
    #thread=60
    logctime=$flag`date +%d%m%y_%H:%M:%S`

    if [ "$device" = "ext4" ];then
        dumpe2fs /dev/sfd0n1 | grep 'Filesystem features' | grep 'has_journal' | awk '{print $1 $2 $3}' > $flagjournal
        if [ `grep "has_journal" $flagjournal` ];then
            echo "enable journal"
            pp=$running.has_journal
        else
            echo "disabled journal"
            pp=$running.no_journal
        fi
    fi

    daslog=/var/log/aerospike/aerospike.log
    as_log=$pp.$device.as_log
    aslog_pid=$as_log.pid
    echo -e "$device aerospike log starts at: " $logctime "\n"  > $as_log
    tail -f -n 0 $daslog  >> $as_log &
    echo $! > $aslog_pid

    sfxdriver_log=$pp.$device.sfxd_message
    sfxdriver_pid=$sfxdriver_log.pid
    echo -e "$device sfxdriver_message starts at: " $logctime "\n"  > $sfxdriver_log
    tail -f -n 0 $dsfxmessage  >> $sfxdriver_log &
    echo $! > $sfxdriver_pid

    iostat_log=$pp.$device.iostat
    iostat_pid=$iostat_log.pid

    #iostat all of the sfdx devie, will change it later
    #lsblk | grep sfd | awk '{print "/dev/"$1}' | xargs iostat -txdm 1 >> $iostat_log &
    echo iostat -txdm /dev/$io_sfx 3 >> $iostat_log &
    iostat -txdm /dev/$io_sfx 3 >> $iostat_log &

    echo $! > $iostat_pid

    outfile=$pp.$device.result

    #disable restart aerospike server because if doing that, run will fail due to connection timeout
    #service aerospike restart
    service aerospike status

    echo -e "$device $action phrase starts at:  "$logctime "\n"  > $outfile
    if [ "$ret" = "n" ];then
        echo "bin/ycsb run aerospike -P workloads/workloada_run -p as.host=$host -p as.port=$port -p as.namespace=$namespace -threads $thread -p maxexecutiontime=$exetime -p recordcount=$recount -s >> $outfile 2>&1" >> $outfile
        bin/ycsb run aerospike -P workloads/workloada_run -p as.host=$host -p as.port=$port -p as.namespace=$namespace -threads $thread -p maxexecutiontime=$exetime -p recordcount=$recount -s >> $outfile 2>&1
    elif [ "$ret" = "y" ];then
        echo "workloada..... $action"
        bin/ycsb run aerospike -s -P workloads/workloada_run -p operationcount=50000000 >> $outfile
    fi

    cendtime=$flag`date +%d%m%y_%H:%M:%S`
    echo -e "\n$device $action phrase ends at: "$cendtime "\n"  >> $outfile &
    echo -e "\n$device sfxdriver_message ends at: "$cendtime "\n"  >> $sfxdriver_log &
    echo -e "\n$device aerospike log ends at: "$cendtime "\n"  >> $as_log &
    cat $iostat_pid | xargs kill -9 &
    cat $sfxdriver_pid | xargs kill -9 &
    cat $aslog_pid | xargs kill -9 &
    rm -rf $presult/*pid
}


if [ "$action" = "load" ];then
    if [ "$device" = "all" ];then
        i=0
        #for d in device ext4 xfs
        for d in device 
        do
            prepare_conf $d 
            cls_data $d

            if [ "$1" = "ext4" ];then
                tune2fs -O has_journal /dev/sfd0n1
                mount /dev/${sfxd[1]} /opt/aerospike/data/
            fi
            if [ "$1" = "xfs" ];then
                mount /dev/${sfxd[2]} /opt/aerospike/xfsdata/ 
            fi
            doload $d ${sfxd[$i]}
            i=$[i+1]
        done
        # do test disable journal log
        #umount /dev/sfd0n1
        #fsck.ext4 -f  /dev/sfd0n1
        #tune2fs -O ^has_journal /dev/sfd0n1
        #fsck.ext4 -f  /dev/sfd0n1
        #mount /dev/sfd0n1 /opt/aerospike/data/
        #prepare_conf ext4 
        #cls_data ext4
        #doload ext4 ${sfxd[1]}   
    else
        cls_data $device
        doload $device $bldevice
        dorun  $device $bldevice
    fi
elif [ "$action" = "run" ];then
    dorun $device $bldevice
else
    echo "Run sudo bin/ycsb load aerospike -P workloads/workloada -p as.host=localhost -p as.namespace=$ -threads 100 -p recordcount=50000000 -s to star load phrase: " 
    echo "Run sudo ./bin/ycsb run aerospike -s -P workloads/workloada to start run phrase"
fi

iostat2csv
result2csv



# some tips:
# service aerospike status
# systemctl restart nfs
# mount /dev/sfd0n1 /opt/aerospike/data/


# sudo rpm -ivh aerospike-server-community-4.5.1.5-1.el7.x86_64.rpm
# sudo rpm -ivh aerospike-tools-3.18.1-1.el7.x86_64.rpm
# https://www.aerospike.com/docs/operations/install/linux/el6 

# sudo mkfs.ext4 /dev/sfd0n1
# sudo mkfs -t xfs /dev/sfd1n1
# mkdir -p /opt/aerospike/xfsdata
# mount /dev/sfd1n1 /opt/aerospike/xfsdata/
# sudo mkfs.ext4 /dev/sfd1n1
# sudo mount /dev/sfd0n1 /opt/aerospike/data/

#asinfo -v "set-config:context=namespace;id=css_bar;conflict-resolution-policy=last-update-time"
# mvn -pl com.yahoo.ycsb:aerospike-binding -am clean package
# for f in `ls -a *.pid`; do cat $f; done
#sudo ./loadrun.sh -a load -n css_bar -c file -t 100 -r 500000000 -w n
#sudo ./loadrun.sh -a load -n css_bar -c device -b sfd2n1 -t 100 -r 500000000 -w n
#sudo ./loadrun.sh -a load -n css_bar -c all -b sfd2n1 -t 100 -r 50000000 -w n


#sudo ./loadrun.sh -a load -n css_bar -b sfd2n1 -t 100 -r 100000000 -c device -w n

#sudo ./loadrun.sh -a load -n css_bar -b sfd0n1 -t 100 -r 100000000 -c ext4 -w n
#sudo ./bin/ycsb run aerospike -s -P workloads/workloada -p as.host=192.168.10.202 -p as.port=3000 -p as.namespace=css_sfx -threads 100 -p operationcount=100000000 -s -t

# sudo ./loadrun.sh -a load -n css_sfx -b sfd2n1 -t 100 -r 270000000 -c device -w n -p 3000

#sudo ./loadrun.sh -a load -n css_sfx -b sfd2n1 -t 100 -r 270000000 -c device -w n -p 3000 

#sudo ./loadrun.sh -a load -n css_sfx -b sfd2n1 -t 100 -r 270000000 -c device -w n -p 3000 > 948oo.log   2>1 &
#sudo ./loadrun.sh -a load -n css_sfx  -t 100 -r 270000000 -c device -w n -p 3000 > 948oo.log   2>&1 

#sudo bin/ycsb load aerospike -P workloads/workloada -p as.host=192.168.10.202 -p as.port=3000 -p as.namespace=css_sfx -threads 100 -p recordcount=200000000 -s


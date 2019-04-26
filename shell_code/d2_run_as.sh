while getopts :l:n:e:d:h vname 
do
    case "$vname" in
       l) echo $OPTARG 
          if [ "$OPTARG" = "show" ];then
              echo "showing the logs information used by aerospike server" &&  asinfo -v 'logs'
          elif [ "$OPTARG" = "edit" ];then
              echo "will disable the debug_logs information"
              asinfo -v --config-file /etc/aerospike/infolog_aerospike.conf
              service aerospike restart
              service aerospike status
          elif [ "$OPTARG" = "add" ];then
              echo "will add the debug_logs information"
              asinfo -v --config-file /etc/aerospike/aerospike.conf
              service aerospike restart
              service aerospike status
          fi
          ;;
       n)
          echo "namespace: $OPTARG" && asinfo -v "namespaces"
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
          asinfo -v "set-config:context=namespace;id=$namespace;file=$datafile" 
          echo "After Edit parameters for namespace: $namespace"
          asinfo -v "get-config:context=namespace;id=$namespace" -l
          ;;
       h) echo "h for help"
          echo "-l: show|edit|add the logs information"
          echo "-n: show the name of namespace"
          ;;
       *) echo "Unknown option: $vname";;
done


sudo service aerospike stop
sudo rm -rf /opt/aerospike/data/*.dat

sudo service aerospike restart
sudo service aerospike status
#asinfo -v "set-config:context=namespace;id=css_bar;conflict-resolution-policy=last-update-time"

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

# mvn -pl com.yahoo.ycsb:aerospike-binding -am clean package

./bin/ycsb load aerospike -s -P workloads/workloada -p as.timeout=5000 
# echo ./bin/ycsb load aerospike -s -P workloads/workloada -p as.timeout=5000 
#./bin/ycsb run aerospike -s -P workloads/workloada


# service aerospike status
# systemctl restart nfs
# mount /dev/sfd0n1 /opt/aerospike/data/


# sudo rpm -ivh aerospike-server-community-4.5.1.5-1.el7.x86_64.rpm
# sudo rpm -ivh aerospike-tools-3.18.1-1.el7.x86_64.rpm
# https://www.aerospike.com/docs/operations/install/linux/el6 

# sudo mkfs.ext4 /dev/sfd1n1
# sudo mkfs.ext4 /dev/sfd1n1
# sudo mount /dev/sfd1n1 /opt/aerospike/data/


service aerospike stop
sudo rm -rf /opt/aerospike/data/*.dat
service aerospike restart
service aerospike status
#echo $1
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

./bin/ycsb load aerospike -s -P workloads/workloada -p as.timeout=5000 >$1Load.txt
# echo ./bin/ycsb load aerospike -s -P workloads/workloada -p as.timeout=5000 >$1Load.txt
#./bin/ycsb run aerospike -s -P workloads/workloada >$1Run.txt


# service aerospike status
# systemctl restart nfs
# mount /dev/sfd0n1 /opt/aerospike/data/


# sudo rpm -ivh aerospike-server-community-4.5.1.5-1.el7.x86_64.rpm
# sudo rpm -ivh aerospike-tools-3.18.1-1.el7.x86_64.rpm
# https://www.aerospike.com/docs/operations/install/linux/el6 

# sudo mkfs.ext4 /dev/sfd1n1
# sudo mkfs.ext4 /dev/sfd1n1
# sudo mount /dev/sfd1n1 /opt/aerospike/data/


echo
while getopts :l:n:c:h vname 
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
          fi
          ;;
       n)
          echo "namespace: $OPTARG" && asinfo -v "namespaces"
          ;;
       h) echo "h for help"
          echo "-l: show|edit the logs information"
          echo "-n: show the name of namespace"
          ;;
       *) echo "Unknown option: $vname";;
   esac
done


#namespace=$1
#if test -z "$1"
#then echo 'Please input the correct namespace: ' 
#read namespace
#if test -z namespace
#then echo 'Error namespace'
#exit 1
#else
#echo 'namespace:' ${namespace}
#fi
#fi

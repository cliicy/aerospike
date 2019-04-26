for((i=16;i<=112;i+=16))
do
 echo $i
done
exit 0

echo
while getopts :l:n:e:h vname 
do
    case "$vname" in
       l) echo $OPTARG 
	  if [ "$OPTARG" = "show" ];then
              echo "showing the logs information used by aerospike server" &&  asinfo -v 'logs'
          elif [ "$OPTARG" = "edit" ];then
              echo "will disable the debug_logs information"
              asinfo --only-config-file /etc/aerospike/nodubug_aerospkie.conf
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
       e) namespace=$OPTARG
          if [ "$namespace" = "" ];then
              echo 'Please input the correct namespace: '
              read namespace
              if [ $namespace ="" ];then
                  echo "Error namespace" && exit 1
              fi
          fi
          echo "Before Edit parameters for  namespace: $namespace"
	  asinfo -v "get-config:context=namespace;id=$namespace" -l
          echo "After Edit parameters for  namespace: $namespace"
	  asinfo -v "set-config:context=namespace;id=$namespace;memory-size=5G" -l
	  asinfo -v "get-config:context=namespace;id=$namespace" -l
          ;;
       h) echo "h for help"
          echo "-l: show|edit|add the logs information"
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

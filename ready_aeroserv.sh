tmpfile=$1

#tail -f -n 0 $daslog  >> $tmpfile &
while true
do
    echo "checking aerospike service is active or not......"
    #grep -l "service ready: soon there will be cake!" $tmpfile
    grep "service ready: soon there will be cake!" $tmpfile
    if [ $? -eq 0 ];then
        echo "aerospike is active now!"
        break 
    fi
    sleep 1
done
echo "finish"


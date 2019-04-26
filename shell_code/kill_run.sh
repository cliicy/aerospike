ps -ef | grep loadrun.sh | awk {'print $2'} >ttr.txt
echo cat ttr.txt | xargs kill -9
cat ttr.txt | xargs kill -9


ps -ef | grep ycsb | awk {'print $2'} >ttr.txt
echo cat ttr.txt | xargs kill -9
cat ttr.txt | xargs kill -9

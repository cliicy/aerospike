presult=`pwd`/YCSB_180419_171149
echo $presult

result2csv()
{
    echo "will save files in $presult to csv"
    for f in `ls $presult/*.result`;
    do
        cat $f | grep Throughput | sed -r 's/\s+/,/g' > $f.csv
        cat $f | grep RunTime | sed -r 's/\s+/,/g' >> $f.csv
        cat $f | grep AverageLatency | sed -r 's/\s+/,/g' >> $f.csv
        mv $f.csv $presult/csv/
    done
}


result2csv

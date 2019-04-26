presult=`pwd`
echo $presult

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


result2csv

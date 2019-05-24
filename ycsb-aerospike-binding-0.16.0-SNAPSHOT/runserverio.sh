#as_ip=192.168.3.87
#ssh $as_ip "sh /home/tcn/as_ycsb_test/YCSB.15.0/lrio_gx.sh sfd0n1 &" &
as_ip=192.168.10.202
as_path=/home/tcn/projs/benchmark/YCSB.15.0
ssh $as_ip "sh $as_path/lrio_gx.sh sfd0n1 100" &

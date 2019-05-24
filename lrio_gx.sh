# $1=sfd1n1 or sfd0n1
BASE_PATH=$(cd `dirname $0`;pwd)
#echo $BASE_PATH >/tmp/ll.log
pushd $BASE_PATH
sh gx_loadrun.sh -a load -n css_sfx -b $1 -t $2 -r 300000000  -i 1 -c ext4 -w n -p 3000

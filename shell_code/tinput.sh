namespace=$1
if test -z "$1"
then echo 'Please input the correct namespace: ' 
read namespace
if test -z namespace
then echo 'Error namespace'
exit 1
fi
fi

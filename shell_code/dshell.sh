lsblk | grep sfd | awk '{if (!$7) {print "sudo nvme format /dev/"$1}}' 
lsblk | grep sfd | awk '{if (!$7) {cmd="nvme format /dev/"$1;system(cmd)}}' 


grep  "free-kbytes" $1  | awk {'print $9,$10,$11,$12,$13'} > sysmem.log
grep  "total-bytes" $1  | awk {'print $10,$11,$12,$13,$14,$17,$18'} > memory-usage.log
grep  "device-usage" $1  | awk {'print $10,$11,$12,$13,$14'} > device-usage.log


asinfo -v "set-config:context=namespace;id=css_bar;conflict-resolution-policy=last-update-time"

service aerospike restart
service aerospike status

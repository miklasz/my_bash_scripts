#!/bin/bash
user="netbox"
password="password-goes-here"
host="localhost"
db_name="netbox"
date=$(date +"%d-%b-%Y-%H.%M.%S")
filename=/opt/netbox/daily/db_netbox_backup-$date.sql
sudo -u postgres pg_dump --dbname=postgresql://$user:$password@127.0.0.1:5432/$db_name > /opt/netbox/daily/db_netbox_backup-$date.sql
gzip $filename
file=$(find /opt/netbox/daily/ -name db_netbox_backup-\*.sql.gz -type f -ctime -3 | sort -n | tail -1)
eval "$(ssh-agent -s)"
ssh-add -k /opt/netbox/netbox.key
scp $file bart@ip-goes-here:/home/bart/daily/

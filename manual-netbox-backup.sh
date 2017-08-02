#!/bin/bash
user="netbox"
password="PASSWORD"
host="localhost"
db_name="netbox"
date=$(date +"%d-%b-%Y-%H.%M.%S")
filename=/opt/netbox/daily/db_netbox_backup-$date.sql
sudo -u postgres pg_dump --dbname=postgresql://$user:$password@127.0.0.1:5432/$db_name > /opt/netbox/daily/db_netbox_backup-$date.sql
tar -zcvf /opt/netbox/daily/netbox_backup-$date.tar.gz $filename /opt/netbox/netbox/media/
file=$(find /opt/netbox/daily/ -name netbox_backup-\*.gz -type f -ctime -3 | sort -n | tail -1)
eval "$(ssh-agent -s)"
ssh-add -k /opt/netbox/netbox.key
scp $file bart@185.98.149.132:/home/bart/daily/

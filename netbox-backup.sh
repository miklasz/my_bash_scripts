#!/bin/bash
user="netbox"
password="PASSWORD"
host="localhost"
db_name="netbox"
date=$(date +"%d-%b-%Y-%H.%M.%S")
db_filename=/var/backups/netbox_backup-$date.sql
pg_dump --dbname=postgresql://$user:$password@127.0.0.1:5432/$db_name > /var/backups/netbox_backup-$date.sql
tar -zcvf /var/backups/netbox_backup-$date.tar.gz $db_filename /opt/netbox/netbox/media/*
rm $db_filename

# Manual Netbox DB Backup how to:
# go to: https://datacentred.atlassian.net/wiki/display/~bartosz.miklaszewski/BM+-+Netbox+-+DB+Manual+Backup

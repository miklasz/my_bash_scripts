#!/bin/bash
user="netbox"
password="password"
host="127.0.0.1"
db_name="netbox"
date=$(date +"%d-%b-%Y-%H.%M.%S")
filename=/opt/netbox/db_netbox_backup-$date.sql
pg_dump --dbname=postgresql://$user:$password@$host:5432/$db_name > db_netbox_backup-$date.sql
gzip $filename

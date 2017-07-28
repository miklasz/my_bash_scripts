#!/bin/bash
export AWS_ACCESS_KEY_ID='<key>'
export AWS_SECRET_ACCESS_KEY='<key>'
cephdirectory='s3://<dir>'
destinationdir='/opt/netbox/restore'

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
NC=`tput sgr0`

while true
do
  echo -e ${BOLD}
  echo -e ${GREEN}"======================================"
  echo -e "   - Menu - - - -"
  echo -e "======================================"${NC}
  echo -e "                                                     "
  echo -e "   ${YELLOW}Datacentred Ceph${NC}                                  "
  echo -e "                                                     "
  echo -e "   List CEPH backup files        ${YELLOW} (l)${NC}  "
  echo -e "   Recover all files from backup ${YELLOW} (a)${NC}  "
  echo -e "   Recover listed file           ${YELLOW} (r)${NC}  "
  echo
  echo -e "                            Exit ${RED} (q)${NC} "
  echo -e "\n"
  echo -e "  What is your choice ${CYAN}¯\_(ツ)_/¯${NC} : \c"
read answer
case "$answer" in
l) duplicity list-current-files --no-encryption --force $cephdirectory ;;
a) duplicity restore --no-encryption --force $cephdirectory $destinationdir ;;
r) echo -e "   Enter file name to recover var/backups/\c"
read filename
duplicity  --file-to-restore var/backups/$filename --no-encryption --force $cephdirectory $destinationdir/$filename ;;
q) exit ;;
esac
done

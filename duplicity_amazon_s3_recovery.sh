#!/bin/bash
export PASSPHRASE='<retracted>'
export SIGN_PASSPHRASE='<retracted>'
export AWS_ACCESS_KEY_ID='<retracted>'
export AWS_SECRET_ACCESS_KEY='<retracted>'
encryptkey='<retracted>'
signkey='<retracted>'
amazondirectory='s3+http://<retracted>/'
destinationdir='/opt/netbox/restore'

RED=`tput setaf 1`
GREEN=`tput setaf 2`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
NC=`tput sgr0`

while true
do
  echo -e ${BOLD}
  echo -e ${GREEN}"======================================"
  echo -e "   - Menu - - - -"
  echo -e "======================================"${NC}
  echo -e "   List amazon backup files      ${MAGENTA} (l)${NC} "
  echo -e "   Recover all files from backup ${MAGENTA} (a)${NC} "
  echo -e "   Recover listed file           ${MAGENTA} (r)${NC} "
  echo
  echo -e "                            Exit ${RED} (q)${NC} "
  echo -e "\n"
  echo -e "  What is your choice ${CYAN}¯\_(ツ)_/¯${NC} : \c"
read answer
case "$answer" in
l) duplicity list-current-files --encrypt-key $encryptkey --sign-key $signkey --force $amazondirectory ;;
a) duplicity restore --encrypt-key $encryptkey --sign-key $signkey --force $amazondirectory $destinationdir ;;
r) echo -e "   Enter file name to recover var/backups/\c"
read filename
duplicity  --file-to-restore var/backups/$filename --encrypt-key $encryptkey --sign-key $signkey --force $amazondirectory $destinationdir/$filename ;;
q) exit ;;
esac
done

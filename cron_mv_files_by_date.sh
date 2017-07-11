#!/bin/bash
# move files older then 3 days to destination directory
find /home/bart/daily -maxdepth 1 -mtime +3 -type f -exec mv "{}" /home/bart/daily/old/ \;

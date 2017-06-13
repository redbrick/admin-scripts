#!/bin/bash

date=$(date +%Y%m%d)
success=0
loops=0

while [ $success -eq 0 ]; do
  success=$(grep -c success /backup/mysql/"$date"/summary)
  if [ "$success" -gt 0 ]; then
    files=$(find /backup/mysql/"$date"/tree/dumps/ -type f -printf "%P \n")
    for file in $files; do
      username=${file%.sql}
      group=$(id -g "$username")
      chown "$username":"$group" /backup/mysql/"$date"/tree/dumps/"$file"
    done
  elif [ $loops -gt 12 ]; then
    exit 1
  else
    $loops++
    sleep 1800
  fi
done

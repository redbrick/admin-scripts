#!/bin/bash
#Globals
device='/dev/sda1'
ndevice='/dev/sda1'

#Set New Quota's for ordinary users
new_bquota=2000000
new_blimit=2100000
new_fquota=1800000
new_flimit=2000000

#Get users start for loop
for user in $(getent passwd | awk -F : '{print $1}'); do
#Check for actual users with quotas
  if [ "$(quota -lu "$user" | grep -c $device)" -eq "1" ]; then
    old_bquota=$(quota -lu "$user" | grep $device | awk '{print $3}')
    old_blimit=$(quota -lu "$user" | grep $device | awk '{print $4}')
    old_fquota=$(quota -lu "$user" | grep $device | awk '{print $6}')
    old_flimit=$(quota -lu "$user" | grep $device | awk '{print $7}')
    #Compare old v new and setup values for set quota:
    #Block Quota
    if [ "$old_bquota" -lt $new_bquota ]; then
      bquota=$new_bquota
    else
      bquota=$old_bquota
    fi
    #Block Limit
    if [ "$old_blimit" -lt $new_blimit ]; then
       blimit=$new_blimit
    else
      blimit=$old_blimit
    fi
    #File Quota
    if [ "$old_fquota" -lt $new_fquota ]; then
      fquota=$new_fquota
    else
      fquota=$old_fquota
    fi
    #File Limit
    if [ "$old_flimit" -lt $new_flimit ]; then
      flimit=$new_flimit
    else
      flimit=$old_flimit
    fi
    #Set the users Quota on New Device
    setquota -u "$user" "$bquota" "$blimit" "$fquota" "$flimit" "$ndevice"
    #Testing:
    echo User: "$user"
    echo -e "Old Quota: $device\t$old_bquota\t$old_blimit\t$old_fquota\t$old_flimit"
    echo -e "New Quota: $ndevice\t$bquota\t$blimit\t$fquota\t$flimit"
  else
    echo "User $user has no $device quota"
    echo
  fi
  echo ----------------------------------------------------------------------
done

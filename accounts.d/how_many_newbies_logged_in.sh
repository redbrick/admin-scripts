#!/bin/bash
NUMBER=0

for a in $(/srv/admin/scripts/rrs/useradm list_newbies); do
  if finger "$a" | grep "Last login"; then
    NUMBER=$(("$NUMBER"+1))
  fi
done

echo $NUMBER

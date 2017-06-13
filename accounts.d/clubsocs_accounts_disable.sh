#!/bin/sh

# -M flag means member will not be e-mailed their new account details.

#Account Listings Clubs 102, Socs 101, dcu 31382, projects 1014, intersocs 1016
clubs=$(ldapsearch -xLLL "(gidnumber=102)" | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}')
socs=$(ldapsearch -xLLL "(gidnumber=101)" | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}')
dcu=$(ldapsearch -xLLL "(gidnumber=31382)" | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}')
projects=$(ldapsearch -xLLL "(gidnumber=1014)" | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}')
intersocs=$(ldapsearch -xLLL "(gidnumber=1016)" | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}')

list="$clubs\n$socs\n$dcu\n$projects\n$intersocs"

msg=/srv/admin/scripts/accounts.d/message.txt

#for user in $(ls /home/society)
echo "You are about to disable all Impersonal RedBrick Accounts - To proceed type \"Proceed\", Print will show the accounts about to be diabled"
read -r ans

if [ "$ans" = "Proceed" ]; then
  for user in $list; do
    useradm resetpw -M "$user"
    useradm setshell "$user" /usr/local/shells/disabled
    altmail=$(useradm show "$user" | grep altmail | awk '{print $2}')
    mutt -s "Your RedBrick Account" "$user" "$altmail" < $msg
  done
elif [ "$ans" = "Print" ]; then
  for i in $list; do
    echo "$i"
  done
else
  echo Exiting
  exit
fi

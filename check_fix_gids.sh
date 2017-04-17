#!/bin/bash

#Get Gids from LDAP

names=`ldapsearch -xLLL "(objectClass=posixGroup)" gidNumber | grep dn | awk -F = '{print $2}' | awk -F , '{print $1}'`

ids=`ldapsearch -xLLL "(objectClass=posixGroup)" gidNumber | grep gidNumber | awk '{print $2}'`

count=`ldapsearch -xLLL "(objectClass=posixGroup)" gidNumber | grep -c dn`

#Convet strings to Arrays

acount=`expr $count - 1`

for i in `seq 1 $count`; do
#	echo loop debug $i
	ai=`expr $i - 1`
	a_names[$ai]=`echo $names | awk '{print $'$i'}'`
#	echo ${a_names[$ai]}
	a_ids[$ai]=`echo $ids | awk '{print $'$i'}'`
#	echo ${a_ids[$ai]}

done

#Compare LDAP GIDS to System GIDS

for a in `seq 0 $acount`; do
# echo ${a_names[$a]}
# Check for group name in /etc/groups
# [ `grep -c ${a_names[$a]} /etc/group` -eq 1 ] && echo "${a_names[$a]} in /etc/group" || echo "${a_names[$a]} not in /etc/group"
if [ `grep -c ${a_names[$a]} /etc/group` -gt 0 ]; then
	# Check its been assigned the right gid
	[ `grep ${a_names[$a]} /etc/group | awk -F : '{print $3}'` = ${a_ids[$a]} ] || echo FUCK UP IN ${a_names[$a]} Group is not assigned the correct GID
else
	#IF Group is not there WARN AND ASK TO FIX
	echo "${a_names[$a]}:x:${a_ids[$a]} not in /etc/group"
	# Check for GID in use
#	[ `grep -c ${a_ids[$a]} /etc/group` -gt 0 ] && echo GID ${a_ids[$a]} in use || echo GID ${a_ids[$a]} not in use
	if [ `grep -c :${a_ids[$a]}: /etc/group` -gt 0 ]; then
		#GID is in use
		echo GID ${a_ids[$a]} in use by `grep :${a_ids[$a]}: /etc/group | awk -F : '{print $1}'`
		#This is complicated bit that requires finding and chgrping files in use by GID
		#genetate new gid
		RANDOM=$a
		newgid=$RANDOM
		while [ `grep -c :$newgid: /etc/group` -gt 0 ]; do
			newgid=$RANDOM
		done
		echo New GID is $newgid
	else
		echo GID ${a_ids[$a]} not in use
		# Append GID and name to /etc/group possible ask first
		echo "${a_names[$a]}:x:${a_ids[$a]}:" >> /etc/group
		#may use a fix variable for this instead and do writing at the end
	fi
fi
done

#ASSIGN NEW GIDS

#CHECH AND FIX GIDS of FILES NOT IN /STORAGE OR /FAST-STORAGE or TMP Dirs

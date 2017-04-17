#! /bin/bash

# Input : a file with a list of email addresses (one address per line)
# Check if the email is in our ldap, if not return the email address.

FILE=/home/aziz/emails.new

while read line
do
	if [ -z "$(ldapsearch -D cn=root,ou=ldap,o=redbrick -xLLL -y /etc/ldap.secret "altmail=$line" uid)" ]
	then
		echo $line
	fi
done <$FILE

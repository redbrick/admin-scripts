#!/bin/bash

# Script to add a hg repo
# Blame/contact werdz if there's any bugs or something doesn't work.

HG=/usr/bin/hg
COLLECTION=/storage/hg
APACHE_UID=33
APACHE_GID=33
WEBHOST=morpheus
ALLOW_ARCHIVE="gz zip bz2"
CHOWN=/bin/chown

if [[ $HOSTNAME != $WEBHOST ]]; then
	echo "This script must be run on the web server ($WEBHOST)."
	exit 1
fi

echo "What will this repository be called?"
read REPONAME

if [[ -e $COLLECTION/$REPONAME ]]; then
	echo "This repository already exists! Aborting."
	exit 2
fi

echo "What users should have write access to $REPONAME? (space separated list)"
read USERLIST

echo "Enter a brief description of this repository:"
read DESCRIPTION

echo "Enter a primary contact in the form Name <emailaddress@host.com>:"
read CONTACT

echo "Please confirm that the following details are correct:"
echo "Repository name: $REPONAME"
echo "Users with write (push) access: $USERLIST"
echo "Description: $DESCRIPTION"
echo "Primary contact: $CONTACT"
echo
echo -n "Are these correct? "
ANSWER=""

while [[ $ANSWER != "y" ]] && [[ $ANSWER != "n" ]]; do
	echo -n "(y/n) "
	read ANSWER
done

if [[ $ANSWER == "n" ]]; then
	echo "Aborting"
	exit 3
fi

echo "Init repository..."
$HG init $COLLECTION/$REPONAME
echo "Create configuration file..."
cat > $COLLECTION/$REPONAME/.hg/hgrc << EOF
[web]
allow_push = $USERLIST
contact = $CONTACT
description = $DESCRIPTION
allow_archive = $ALLOW_ARCHIVE
EOF
echo "Fix permissions..."
$CHOWN -R $APACHE_UID:$APACHE_GID $COLLECTION/$REPONAME
echo "Operation complete"

exit 0

#!/bin/bash

export http_proxy="http://proxy.dcu.ie:8080"
WEBDIR="/webtree/redbrick/htdocs"
TMPDIR="/tmp"
FILE="twitter.rss"

if [ ! -d $WEBDIR ]; then
	exit 1
fi

/usr/bin/wget -O $TMPDIR/$FILE http://twitter.com/statuses/user_timeline/28599864.rss &> /dev/null

# failure test
if [ $? -ne 0 ]; then
	exit 0
fi

sed -i 's/RedBrickDCU: //' $TMPDIR/$FILE
mv $TMPDIR/$FILE $WEBDIR/$FILE
chmod 644 $WEBDIR/$FILE

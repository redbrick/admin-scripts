#! /bin/sh
#Doesn't work with SIGINT, even though it should, fml :)

trap '' 1 2 3 CHLD TTOU TSTP XCPU

echo "--------------------------------------------------------------------------------"
echo "                     Your account has been disabled                             "
echo "--------------------------------------------------------------------------------"
echo ""

if [ -f /storage/daft/"$LOGNAME" ] && [ -s /storage/daft/"$LOGNAME" ] && [ -r /storage/daft/"$LOGNAME" ]; then
	cat /storage/daft/"$LOGNAME"
fi

echo ""
echo "--------------------------------------------------------------------------------"
echo "                        committee@redbrick.dcu.ie                               "
echo "--------------------------------------------------------------------------------"

sleep 10

exit

NUMBER=0

for a in $(/srv/admin/scripts/rrs/useradm list_newbies)
do
	finger $a | grep "Last login"

	if [ $? -eq 0 ]; then
		NUMBER=$[$NUMBER+1]
	fi
done

echo $NUMBER

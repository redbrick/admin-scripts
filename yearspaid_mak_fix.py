#!/usr/bin/python
import sys,string

"""
Fixing shit I fucked.

Running on the output of this search

ldapsearch -D cn=root,ou=ldap,o=redbrick -y /etc/ldap.secret -xLLL "(|(objectClass=club)(objectClass=society)(objectClass=projects)(objectClass=redbrick)(objectClass=dcu)(objectClass=intersoc)(objectClass=founders))"

"""

#print modify ldif template
def modifyTemplate(uid):
		dn = 'dn: uid='+uid.strip()
		dn += "\nchangetype: modify\ndelete: yearsPaid\n\n"
		print dn

#open ldif
with open(sys.argv[1], 'r') as content:
    ldif = content.read()
#split by user
getdn = string.split(ldif, 'dn: uid=')
for i in getdn:
	try:
		thisdn = string.split(i,'\n')
		uid = thisdn[0]
		if(len(uid) > 0):
			modifyTemplate(uid)
	except IndexError:
		continue

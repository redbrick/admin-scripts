#!/usr/bin/python3
"""
Fixing shit I fucked.
Running on the output of this search

ldapsearch -D cn=root,ou=ldap,o=redbrick -y /etc/ldap.secret -xLLL "(|(objectClass=club)
(objectClass=society)(objectClass=projects)(objectClass=redbrick)(objectClass=dcu)
"""
import sys

def modify_template(user_id):
    """print modify ldif template"""
    ldap_dn = 'dn: uid=' + user_id.strip()
    ldap_dn += "\nchangetype: modify\ndelete: yearsPaid\n\n"
    print(ldap_dn)

#open ldif
with open(sys.argv[1], 'r') as content:
    LDIF = content.read()
#split by user
GETDN = LDIF.split('dn: uid=')
for i in GETDN:
    try:
        thisdn = i.split('\n')
        uid = thisdn[0]
        if uid:
            modify_template(uid)
    except IndexError:
        continue

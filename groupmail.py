#!/usr/bin/python

"""
-maK
This is a script to send a mail to a group
defined by an ldap search
or simply send a singular mail

use ./groupmail -h
"""
import smtplib, string, argparse, os

def sendmail(frm, to, subject, body, cc):
    if(cc == None):
        cc = ''
    msg = string.join((
		'From: %s' % frm,
		'To: %s' % to,
        'CC: %s' % cc,
		'Subject: %s' % subject,
		'',
        '%s' % body), "\r\n")

    try:
        smtp = smtplib.SMTP('mail.redbrick.dcu.ie')
        smtp.sendmail(frm, to, msg)
        smtp.quit()
    except:
			print 'Error sending mail to ' + to

def mailgroup(ldif, frm, subject, body, cc, prnt):
    tomail = string.split(ldif, 'dn: uid=')
    cn = ''
    altmail = ''
    uid = ''
    for u in range(1,len(tomail)):
        credentials = string.split(tomail[u], '\n')
        for i in credentials:
            if(i.startswith('uid: ')):
                uid = i.split()[1]
            if(i.startswith('cn: ')):
                cn = i.split('cn: ')[1]
            if(i.startswith('altmail: ')):
                altmail = i.split()[1]
        if(prnt):
            print uid + ' - ' + cn + ' : ' + altmail
        else:
            #Send mail to each
            print 'Send mail to '+cn+' using '+altmail+' (y|n)?'
            send = raw_input('default(y): ')
            if((send == 'n') or (send == 'N')):
                print 'Mail not sent to '+cn+' using '+altmail+'\n'
            else:
                sendmail(frm, altmail.strip(), subject, body, cc)
                print 'Mail sent to '+cn+' using '+altmail+'\n'

def main():
    parser = argparse.ArgumentParser(description='Used to mail an ldap group/groups')
    parser.add_argument('-g',dest='GROUPS', type=str, help='Specify groups or singular group. (eg. club or club,society,founders,redbrick)')
    parser.add_argument('-p',dest='PRINT', action='store_true', help='Only print details - Do not send')
    parser.add_argument('-f',dest='FROM', type=str, help='Who the mail is from.')
    parser.add_argument('-cc',dest='CC', type=str, help='cc all mails to.')
    parser.add_argument('-m',dest='MSG', type=str, help='Location of Message to be sent (text file etc)')
    parser.add_argument('-t',dest='TO', type=str, help='Who singular mail is To.')
    parser.add_argument('-s',dest='SUBJECT', type=str, help='Subject of mail.')
    a = parser.parse_args()

    if a.GROUPS != None:
        if ',' in a.GROUPS:
            searchParams = string.split(a.GROUPS, ',')
        else:
            searchParams = a.GROUPS
        ldapsearch = 'ldapsearch -D cn=root,ou=ldap,o=redbrick -y /etc/ldap.secret -xLLL '
        if isinstance(searchParams, str):
            ldapsearch += '"(objectClass='+searchParams+')" uid cn altmail'
        else:
            ldapsearch += '"(|'
            for i in searchParams:
                ldapsearch += '(objectClass='+ i +')'
            ldapsearch += ')" uid cn altmail'

        ldif = os.popen(ldapsearch).read()
        mailgroup(ldif, '','','','',a.PRINT)
        exit()

    if a.MSG != None:
        with open(a.MSG, 'r') as content:
            a.MSG = content.read()

    if a.GROUPS == None and a.FROM != None and a.TO != None and a.SUBJECT != None and a.MSG != None and a.PRINT == False:
        sendmail(a.FROM, a.TO, a.SUBJECT, a.MSG, a.CC)

if __name__ == '__main__':
    main()

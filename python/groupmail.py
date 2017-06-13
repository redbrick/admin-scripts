#!/usr/bin/python3

"""
-maK
This is a script to send a mail to a group
defined by an ldap search
or simply send a singular mail

use ./groupmail -h
"""
import smtplib
import argparse
import os

def sendmail(frm, to_email, subject, body, cc_email=''):
    """ Send email"""
    msg = '\r\n'
    msg.join(('From: %s' % frm,
              'To: %s' % to_email,
              'CC: %s' % cc_email,
              'Subject: %s' % subject,
              '',
              '%s' % body))
    try:
        smtp = smtplib.SMTP('mailhost.redbrick.dcu.ie')
        smtp.sendmail(frm, to_email, msg)
        smtp.quit()
    except smtp.SMTPRecipientsRefused:
        print('Error sending mail to ' + to_email)
    except smtp.SMTPHeloError:
        print('The server didn’t reply properly to the HELO greeting.')
    except smtp.SMTPSenderRefused:
        print('The server didn’t accept the from address')
    except smtp.SMTPDataError:
        print('The server replied with an unexpected error code')
    except smtp.SMTPNotSupportedError:
        print('utf8 not supported by server')

def mailgroup(ldif, frm, subject, body, prnt):
    """ email groups"""
    to_mail = ldif.split('dn: uid=')
    ldap_cn = ''
    altmail = ''
    uid = ''
    for j in range(1, len(to_mail)):
        credentials = to_mail[j].split('\n')
        for i in credentials:
            if i.startswith('uid: '):
                uid = i.split()[1]
            if i.startswith('cn: '):
                ldap_cn = i.split('cn: ')[1]
            if i.startswith('altmail: '):
                altmail = i.split()[1]
        if prnt:
            print(uid + ' - ' + ldap_cn + ' : ' + altmail)
        else:
            # Send mail to each
            print('Send mail to ' + ldap_cn + ' using ' + altmail + ' (y|n)?')
            send = input('default(y): ')
            if(send == 'n') or (send == 'N'):
                print('Mail not sent to ' + ldap_cn + ' using ' + altmail + '\n')
            else:
                sendmail(frm, altmail.strip(), subject, body)
                print('Mail sent to ' + ldap_cn + ' using ' + altmail + '\n')

def check_args(args):
    """check args for sending"""
    if(args.GROUPS is None and args.FROM is not None and args.TO is not None and
       args.SUBJECT is not None and args.MSG is not None):
        return not args.PRINT
    return False

def main():
    """Main method"""
    parser = argparse.ArgumentParser(description='Used to mail an ldap group/groups')
    parser.add_argument('-g', dest='GROUPS', type=str,
                        help='Specify groups or singular group.\
                                (eg. club or club,society,founders,redbrick)')
    parser.add_argument('-p', dest='PRINT', action='store_true',
                        help='Only print details - Do not send')
    parser.add_argument('-f', dest='FROM', type=str, help='Who the mail is from.')
    parser.add_argument('-cc', dest='CC', type=str, help='cc all mails to.')
    parser.add_argument('-m', dest='MSG', type=str,
                        help='Location of Message to be sent (text file etc)')
    parser.add_argument('-t', dest='TO', type=str, help='Who singular mail is To.')
    parser.add_argument('-s', dest='SUBJECT', type=str, help='Subject of mail.')
    args = parser.parse_args()

    if args.GROUPS is not None:
        if ',' in args.GROUPS:
            search_params = args.GROUPS.split(',')
        else:
            search_params = args.GROUPS
        ldapsearch = 'ldapsearch -D cn=root,ou=ldap,o=redbrick -y /etc/ldap.secret -xLLL '
        if isinstance(search_params, str):
            ldapsearch += '"(objectClass=' + search_params + ')" uid cn altmail'
        else:
            ldapsearch += '"(|'
            for i in search_params:
                ldapsearch += '(objectClass=' + i + ')'
            ldapsearch += ')" uid cn altmail'

        ldif = os.popen(ldapsearch).read()
        if args.FROM is not None and args.SUBJECT is not None and args.MSG is not None:
            mailgroup(ldif, args.FROM, args.SUBJECT, args.MSG, args.PRINT)
        else:
            mailgroup(ldif, '', '', '', args.PRINT)
        exit()

    if args.MSG is not None:
        with open(args.MSG, 'r') as content:
            args.MSG = content.read()

    if check_args(args):
        sendmail(args.FROM, args.TO, args.SUBJECT, args.MSG, args.CC)

if __name__ == '__main__':
    main()

#!/usr/bin/python
import string, os, sys
import subprocess

def getCourses(db):
    result = ''
    p = subprocess.Popen('./rbsearch -uid '+str(db)+' | grep yearsPaid', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    p.daemon=True
    for line in p.stdout.readlines():
        result += line
	retval = p.wait()

    if '1' in result:
	return False
    else:
	return True

#start processing input
filenameGiven = True
try:
    filename = sys.argv[1]
except IndexError,e:
    print 'Usage: not_a_user_db.py <filename>'
    filenameGiven = False

#check if filename of input has been given
if(filenameGiven):
	f = open(filename)
	lines = [line.strip() for line in open(filename)]
	f.close()

	for l in lines:
		if(getCourses(l)):
			print l




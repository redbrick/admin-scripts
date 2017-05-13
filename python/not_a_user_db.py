#!/usr/bin/python3
"""Check if db is owned by a user"""
import sys
import subprocess

def get_courses(db_name):
    """Get users course"""
    result = ''
    proc = subprocess.Popen('../bash/rbsearch -uid ' + str(db_name) + ' | grep yearsPaid',
                            shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    proc.daemon = True
    for line in proc.stdout.readlines():
        result += line
        proc.wait()

    if '1' in result:
        return False
    return True

# start processing input
if sys.argv[1]:
    try:
        FILENAME = sys.argv[1]
        FILE = open(FILENAME)
        LINES = [line.strip() for line in FILE]
        FILE.close()
        for l in LINES:
            if get_courses(l):
                print(l)
    except IndexError as err:
        print('Usage: not_a_user_db.py <filename>')
else:
    print('Usage: not_a_user_db.py <filename>')

#!/usr/bin/env python
""" generate new years ldif"""
import sys

for i in sys.stdin:
    i = i.rstrip()
    if i.startswith("yearsPaid:"):
        print("yearsPaid:", int(i.split()[1]) - 1)
    elif i.startswith("newbie:"):
        print("newbie: FALSE")
    else:
        print(i)

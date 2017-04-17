#!/bin/bash

# Updates the pkgsrc ports tree.
# werdz@redbrick.dcu.ie, 18/11/09

export HTTP_PROXY=http://proxy.dcu.ie:8080
export CVS_RSH=ssh
export PATH=/usr/pkg/bin:/usr/pkg/sbin:$PATH

cd /usr/pkgsrc
tsocks cvs update -dP

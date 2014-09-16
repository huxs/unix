#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Sort the output of ls -li by inode, filename or date of last mod
# depending on switches

# Check nof args
if [ $# -ne 1 ] ; then echo "Usage: $0 -i|-f|-d" ; exit 1; fi

case $1 in 
    -i) SORT_ARGS="-k 1 -n"
	;;
    -f) SORT_ARGS="-k 9 -i" # Ignore non-printing characters
	;;
    -d) SORT_ARGS="-k 7,8"
	;;
    *)  echo "$0: Undefined switch $1"
	exit 1
	;;
esac  

ls -li | sort $SORT_ARGS

# Just parse the output of ls -li and decide which field to sort
# on. Note that we get the date by sorting on first the date and then
# the time. (We cheat and do it alphabetically, but that works here).

# Sample output from ls -li
#total 24
#36684109 -rwxr-xr-x 1 sax sax  814 2007-09-08 18:16 large-small.sh
#36684111 -rwxr-xr-x 1 sax sax 1164 2007-09-08 18:21 size.sh
#36684113 -rwxr-xr-x 1 sax sax 1153 2007-09-08 18:58 clean.sh
#36684105 -rwxr-xr-x 1 sax sax  814 2007-09-08 19:00 sort-ls.sh~
#36684114 -rw-r--r-- 1 sax sax  633 2007-09-08 19:07 Assignments.txt
#36684112 -rwxr-xr-x 1 sax sax  971 2007-09-08 19:09 sort-ls.sh

# Also note that ls can sort by itself on a number of fields including
# various times.


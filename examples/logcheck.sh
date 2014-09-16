#! /bin/sh 
# (C) Stefan Axelsson 2007-09-10
# Periodically check if a user is logged on. Output a note to stdout
# if (s)he is.

# Need two args, interval and username
if [ $# -lt 2 ] ; then echo "Usage: $0 interval username" ; exit 1; fi

INTERVAL=$1
USERNAME=$2

while true
do
    if who | grep $USERNAME > /dev/null # Only interested if there is a match
    then
	echo "$USERNAME is logged on"
    fi
    sleep $INTERVAL
done

# Note that the exit status of a pipeline is the exit status of the
# last command, in our case 'grep' which is what we want. Grep returns
# true if there was a match and false otherwise.

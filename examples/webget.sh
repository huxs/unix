#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Fetch a webpage, output it followed by the transfer rate

# Check nof args
if [ $# -ne 1 ] ; then echo "Usage: $0 URI" ; exit 1; fi

TEMPOUT=`mktemp`

# Get the file and remember how long it took (wget already reports
# this but we'll do it the hard way for practice.

TIME=`/usr/bin/time -p wget -q -O $TEMPOUT $1 2>&1 | head -1|awk '{print$2}'`

# OK, how big is it? (Field '5' is the size in bytes)
SIZE=`ls -l $TEMPOUT |awk '{print $5}'`

# Check that the size isn't zero
if [ $SIZE -eq 0 ]
then
    echo "$0: ERROR, couldn't get the file, or empty file"
    exit 1
fi

if [ $TIME = "0.00" ] # Note string comparison 'test' doesn't do floats
then
    echo "$0: Hmm, command didn't take any time... Aborting"
    exit 1
fi

# What's the bytes/sec? (Note we can't use expr since time might be
# float) Note also that we quote ';' as we want to send that to bc,
# not have the shell interpret it
BPS=`echo scale=0';'$SIZE/$TIME | bc -l`

# Print the file and the bps value
cat $TEMPOUT 
echo $BPS "Bytes per second"

# Clean up
rm -f $TEMPOUT

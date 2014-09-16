#! /bin/sh 
# (C) Stefan Axelsson 2007-09-10
# Emulate 'tripwire'

# Need two args, logfile and starting directory
if [ $# -lt 2 ] ; then echo "Usage: $0 logfile directory" ; exit 1; fi

LOG=$1
DIR=$2

# Do the current checksums
CLOG=`mktemp`
find . -type f -name '*' -exec md5sum '{}' \; | sort > $CLOG

# Sort it... 
#TEMP=`mktemp`
#sort < $CLOG > $TEMP
#mv $TEMP $CLOG

# Compare against last run. Comm is the ticket here... It compares two
# sorted files and outputs all differences. -3 means to suppress
# output of lines that are similar in both files.

if [ -f $LOG ] # If LOG doesn't exist yet then there's nothing to compare to
then 
    comm -3 $LOG $CLOG
fi

mv $CLOG $LOG

# Note that this doesn't solve the first lab as it doesn't tell the
# users what the differences ARE. It just prints the differences...
# Also it doesn't really handle directories or other special files
# very well.

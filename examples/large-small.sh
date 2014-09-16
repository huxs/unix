#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Find the smallest and largest file below a directory that is given
# as a parameter

# Check nof args
if [ $# -ne 1 ] ; then echo "Usage: $0 directory-name" ; exit 1; fi

TEMPFILE=`mktemp`
find $1 -maxdepth 3 -printf '%k\t%p\n' | sort -n > $TEMPFILE

# Print the smallest and the largest file, note that only one file is
# printed even if there are more with the same size
head -1 $TEMPFILE | cut -f 2  # Field no two is the filename 
tail -1 $TEMPFILE | cut -f 2

# Clean up
rm -f $TEMPFILE

# OK, there could be some more error checking. Note that we need to
# use a temporary file as we're going to call both head and tail on
# it. We could get around that by using awk or something similar, but
# that wouldn't quite be in the spirit of shell script programming.

#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Sum the size of all files below a directory

# Check nof args
if [ $# -ne 1 ] ; then echo "Usage: $0 directory-name" ; exit 1; fi

TEMPFILE=`mktemp`
# -type f: just sum the regular files, not directories etc.
find $1 -maxdepth 1 -type f -printf '%s\n' > $TEMPFILE
while read SIZE
do
    SUM=`expr ${SUM-0} + $SIZE` 
done < $TEMPFILE 
echo $SUM
rm -f $TEMPFILE

# Note a few tricks, 'read' reads from standard input and we've
# redirected stdin from the tempfile to the while loop. In order not
# to have a problem with SUM being undefined we use the ${SUM-0} which
# means to assume '0' if SUM is undefined ( ${SUM=0} would also have
# defined SUM, but that's done by the assignment here anyway. 

# If we do it in a pipeline like this then all the parts are executed
# in a subshel, and hence can't pass on their environments, which
# means that you can't just read $SUM at the end after done as it's
# gone out of scope then. So we have to echo each one and print the
# last.

#find $1 -maxdepth 1 -type f -printf '%s\n' | \
#while read SIZE
#do
#    SUM=`expr ${SUM-0} + ${SIZE-0}` 
#    echo $SUM
#done | tail -1

#! /bin/sh 
# (C) Stefan Axelsson 2007-09-09
# Replace all words in a file to a given word
if [ $# -lt 3 ] ; then echo "Usage: $0 oldword newword filename" ; exit 1; fi

OLD=$1
NEW=$2
FILE=$3

TEMP=`mktemp`

# What is a word? Should we add whitespace or rely on the user doing that?
# (g)lobal flag to change all occurrences (i.e. match many times on a line)
sed "s/$OLD/$NEW/g" $FILE > $TEMP
mv $TEMP $FILE

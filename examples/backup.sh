#! /bin/sh 
# (C) Stefan Axelsson 2007-09-09
# Copy all the files in a directory to the same directory (or another
# directory, given as an argument) but add the extension .BACKUP to
# them

# Check nof args if one there is one directory (SOURCEDIR=TARGETDIR)
# and if there is two there is another directory, TARGETDIR=$2
if [ $# -lt 1 ] ; then echo "Usage: $0 sourcedir [targetdir]" ; exit 1; fi

SOURCEDIR=$1
TARGETDIR=${1:-$SOURCEDIR} # If set TARGET=SOURCE if user hasn't given TARGET

for file in $SOURCEDIR/*
do
    echo cp "$file" "$TARGETDIR/`basename "$file"`.BACKUP"
done

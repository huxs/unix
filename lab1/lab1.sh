#!/bin/sh

# Variables

latetime=0
hours=0
days=20

# Return the timestamp.
getTimestamp()
{   
    temp=`echo $1 | cut -d "[" -f 2 | sed 's/\// /g' | sed 's/:/ /'`
    date -d"$temp" +%s 
}

# -c
PrintMostUsedAddress()
{
    awk '{print $1}' < $2 | uniq -c | sort -n -r | head -$1 | awk '{print $2,$1}'
}

# -2
#awk '{print $1, $9}' < $1 | grep -E '{1}\ 200' | uniq -c | sort -n | tail -1 | awk '{print $2,$1}'
PrintMostSuccessfulAddress()
{
    OLDIFS=$IFS
    IFS=' '
    content=`awk '{print $1, $4, $9}' < $2`
    echo $content | 
    {
	while read ip date code ; do

	    time=`getTimestamp $date`
	    subr=`expr $latetime - $time`
	 
	    a=`expr $days \* 86400`
	    
#	    if [ $subr -lt $a ] ; then
#		echo "yeah!"
#	    fi
	    
	    if [ $code = "200" ] ; then
		result="$result $ip\n" 
	    fi

	done
	echo $result | uniq -c | sort -n -r | head -$1 | awk '{print $2, $1}'
    }
    IFS=$OLDIFS
}

# Parse flags.
count=1

while getopts "n:h:d:" flag ; do
    case $flag in
	n)
	    count=$OPTARG
	    ;;
	h)
	    if [ $OPTARG -lt 24 ] ; then
		hours = $OPTARG
	    else
		echo "Hours must be less then 24."
		exit 1
	    fi
	    ;;
	d)
	    days = $OPTARG;
	    ;;
	*)
	    echo "$flag" $OPTIND $OPTARG
	    ;;
    esac
done


# Get the filename.
shift `expr $OPTIND - 1`
echo $1;

# Get latest time from tail of file.
latetime=$(getTimestamp `tail -1 < $1 | awk '{print $4}'`)

PrintMostSuccessfulAddress $count $1

#while read line ; do
    
#    temp=`echo $line | awk '{print $4}' | cut -d "[" -f 2 | sed 's/\// /g' | sed '0,/:/{s/:/ /}'`
#    timestamp=`

#    if [ $timestamp -lt 9999999999999 ] ; then
#	a="$a $line\n"
###    fi
#done < $1


##awk '{print $4}' < $1

#date --date='06/12/2012 07:21:22' +"%s"


#!/bin/sh

# Variables
timeLimit=0
timeLimitHours=0
timeLimitDays=0
count=999999999

# Include scripts.
dir=$(dirname "$0")
. $dir/lab1_c.sh
. $dir/lab1_2.sh
. $dir/lab1_r.sh
. $dir/lab1_f.sh
. $dir/lab1_t.sh


# Converts one row to unix timestamp.
timestamp()
{
    time=$(echo "$1" | awk '{print $4}')
    temp=$(echo $time | cut -d "[" -f 2 | sed 's/\// /g' | sed 's/:/ /')
    date -d"$temp" +%s
}

# Parse paramerters.
while getopts "n:h:d:c2rFt" flag ; do
    case $flag in
	n)
	    count=$OPTARG
	    ;;
	h)
	    if [ $OPTARG -lt 24 ] ; then
		timeLimitHours=$OPTARG
	    else
		echo "Hours must be less then 24."
		exit 1
	    fi
	    ;;
	d)
	    timeLimitDays=$OPTARG;
	    ;;
	c)
	    query="c"
	    ;;
	2)
	    query="2"
	    ;;
	r)
	    query="r"
	    ;;
	F)
	    query="F"
	    ;;
	t)
	    query="t"
	    ;;
	*)
	    echo "$flag" $OPTIND $OPTARG
	    exit 1
	    ;;
	
    esac
done

# Get the infile.
shift $(expr $OPTIND - 1)
if [ "$1" = "-" -o "$1" = "" ] ; then
    in=/dev/stdin
else
    in=$1
fi

echo "Parsing File .. $in";

content=$(cat $in)

if [ "$?" != "0" ]; then
    echo "Failed to read infile" 1>&2
    exit 1
fi

# Check if we have time limit set.
if [ $timeLimitDays -gt 0 -o $timeLimitHours -gt 0 ] ; then

    # Fetch the last row of the file.
    lastline=$(echo "$content" | tail -1)

    # Convert the date to timestamp.
    timeLimit=$(timestamp "$lastline")

    # Subtract the values from limit.
    timeLimit=$(expr $timeLimit - $timeLimitDays \* 24 \* 60 \* 60)
    timeLimit=$(expr $timeLimit - $timeLimitHours \* 60 \* 60)

    OLDIFS=$IFS
    IFS='
'
    # Make a new subset of rows from log (THIS TAKES TIME.)
    for line in $content ; do

	rowTimeStamp=$(timestamp "$line")
	
	if [ $rowTimeStamp -ge $timeLimit ] ; then
	    result="$result$line\n"
	fi

    done

    IFS=$OLDIFS
    
    # Remove last newline.
    result="${result%\n}"    
else
    result=$content
fi    
    


# Execute selected query.
case $query in
    c)
        lab1_c "$count" "$result"
	;;
    2)
	lab1_2 "$count" "$result"
	;;
    r)
	lab1_r "$count" "$result"
	;;
    F)
	lab1_F "$count" "$result"
	;;
    t)
	lab1_t "$count" "$result"
	;;
    *)
	echo "Invalid query. [Use c, 2, r, F, t]"
	exit 1
	;;
esac

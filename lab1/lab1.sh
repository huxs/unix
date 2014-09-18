#!/bin/bash

# Variables
timeLimit=0
timeLimitHours=0
timeLimitDays=0

# Declare associative array of months
declare -A MONTHS
MONTHS=( ["Jan"]=01 ["Feb"]=02 ["Mar"]=03 ["Apr"]=04 ["May"]=05 ["Jun"]=06 ["Jul"]=07 ["Aug"]=08 ["Sep"]=09 ["Oct"]=10 ["Nov"]=11 ["Dec"]=12)

# Converts one row to unix timestamp
timestamp()
{
    time=$(echo $1 | awk '{print $4}')
    day=${time:1:2}
    month=${MONTHS[${time:4:3}]}
    year=${time:8:4}
    hour=${time:13:2}
    minute=${time:16:2}
    second=${time:19:2}
#    echo "$day .. $month .. $year .. $hour .. $minute .. $second "
    date --date="$year$month$day $hour:$minute:$second" +%s
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

	    if [ $code = "200" ] ; then
		result="$result $ip\n" 
	    fi

	done
	echo $result | uniq -c | sort -n -r | head -$1 | awk '{print $2, $1}'
    }
    IFS=$OLDIFS
}


count=1

# Parse paramerters.
while getopts "n:h:d:" flag ; do
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
	*)
	    echo "$flag" $OPTIND $OPTARG
	    ;;
    esac
done

# Get the filename.
shift $(expr $OPTIND - 1)
echo "Parsing File .. $1";

# Check if we have time limit set.
if [ $timeLimitDays -gt 0 -o $timeLimitHours -gt 0 ] ; then

    # Fetch the last row of the file.
    lastline=`tail -1 <$1`

    # Convert the date to timestamp.
    timeLimit=$(timestamp "$lastline")

    # Subtract the values from limit.
    timeLimit=`expr $timeLimit - $timeLimitDays \* 24 \* 60 \* 60`
    timeLimit=`expr $timeLimit - $timeLimitHours \* 60 \* 60`

    echo $timeLimit

    #Make a new subset of rows from log (THIS TAKES TIME.)
    while read line ; do
        rowTimeStamp=$(timestamp "$line")
		
	if [ $rowTimeStamp -ge $timeLimit ] ; then
	    result+="$line\n"
	fi
    done < $1
    
    # Print result.
    echo -e $result
fi

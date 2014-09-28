#! /bin/sh

# Which address makes the most number of successful attempts?
lab1_2()
{
    OLDIFS=$IFS
    IFS=' '

    # Awk out the columns needed for the query in this case the ip and status code.
    content=$(echo "$2" | awk '{print $1, $9}')

    echo $content | 
    {
	while read -r ip code ; do

	    # If the code is equal to 200 append it ot the list of successful ips.
	    if [ "$code" -eq "200" ] ; then
		ips="$ips$ip\n" 
	    fi

	done

	echo "$ips" | grep . | uniq -c | sort -n -r | head -$1 | awk '{print $2, $1}'
    }

    IFS=$OLDIFS
}

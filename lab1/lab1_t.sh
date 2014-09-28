#! /bin/sh

# Which IP number get the most bytes sent to them?
lab1_t()
{
    OLDIFS=$IFS
    IFS=' '

    # Awk out the columns needed for the query in this case the ip and and the bytes sent.
    content=$(echo "$2" | awk '{print $1, $10}')

    echo $content | 
    {
	while read -r ip bytes ; do
	    
	    # If the bytes sent isnt maked as - append the ip and the bytes.
	    if [ "$bytes" != "-" ] ; then
		tips="$tips$bytes|$ip\n" 
	    fi

	done

	echo "$tips" | grep . | sort -n -t "|" -r | tr "|" " " | head -$1 | awk '{print $1,$2}'
    }

    IFS=$OLDIFS
}


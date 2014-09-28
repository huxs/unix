#! /bin/sh

# What are the most common results codes and where do they come from?
lab1_r()
{
    OLDIFS=$IFS
    IFS=' '

    # Awk out the columns needed for the query in this case the status code and the ip.
    content=$(echo "$2" | awk '{print $9, $1}')
    
    # Get a list of codes sorted by their occurrence.
    codes=$(echo "$2" | awk '{print $9}' | sort -n | uniq -c | sort -n -r | awk '{print $2}') 

    echo $content | 
    {
	# Loop through each line of the file.
	while read -r code ip ; do	    
	    IFS='
'	    
	    c=0
	    # Loop through each code in the list of codes.
	    for i in $codes ; do

		# If the code in the file matches the code in the list of codes.
		# Append the rank of the code, the ip and the code.
		if [ "$code" -eq "$i" ] ; then
		    rips="$rips$c $ip $code\n" 
		fi
		c=$(expr $c + 1)
	    done
	    IFS=' '
	done

	# Sort the appended list and print the status code and ip.
	echo $rips | grep . | sort -n | uniq | head -$1 | awk '{print $3, $2}'

	
    }

    IFS=$OLDIFS
}

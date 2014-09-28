#!/bin/sh

# Which IP address makes the most number of connection attempts?
lab1_c()
{
    echo "$2" | awk '{print $1}' | uniq -c | sort -n -r | head -$1 | awk '{print $2,$1}'
}


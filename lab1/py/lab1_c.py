#! /usr/bin/python

import operator

# Which IP address makes the most number of connection attempts?
def lab1_c(count, data):
    ips = dict()
    for row in data:
        ip = row.split()[0]
        if ip in ips:
            ips[ip] += 1
        else:
            ips[ip] = 1
    
    sortedIps = sorted(ips.items(), key=operator.itemgetter(1), reverse=True)

    c = 0
    for k,v in sortedIps:
        if c < count:
            print(str(k) + " " + str(v))
            c += 1
        else:
            break
        
            
    

      
    


#! /usr/bin/python

import operator

def lab1_2(count, data):
    ips = dict()
    
    for row in data:
        row = row.split()
        ip = row[0]
        code = row[8]
        if code == "200":
            if ip in ips:
                ips[ip] += 1
            else:
                ips[ip] = 1

    sortedIps = sorted(ips.items(), key=operator.itemgetter(1), reverse=True)

    c = 0
    for k,v in sortedIps:
        if c < count:
            print(str(v) + " " + str(k))
            c += 1
        else:
            break

    
    

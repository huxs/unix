#! /usr/bin/python

import operator

# Which IP number get the most bytes sent to them?
def lab1_t(count, data):

    result = []
    for row in data:
        row = row.split()
        ip = row[0]
        b = row[9]

        if b != "-":
            result.append(b + " " + ip)
        
    result.sort(key=lambda l: int(l.split()[0]), reverse=True) 

    c = 0
    for v in result:
        if c < count:
            parts = v.split();
            print(parts[0] + " " + parts[1])
            c += 1
        else:
            break
    

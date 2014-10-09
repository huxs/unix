#! /usr/bin/python

import operator
import re

# What are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?
def lab1_F(count, data):

    codes = dict()
    for row in data:
        code = row.split()[8]
        regexp = re.findall(r'\b(4[0-9]{2})+', code)
        if len(regexp) > 0:
            if code in codes:
                codes[code] += 1
            else:
                codes[code] = 1

    sortedCodes = sorted(codes.items(), key=operator.itemgetter(1))

    exist = dict()
    result = []
    for row in data:
        row = row.split()
        ip = row[0]
        code = row[8]

        n = 0
        for k,v in sortedCodes:
            if code == k:
                if ip not in exist:
                    exist[ip] = 1
                    result.append(str(n) + " " + code + " " + ip)

            n += 1

    result.sort(key=lambda l: int(l.split()[0]), reverse=True) 

    c = 0
    for v in result:
        if c < count:
            parts = v.split();
            print(parts[1] + " " + parts[2])
            c += 1
        else:
            break
    

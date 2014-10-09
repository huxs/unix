#! /usr/bin/python

import sys
import getopt
import time
import datetime

# Variables
timeLimit=0
timeLimitHours=0
timeLimitDays=0
query=0

# Include scripts.
from lab1_c import lab1_c
from lab1_2 import lab1_2
from lab1_r import lab1_r

# Converts one row to unix timestamp.
def timestamp(row):
    t = row.split()[3]
    temp = t.replace(t[:1], '')
    return time.mktime(datetime.datetime.strptime(temp, "%d/%b/%Y:%X").timetuple())

# Parse paramerters.
try:
    opts, args = getopt.getopt(sys.argv[1:], ":n:|:h:d:|:c2rFt")
except getopt.GetoptError as e:
    print(e)
    sys.exit(2)

for opt, arg in opts:
    if opt == "-n":
        count = int(arg)
    elif opt in ("-h", "-d"):
        if opt == "-h":
            timeLimitHours = int(arg)
        elif opt == "-d":
            timeLimitDays = int(arg)
    elif opt in ("-c", "-2", "-r", "-F", "-t"):
        if opt == "-c":
            query = "c"
        elif opt == "-2":
            query = "2"
        elif opt == "-r":
            query = "r"
        elif opt == "-F":
            query = "F"
        elif opt == "-t":
            query = "t"
    else:
        assert False, "Unhandled option."

filename = sys.argv[-1];
print("Parsing File .. " + filename)

content = open(filename, 'r')

data = []
if (timeLimitHours > 0 or timeLimitDays > 0):
    
    # Fetch last row of the file.
    for line in content:
        pass
    lastline = line    

    # Convert the date to timestamp.
    timeLimit = timestamp(lastline)

    # Calculate the timelimit.
    timeLimit = timeLimit - timeLimitDays * 24 * 60 * 60
    timeLimit = timeLimit - timeLimitHours * 60 * 60
    print(timeLimit)

    content.seek(0, 0)
    # Make new subset of rows from the log.
    for line in content:
        rowTimestamp = timestamp(line)

        if rowTimestamp > timeLimit:
            data.append(line)
else:
    data = content.readlines()

# Execute selected query.    
if query == "c":
    lab1_c(count, data)
elif query == "2":
    lab1_2(count, data)
elif query == "r":
    lab1_r(count, data)
elif query == "F":
    lab1_F(count, data)
elif query == "t":
    lab1_t(count, data)
else:
    assert False, "Inavlid query [Use c, 2, r, F, t]"

    


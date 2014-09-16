#! /bin/sh 
# (C) Stefan Axelsson 2007-09-08
# Monitor the running processes and output a list of the users

ps aux | grep -v '^USER' | awk '{print $1}' | sort | uniq

# Instead of awk one could use cut, but output is not tab delimeted,
# one could fix that with -d but I couldn't be bothered.

# grep -v outputs all lines *but* those that match the pattern

# ps aux output:
#USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
#root         1  0.0  0.0   2908   524 ?        Ss   Aug13   0:01 /sbin/init
#root         2  0.0  0.0      0     0 ?        S    Aug13   0:00 [migration/0]
#root         3  0.0  0.0      0     0 ?        SN   Aug13   0:01 [ksoftirqd/0]
#root         4  0.0  0.0      0     0 ?        S    Aug13   0:00 [watchdog/0]
#root         5  0.0  0.0      0     0 ?        S<   Aug13   0:00 [events/0]
#root         6  0.0  0.0      0     0 ?        S<   Aug13   0:00 [khelper]

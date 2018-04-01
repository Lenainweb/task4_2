#!/bin/bash

# Checks if the ntp process is running. If the process is not running, it starts it.
# Checks if the configuration file ntp.conf is changed. If there are any changes, 
# it outputs them to stdout. Returns the configuration file to the correct state 
# and restarts the NTP service.

if ! [ "$( ntpq -p )" ] ; then
    echo "NOTICE: ntp is not running" 
    sudo service ntp start 
fi
 
if ! [ -f /etc/ntp.conf ] ; then 
    echo "Error: ntp_verify: no file '/etc/ntp.conf'" >&2
    exit 1
fi

if ! [ -f /etc/ntp.conf.bak ] ; then 
    echo "NOTICE: No file no file '/etc/ntp.conf.bak'"  
    cat /etc/ntp.conf.bak > /etc/ntp.conf
fi

if [ "$( diff -q /etc/ntp.conf.bak /etc/ntp.conf )" ] ; then
    echo "NOTICE: /etc/ntp.conf was changed. Calculated diff:"
    
    echo "$( diff -u -B /etc/ntp.conf.bak /etc/ntp.conf)"

    cat /etc/ntp.conf.bak > /etc/ntp.conf
    sudo service ntp restart
fi

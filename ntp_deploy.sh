#!/bin/bash

# The script installs the package with the ntp server.
# Removes the default ntp server from the configuration file
# It is registered as ntp-server ua.pool.ntp.org.
# Restarts the ntp service.
# Registers at the beginning of the script ntp_verify.sh once every 1 minute.

chmod +x ntp_verify.sh

way=$(pwd)


# Checks if the package is installed, if it is not installed, it installs
list_dpkg=$( dpkg --get-selections | grep 'ntp' | grep -m 1 'ntp' | awk '{print $2}' )
if [ -n "$list_dpkg" ] ; then
    if ! [[ "$list_dpkg" = "install" ]] ; then
        sudo apt-get -y install ntp
    fi
else
    sudo apt-get -y install ntp
fi


# Checks for the presence of a configuration file
if ! [ -f /etc/ntp.conf ] ;then 
    echo "Error: ntp_deploy: There is no /etc/ntp.conf file" >&2 
    exit 1
fi

# Replaces the required lines in the configuration file
( sed '/pool 0/ c\pool 0.ua.pool.ntp.org' /etc/ntp.conf ) > temp.txt
( sed '/pool 1/ c\pool 1.ua.pool.ntp.org' temp.txt ) > /etc/ntp.conf.bak
( sed '/pool 2/ c\pool 2.ua.pool.ntp.org' /etc/ntp.conf.bak ) > temp.txt
( sed '/pool 3/ c\pool 3.ua.pool.ntp.org' temp.txt ) > /etc/ntp.conf.bak
( sed '/pool ntp/ c\pool ua.pool.ntp.org' /etc/ntp.conf.bak ) > temp.txt
cat temp.txt > /etc/ntp.conf.bak
rm -f temp.txt

cat /etc/ntp.conf.bak > /etc/ntp.conf

# Restarts the ntp service.
sudo service ntp restart

sudo echo > /var/spool/cron/root
echo "*/1 * * * * $way/ntp_verify.sh" >> /var/spool/cron/root
echo >> /var/spool/cron/root

crontab -u root /var/spool/cron/root

service cron reload

if [ -f ntp_verify.sh ] ; then
    exit 0
else
    echo "ntp_deploy.sh: No ntp_verify.sh file" >&2
    exit 2
fi
exit 3

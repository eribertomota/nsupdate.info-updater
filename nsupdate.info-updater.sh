#!/bin/bash

# Copyright 2015-2017 Joao Eriberto Mota Filho <eriberto@eriberto.pro.br>
# You can use this script under BSD-3-clause conditions.

# nsupdate.info is a free and open dynamic DNS (DDNS) service, available
# at https://www.nsupdate.info/
#
# nsupdate.info-updater is used to update IP addresses in nsupdate.info.
# nsupdate.info system does not like to receive several conections in a
# short time. As an example, a cron task to send your current IP to the
# site every 4 hours will block your account and you will need to access
# the system to unblock.
#
# nsupdate.info-updater verify if the IP address was changed before send
# it to the system, avoiding a block action from the system.

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

NSUCONF=/etc/nsupdate.info-updater.conf
NSUIPREAL=""
NSUMSG=""
NSUNAME="nsupdate.info-updater"
NSUTEST=""
NSUVER="0.1"

#################
# Verifications #
#################

# Check if conf file exist
NSUTEST=$(ls $NSUCONF 2> /dev/null)
NSUMSG="\nFile $NSUCONF not found.\n"

[ "$NSUTEST" ] || { echo $NSUNAME $NSUVER; echo -e $NSUMSG; exit 1; }

# Load the conf file
source $NSUCONF

# Check if NSULOGIN exist and is not null
NSUTEST=$(echo $NSULOGIN)
NSUMSG="\nThe variable NSULOGIN is empty or not found.\nPlease, fix it in $NSUCONF\n"

[ "$NSUTEST" ] || { echo $NSUNAME $NSUVER; echo -e $NSUMSG; exit 1; }

# Check if NSULOGIN is using the default template
NSUTEST=$(echo $NSULOGIN | egrep \(your_login\|your_password\))
NSUMSG="\nThe $NSUNAME conf file is using the default values for login or password.\nPlease, edit $NSUCONF and change the NSULOGIN line.\n"

[ "$NSUTEST" ] && { echo $NSUNAME $NSUVER; echo -e $NSUMSG; exit 1; }

# Check if NSULASTIP exist and is not null
NSUTEST=$(echo $NSULASTIP)
NSUMSG="\nThe variable NSULASTIP is empty or not found.\nPlease, fix it in $NSUCONF\n"

[ "$NSUTEST" ] || { echo $NSUNAME $NSUVER; echo -e $NSUMSG; exit 1; }

# Check if dir for NSULASTIP exist
NSUTEST=$(echo $NSULASTIP | rev | cut -d"/" -f2- | rev)
NSUMSG="\nDirectory $NSUTEST/ not found. Please, create it.\n"

[ -d "$NSUTEST" ] || { echo $NSUNAME $NSUVER; echo -e $NSUMSG; exit 1; }

# Check for logger
NSUTEST=$(ls /usr/bin/logger)

[ "$NSUTEST" ] || { echo $NSUNAME $NSUVER; echo -e "logger command not found. You won't have logs"; }

#############
# Functions #
#############

function send_ip () {
    # Register the IP in nsupdate.info
    curl -s https://$NSULOGIN@ipv4.nsupdate.info/nic/update > /dev/null
    # Make log
    [ -x /usr/bin/logger ] && logger -t NSUPDATE -i "$NSUMSG"
    [ -x /usr/bin/logger ] && logger -t NSUPDATE -i "Sent the new IP address $NSUIPREAL to nsupdate.info."
    # Set last IP
    echo $NSUIPREAL > $NSULASTIP
    exit 0
}

function generic_error {
    [ -x /usr/bin/logger ] && logger -t NSUPDATE -i "$NSUMSG"
    exit 0
}

function options {
    echo -e "\n$NSUNAME $NSUVER\n"
    echo -e "-f   Force to send IP to nsupdate.info (be careful)"
    echo -e "-v   Show version\n"
    exit 0
}

###########
# PROGRAM #
###########

# Options

[ "$1" = "-v" ] && { echo -e "\n$NSUNAME $NSUVER\n"; exit 0; }
[ "$1" = "-f" ] && { NSUMSG="Forced update done."; send_ip; exit 0; }
[ "$1" ] && { options; exit 0; }


# Get current IP and exit, if no results

NSUIPREAL=$(dig +short myip.opendns.com @resolver1.opendns.com)

[ ! "$NSUIPREAL" ] && { NSUMSG="ERROR. The search for an external IP returned an empty result."; generic_error; }


# Exit if there are errors

NSUTEST=$(echo $NSUIPREAL | grep [a-z])

[ "$NSUTEST" ] && { NSUMSG="ERROR. The message is: $NSUIPREAL."; generic_error; }


# Send the IP to nsupdate.info if no have NSULASTIP or if the IP changes

[ ! -e "$NSULASTIP" ] && { NSUMSG="Initial information about this host."; send_ip; }

NSULASTIPVAR=$(cat $NSULASTIP)

[ "$NSUIPREAL" != "$NSULASTIPVAR" ] && { NSUMSG="Changed the IP address from $NSULASTIPVAR to $NSUIPREAL."; send_ip; }


# No changes (not an error)

NSUMSG="No changes. Exiting."; generic_error

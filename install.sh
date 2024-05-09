#!/bin/bash -
#===============================================================================
#
#          FILE: install.sh
#
#         USAGE: ./install.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/09/2024 10:06:30 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

sudo mv timeshift-static /usr/local/bin/timeshif
sudo chmod +x /usr/local/bin/timeshiftt

sudo mkdir /etc/timeshift
sudo mv default.json /etc/timeshift/

# save to the root partition (modify this if you don't want this)
DEV=$(df / | awk '{print $1}' | tail -n +2)

sudo timeshift --create --comments "First Snapshot" --snapshot-device "$DEV"

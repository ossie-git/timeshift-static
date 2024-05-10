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

# Fedora Requirement
RELEASE=$(cat /etc/*release | grep "^ID=" | cut -d "=" -f 2)
if [ "$RELEASE" = "fedora" ]; then
  sudo dnf install -y crontabs
fi

wget https://github.com/ossie-git/timeshift-static/raw/main/timeshift-static
wget https://raw.githubusercontent.com/ossie-git/timeshift-static/main/default.json
sudo mv timeshift-static /usr/local/bin/timeshift
sudo chmod +x /usr/local/bin/timeshift

sudo mkdir /etc/timeshift
sudo mv default.json /etc/timeshift/

# save to the root partition (modify this if you don't want this)
DEV=$(df / | awk '{print $1}' | tail -n +2)

sudo timeshift --create --comments "First Snapshot" --snapshot-device "$DEV"

# update /etc/timeshift/timeshift.json so that it starts taking scheduled snapshots
sudo sed -i 's/"schedule_monthly" : "false",/"schedule_monthly": "true",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"schedule_weekly" : "false",/"schedule_weekly": "true",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"schedule_daily" : "false",/"schedule_daily": "true",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"schedule_hourly" : "false",/"schedule_hourly": "true",/' /etc/timeshift/timeshift.json

sudo sed -i 's/"count_monthly" : "0",/"count_monthly": "3",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"count_weekly" : "0",/"count_weekly": "4",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"count_daily" : "0",/"count_daily": "7",/' /etc/timeshift/timeshift.json
sudo sed -i 's/"count_hourly" : "0",/"count_hourly": "10",/' /etc/timeshift/timeshift.json

# update /etc/timeshift/timeshift.json so that it excludes /root and /home
sudo sed -i 's,/home\/.*,/home/\*\*"\,,' /etc/timeshift/timeshift.json

# download timeshift-hourly
wget https://raw.githubusercontent.com/ossie-git/timeshift-static/main/timeshift-hourly
sudo mv timeshift-hourly /etc/cron.d/
sudo chmod 644 /etc/cron.d/timeshift-hourly
sudo chown root.root /etc/cron.d/timeshift-hourly

# restart crond
sudo systemctl restart crond

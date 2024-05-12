#!/bin/bash -
#===============================================================================
#
#          FILE: install.sh
#
#         USAGE: ./install.sh
#
#   DESCRIPTION: Install timeshift (static version)
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

# Get Distribution
RELEASE=$(cat /etc/*release | grep "^ID=" | cut -d "=" -f 2 | tr -d '"')

# RHEL is not supported as it requires first installing repos to install rsync
# Refer to https://snapcraft.io/install/rsync-leftyfb/rhel for more

case "$RELEASE" in
  fedora|rocky|centos)
    sudo yum install -y crontabs rsync
    ;;
  #*)
    # do ...
    # ;;
esac

#if [ "$RELEASE" = "fedora" ]; then
#  sudo dnf install -y crontabs
#fi

wget https://github.com/ossie-git/timeshift-static/raw/main/timeshift-static
wget https://raw.githubusercontent.com/ossie-git/timeshift-static/main/timeshift.json
sudo mv timeshift-static /usr/local/bin/timeshift
sudo chmod +x /usr/local/bin/timeshift

sudo mkdir /etc/timeshift
sudo mv timeshift.json /etc/timeshift/

# update our timeshift.json with the UUID of our root partition
UUID=`lsblk -no UUID $(df -P "/" | awk 'END{print $1}')`

if [ -z "${UUID}"  ]; then 
  echo "Could not extract UUID for root partition. Exiting"
  exit 1
fi

# update /etc/timeshift/timeshift.json so that it starts taking scheduled snapshots
sudo sed -i "s/\"backup_device_uuid\" : \"\"\,/\"backup_device_uuid\": \"$UUID\",/" /etc/timeshift/timeshift.json

sudo /usr/local/bin/timeshift --create --comments "First Snapshot"

# download timeshift-hourly
wget https://raw.githubusercontent.com/ossie-git/timeshift-static/main/timeshift-hourly
sudo mv timeshift-hourly /etc/cron.d/
sudo chmod 644 /etc/cron.d/timeshift-hourly
sudo chown root:root /etc/cron.d/timeshift-hourly

# fix SELinux label if SELinux is on the system
if [ -x "$(command -v restorecon)" ]; then
    sudo restorecon -R -v /etc/cron.d/timeshift-hourly
fi

# restart crond
case "$RELEASE" in
  fedora|rocky|centos)
    sudo systemctl stop crond
    sudo systemctl start crond
    ;;
  #*)
    # do ...
    # ;;
esac

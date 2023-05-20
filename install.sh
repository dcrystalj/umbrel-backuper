#!/bin/bash

set -euo pipefail

# read variables
VARIABLES_FILE=$(dirname "$0")/variables
source $VARIABLES_FILE

# check if running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# check if restic is installed
if ! command -v restic &> /dev/null
then
    echo "restic could not be found. Please install it first: https://restic.readthedocs.io/en/latest/020_installation.html"
    exit
fi

mkdir -p $INSTALL_DIR
mkdir -p $BACKUP_DIR
cp -a ./* $INSTALL_DIR
chown -R root:root $INSTALL_DIR

# init restic repository if does not exsists
snapshots=$(restic -p $INSTALL_DIR/password -r sftp:$SFTP snapshots)
if [[ $snapshots == Fatal* ]]; then
    echo "Initializing restic repository"
    restic -p $INSTALL_DIR/password -r sftp:$SFTP init
fi

# add backup cron if not exists
crontab -l | grep 'restic-backuper.sh' || (crontab -l 2>/dev/null; echo "$BACKUP_CRONTAB $INSTALL_DIR/restic-backuper.sh >> $INSTALL_DIR/log") | crontab -

source ./change-data-folder.sh

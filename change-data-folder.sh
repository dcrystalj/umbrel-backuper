#!/bin/bash

# read variables
VARIABLES_FILE=$(dirname "$0")/variables
source $VARIABLES_FILE


# idempotent operation
for APP in "${APPS[@]}"; do
  echo "Changing $APP"
  cd $UMBREL_ROOT/app-data/$APP
  REPLACER="s+\${APP_DATA_DIR}+$BACKUP_DIR/$APP+g"
  sed -i $REPLACER docker-compose.yml
done

echo "Data folder replaced successfully"

# need to stop whole umbrel to take changes into account
echo "Stopping umbrel"
sudo $UMBREL_ROOT/scripts/stop

if [[ $1 == "--restore" ]]; then
  echo "Removing current data"
  for APP in "${APPS[@]}"; do
    rm -rf $UMBREL_ROOT/app-data/$APP/data
  done

  read -p "WARNING: Next command will delete data in $BACKUP_DIR so it can be restored later. Please confirm by typing 'yes' (without quotes): " CONFIRM
  if [[ $CONFIRM != "yes" ]]; then
    echo "Aborting"
    exit 1
  fi

  echo "Please restore your backup data to $BACKUP_DIR in another shell now"
  echo "Useful commands:"
  echo "sudo restic -p $INSTALL_DIR/password -r sftp:$SFTP snapshots"
  echo "sudo restic -p $INSTALL_DIR/password -r sftp:$SFTP restore latest --target /"

  read -p "Press enter to continue when restore is done"
else
  echo "Keeping current data"
  for APP in "${APPS[@]}"; do
    mkdir -p $BACKUP_DIR/$APP/data
    cp -a $UMBREL_ROOT/app-data/$APP/data $BACKUP_DIR/$APP/data/
  done
fi
echo "Done"

echo "Starting umbrel..."
sudo $UMBREL_ROOT/scripts/start

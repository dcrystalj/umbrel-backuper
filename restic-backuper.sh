#!/usr/bin/env bash
set -euo pipefail

source variables

for APP in "${APPS[@]}"; do
    $UMBREL_ROOT/scripts/app stop $APP
done

GOMAXPROCS=2 restic -p $INSTALL_DIR/password -r sftp:$SFTP backup $BACKUP_DIR
GOMAXPROCS=2 restic -p $INSTALL_DIR/password -r sftp:$SFTP forget --keep-daily 2 --keep-monthly 1 --prune

for APP in "${APPS[@]}"; do
    $UMBREL_ROOT/scripts/app start $APP
done


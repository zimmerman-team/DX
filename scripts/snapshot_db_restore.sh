#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to restore data in the DX environment from a backup folder. Specify the environment type and backup folder name."
  echo "Note: This script is not connected to any automated services."
  echo "      Find your snapshot name at ls -lsht ./snapshots."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod] [backup_folder_name]"
  exit 0
fi

# Start
# Check if two arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 [dev|test|staging|prod] [backup_folder_name]"
  exit 1
fi

# Extract the arguments provided
MODE="$1"
BACKUP_FOLDER="$2"

# if $MODE is not dev, test, staging or prod, then exit
if [ "$MODE" != "dev" ] && [ "$MODE" != "test" ] && [ "$MODE" != "staging" ] && [ "$MODE" != "prod" ]; then
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

# Define variables
MONGO_DB="the-data-explorer-db"
# Assign dx-mongo to $CONTAINER_ID
CONTAINER_ID="dx-mongo"
if [ "$MODE" != "prod" ]; then
    CONTAINER_ID="dx-mongo-$MODE"
fi

MONGO_INITDB_ROOT_USERNAME=$(grep -E "^MONGO_INITDB_ROOT_USERNAME=" ".env.$MODE" | cut -d= -f2)
MONGO_INITDB_ROOT_PASSWORD=$(grep -E "^MONGO_INITDB_ROOT_PASSWORD=" ".env.$MODE" | cut -d= -f2)

# Check if the backup folder exists
BACKUP_DIR="./snapshots/$BACKUP_FOLDER"
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup folder '$BACKUP_FOLDER' not found."
  echo "these are available:"
  ls ./snapshots
  exit 1
fi

# Restore MongoDB database
docker cp $BACKUP_DIR $CONTAINER_ID:/tmp
docker exec $CONTAINER_ID mongorestore --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db $MONGO_DB --drop /tmp/$BACKUP_FOLDER/$MONGO_DB

# # Remove backup folder from the container
docker exec $CONTAINER_ID rm -rf /tmp/$BACKUP_FOLDER

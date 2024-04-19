#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to take a snapshot of the MongoDB data in the DX environment. Specify the environment type."
  echo "There will be a folder with a datetime string like 20240419121915 in the snapshots directory."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod]"
  exit 0
fi

# Start
# Check if an argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 [dev|test|staging|prod]"
  exit 1
fi
# Extract the first argument provided
MODE="$1"
# if $MODE is not dev, test, staging or prod, then exit
if [ "$MODE" != "dev" ] && [ "$MODE" != "test" ] && [ "$MODE" != "staging" ] && [ "$MODE" != "prod" ]; then
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

# Define variables
DATE=$(date +%Y%m%d%H%M%S)
LOCAL_BACKUP_DIR="./snapshots"
MONGO_DB="the-data-explorer-db"
# Assign dx-mongo to $CONTAINER_ID
CONTAINER_ID="dx-mongo"
if [ "$MODE" != "prod" ]; then
    CONTAINER_ID="dx-mongo-$MODE"
fi

MONGO_INITDB_ROOT_USERNAME=$(grep -E "^MONGO_INITDB_ROOT_USERNAME=" ".env.$MODE" | cut -d= -f2)
MONGO_INITDB_ROOT_PASSWORD=$(grep -E "^MONGO_INITDB_ROOT_PASSWORD=" ".env.$MODE" | cut -d= -f2)

# Create backup directory if it doesn't exist
mkdir -p $LOCAL_BACKUP_DIR

# Backup MongoDB database
docker exec $CONTAINER_ID mongodump --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db $MONGO_DB --out /data/db/$DATE

# Copy backup files to local backup directory
docker cp $CONTAINER_ID:/data/db/$DATE $LOCAL_BACKUP_DIR

# Remove backup files from the container
docker exec $CONTAINER_ID rm -rf /data/db/$DATE

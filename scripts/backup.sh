#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to prepopulate data in the DX environment. Specify the environment type."
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
if [ "$MODE" != "dev" ]; then
  echo "Invalid mode. Only 'dev' is allowed"
  exit 1
fi

# copy all files from ./prepopulate-data/parsed-data-files to ./dx.backend/parsed-data-files


# Assign dx-mongo to $CONTAINER_ID
SERVICE_ID="mongo"
if [ "$MODE" != "prod" ]; then
    SERVICE_ID="mongo-$MODE"
fi

BACKEND_SERVICE_ID="backend-dev"

# ensure mongodb and backend is running
bash ./scripts/stop.sh $MODE
bash ./scripts/start.sh $MODE "" $SERVICE_ID $BACKEND_SERVICE_ID -d

# Assign dx-mongo to $CONTAINER_ID
CONTAINER_ID="dx-mongo"
if [ "$MODE" != "prod" ]; then
    CONTAINER_ID="dx-mongo-$MODE"
fi

BACKEND_CONTAINER_ID="dx-backend-dev"

echo "backing up datasets "

sudo docker exec -it "$BACKEND_CONTAINER_ID" python scripts/backup-baseline-datasets.py

cp -r  ./dx.backend/staging/prepopulate-data/parsed-data-files ./prepopulate-data/
cp -r  ./dx.backend/staging/prepopulate-data/sample-data-files ./prepopulate-data/

rm -rf ./dx.backend/staging/prepopulate-data

echo "dataset backup complete"



MONGO_INITDB_ROOT_USERNAME=$(grep -E "^MONGO_INITDB_ROOT_USERNAME=" ".env.$MODE" | cut -d= -f2)
MONGO_INITDB_ROOT_PASSWORD=$(grep -E "^MONGO_INITDB_ROOT_PASSWORD=" ".env.$MODE" | cut -d= -f2)

# copy the mongodb.dump file to the container and execute mongoimport
echo "Waiting for MongoDB to be available..."
sleep 10 # wait for mongodb to start
sudo docker exec -it "$CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Chart -q '{"public": true}' --out ./Chart 
sudo docker exec -it "$CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Report -q '{"public": true}' --out ./Report 
sudo docker exec -it "$CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Dataset -q '{"public": true}' --out ./Dataset 

sudo docker cp  "$CONTAINER_ID":/Chart ./prepopulate-data/Chart
sudo docker cp  "$CONTAINER_ID":/Report ./prepopulate-data/Report
sudo docker cp  "$CONTAINER_ID":/Dataset ./prepopulate-data/Dataset

echo "Backing up public data is done."

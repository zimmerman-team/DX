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
if [ "$MODE" != "dev" ] && [ "$MODE" != "test" ] && [ "$MODE" != "staging" ] && [ "$MODE" != "prod" ]; then
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

# copy all files from ./prepopulate-data/parsed-data-files to ./dx.backend/parsed-data-files
cp -r ./prepopulate-data/parsed-data-files ./dx.backend/
cp -r ./prepopulate-data/sample-data-files ./dx.backend/

# Assign dx-mongo to $CONTAINER_ID
SERVICE_ID="mongo"
if [ "$MODE" != "prod" ]; then
    SERVICE_ID="mongo-$MODE"
fi

# ensure mongodb is running
bash ./scripts/stop.sh $MODE
bash ./scripts/start.sh $MODE $SERVICE_ID -d

# Assign dx-mongo to $CONTAINER_ID
CONTAINER_ID="dx-mongo"
if [ "$MODE" != "prod" ]; then
    CONTAINER_ID="dx-mongo-$MODE"
fi

MONGO_INITDB_ROOT_USERNAME=$(grep -E "^MONGO_INITDB_ROOT_USERNAME=" ".env.$MODE" | cut -d= -f2)
MONGO_INITDB_ROOT_PASSWORD=$(grep -E "^MONGO_INITDB_ROOT_PASSWORD=" ".env.$MODE" | cut -d= -f2)

# Ask the user for the authId for the base data
read -s -p "Please enter the authId for the public data: " authId

# Replace the string `REPL` with $authId in ./prepopulate-data/

if [ "$(uname)" == "Linux" ]; then
    echo "Linux detected"
    sed -i "s/REPL/$authId/g" ./prepopulate-data/Chart
    sed -i "s/REPL/$authId/g" ./prepopulate-data/Dataset
    sed -i "s/REPL/$authId/g" ./prepopulate-data/Report
elif [ "$(uname)" == "Darwin" ]; then
    echo "macOS detected"
    sed -i '' "s/REPL/$authId/g" ./prepopulate-data/Chart
    sed -i '' "s/REPL/$authId/g" ./prepopulate-data/Dataset
    sed -i '' "s/REPL/$authId/g" ./prepopulate-data/Report
else
    echo "Unsupported operating system"
fi

# Untar the ./prepopulate-data/FederatedSearchIndex.tar.xz file
tar -xvf ./prepopulate-data/FederatedSearchIndex.tar.xz -C ./prepopulate-data/

# copy the mongodb.dump file to the container and execute mongoimport
sudo docker cp ./prepopulate-data/Chart "$CONTAINER_ID":/Chart
sudo docker cp ./prepopulate-data/Report "$CONTAINER_ID":/Report
sudo docker cp ./prepopulate-data/Dataset "$CONTAINER_ID":/Dataset
sudo docker cp ./prepopulate-data/FederatedSearchIndex "$CONTAINER_ID":/FederatedSearchIndex

rm -rf ./prepopulate-data/FederatedSearchIndex

# Replace the authId and owner with `REPL` in ./prepopulate-data/
if [ "$(uname)" == "Linux" ]; then
    echo "Linux detected"
    sed -i 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Dataset
    sed -i 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Report
    sed -i 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Chart

    sed -i 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Dataset
    sed -i 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Report
    sed -i 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Chart
elif [ "$(uname)" == "Darwin" ]; then
    echo "macOS detected"
    sed -i '' 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Dataset
    sed -i '' 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Report
    sed -i '' 's/"authId": "[^"]*"/"authId": "REPL"/g' ./prepopulate-data/Chart

    sed -i '' 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Dataset
    sed -i '' 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Report
    sed -i '' 's/"owner": "[^"]*"/"owner": "REPL"/g' ./prepopulate-data/Chart
else
    echo "Unsupported operating system"
fi


echo "Waiting for MongoDB to be available..."
sleep 10 # wait for mongodb to start
sudo docker exec -it "$CONTAINER_ID" mongoimport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Chart --file /Chart --mode upsert
sudo docker exec -it "$CONTAINER_ID" mongoimport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Report --file /Report --mode upsert
sudo docker exec -it "$CONTAINER_ID" mongoimport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Dataset --file /Dataset --mode upsert
sudo docker exec -it "$CONTAINER_ID" mongoimport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection FederatedSearchIndex --file /FederatedSearchIndex --mode upsert

echo "Prepolulating data is done."


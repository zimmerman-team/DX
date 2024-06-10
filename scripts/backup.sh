#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to backup public data in the DX dev environment."
  echo ""
  echo "Usage: bash $0"
  exit 0
fi

MONGO_SERVICE_ID="mongo-dev"
MONGO_CONTAINER_ID="dx-mongo-dev"

BACKEND_SERVICE_ID="backend-dev"
BACKEND_CONTAINER_ID="dx-backend-dev"

# ensure mongodb and backend is running
bash ./scripts/start.sh dev $MONGO_SERVICE_ID $BACKEND_SERVICE_ID -d

preprocess_json() {
    local input_file="$1"
    local temp_file=$(mktemp)

    sudo jq . "$input_file" > "$temp_file"

    sudo mv "$temp_file" "$input_file"
}

# echo "Waiting for MongoDB and Backend to be available..."
# sleep 15

echo "Backing up datasets"

# Run the python script that backs up public parsed datasets to a staging folder
sudo docker exec -it "$BACKEND_CONTAINER_ID" python scripts/backup-baseline-datasets.py

# Copy the parsed datasets to the prepopulate folder
cp -r  ./dx.backend/staging/prepopulate-data/parsed-data-files ./prepopulate-data/
cp -r  ./dx.backend/staging/prepopulate-data/sample-data-files ./prepopulate-data/

# Delete the staging folder
rm -rf ./dx.backend/staging/prepopulate-data

echo "Dataset backup complete"

MODE="dev"
MONGO_INITDB_ROOT_USERNAME=$(grep -E "^MONGO_INITDB_ROOT_USERNAME=" ".env.$MODE" | cut -d= -f2)
MONGO_INITDB_ROOT_PASSWORD=$(grep -E "^MONGO_INITDB_ROOT_PASSWORD=" ".env.$MODE" | cut -d= -f2)

# Execute mongoimport and copy the mongodb.dump file to the prepopulate-data folder
sudo docker exec -it "$MONGO_CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Chart -q '{"baseline": true}' --out ./Chart 
sudo docker exec -it "$MONGO_CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Report -q '{"baseline": true}' --out ./Report 
sudo docker exec -it "$MONGO_CONTAINER_ID" mongoexport  --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db the-data-explorer-db --collection Dataset -q '{"baseline": true}' --out ./Dataset 

# Id for replacing auth and owner
id="REPL"

sudo docker cp "$MONGO_CONTAINER_ID":/Chart ./prepopulate-data/Chart
sudo docker cp "$MONGO_CONTAINER_ID":/Report ./prepopulate-data/Report
sudo docker cp "$MONGO_CONTAINER_ID":/Dataset ./prepopulate-data/Dataset

preprocess_json ./prepopulate-data/Chart
preprocess_json ./prepopulate-data/Report
preprocess_json ./prepopulate-data/Dataset

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

echo "Backing up public data is done."


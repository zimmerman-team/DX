#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to (re)build services running through docker. Specify the environment type, optionally specify service names."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod] [service name (optional) (up to 6 service names)]"
  exit 0
fi

# Start
# Check if an argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 bash $0 [dev|test|staging|prod] [service name (optional) (up to 6 service names)]"
  exit 1
fi
# Extract the first argument provided
MODE="$1"
# if $MODE is not dev, test, staging or prod, then exit
if [ "$MODE" != "dev" ] && [ "$MODE" != "test" ] && [ "$MODE" != "staging" ] && [ "$MODE" != "prod" ]; then
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

# Get additional arguments (service names)
I1="$2"
I2="$3"
I3="$4"
I4="$5"
I5="$6"
I6="$7"

# Check if "frontend" is being updated, this is the case if any argument is "frontend", "frontend-dev", "frontend-test", or "frontend-staging", or if no arguments are provided
is_frontend=false
for input_var in $I1 $I2 $I3 $I4 $I5; do
  if [[ "$input_var" == "frontend" || "$input_var" == "frontend-dev" || "$input_var" == "frontend-test" || "$input_var" == "frontend-staging" ]]; then
    is_frontend=true
    break
  fi
done
# if I1 is empty
if [ -z "$I1" ]; then
  is_frontend=true
fi

# Activate the correct .env file
sudo rm -f .env
sudo ln .env.$MODE .env

# create a compressed backup of the previous deployed build
if [[ $is_frontend == true && "$MODE" != "dev" ]]; then
  directory_to_compress="/var/www/html/$MODE"
  current_date=$(date +'%Y%m%d')
  if [ -d "$directory_to_compress" ]; then
    tar -cJvf "${directory_to_compress##*/}_${current_date}.tar.xz" "$directory_to_compress"
  fi
fi

# Check the value of the provided argument and run the appropriate command
if [ "$MODE" = "dev" ]; then
  sudo docker compose -f docker-compose.dev.yml build $I1 $I2 $I3 $I4 $I5 $I6
elif [ "$MODE" = "prod" ]; then
  sudo docker compose build $I1 $I2 $I3 $I4 $I5 $I6
  if [ $is_frontend == true ]; then
    sudo docker compose up -d frontend
    sleep 3 # wait for the frontend to be mounted
    rm -rf /var/www/html/prod
    cp -r ./dx.client/prod /var/www/html/
    sudo docker compose down
  fi
elif [ "$MODE" = "staging" ]; then
  sudo docker compose -f docker-compose.staging.yml build $I1 $I2 $I3 $I4 $I5 $I6
  if [ $is_frontend == true ]; then
    sudo docker compose -f docker-compose.staging.yml up -d frontend-staging
    sleep 3 # wait for the frontend to be mounted
    rm -rf /var/www/html/staging
    cp -r ./dx.client/staging /var/www/html/
    sudo docker compose -f docker-compose.staging.yml down
  fi
elif [ "$MODE" = "test" ]; then
  sudo docker compose -f docker-compose.test.yml build $I1 $I2 $I3 $I4 $I5 $I6
  if [ $is_frontend == true ]; then
    sudo docker compose -f docker-compose.staging.yml up -d frontend-test
    sleep 3 # wait for the frontend to be mounted
    rm -rf /var/www/html/test
    cp -r ./dx.client/test /var/www/html/
    sudo docker compose -f docker-compose.test.yml down
  fi
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

echo "Build script is done. You can now start the services using the 'scripts/start.sh $MODE' script."

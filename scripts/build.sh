#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to (re)build services running through docker. Specify the environment type, optionally specify service names."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod] [service name (optional) (up to 5 service names)]"
  exit 0
fi

# Start
# Check if an argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 bash $0 [dev|test|staging|prod] [service name (optional) (up to 5 service names)]"
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

# Check the value of the provided argument and run the appropriate command
if [ "$MODE" = "dev" ]; then
  sudo rm .env
  sudo ln .env.dev .env
  sudo docker compose -f docker-compose.dev.yml build $I1 $I2 $I3 $I4 $I5
elif [ "$MODE" = "prod" ]; then
  sudo rm .env
  sudo ln .env.prod .env
  sudo docker compose build $I1 $I2 $I3 $I4 $I5
elif [ "$MODE" = "staging" ]; then
  sudo rm .env
  sudo ln .env.staging .env
  sudo docker compose -f docker-compose.staging.yml build $I1 $I2 $I3 $I4 $I5
elif [ "$MODE" = "test" ]; then
  sudo rm .env
  sudo ln .env.test .env
  sudo docker compose -f docker-compose.test.yml build $I1 $I2 $I3 $I4 $I5
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

echo "Build script is done. You can now start the services using the 'scripts/start.sh $MODE' script."

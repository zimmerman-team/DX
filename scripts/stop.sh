#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to stop services running through docker. Specify the environment type, optionally specify service names."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod] [service name (optional) (up to 6 service names)]"
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
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'. With: bash $0 [dev|test|staging|prod] [service name (optional) (up to 6 service names)]"
  exit 1
fi

# Get additional arguments (service names)
I1="$2"
I2="$3"
I3="$4"
I4="$5"
I5="$6"
I6="$7"

# Extract the first argument provided
MODE="$1"

# Check the value of the provided argument and run the appropriate command
if [ "$MODE" = "dev" ]; then
  sudo docker compose -f docker-compose.dev.yml down
elif [ "$MODE" = "prod" ]; then
  sudo docker compose down
elif [ "$MODE" = "staging" ]; then
  sudo docker compose -f docker-compose.staging.yml down
elif [ "$MODE" = "test" ]; then
  sudo docker compose -f docker-compose.test.yml down
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

echo "Stop script is done."

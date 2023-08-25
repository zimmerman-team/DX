#!/bin/bash

# Check if an argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 [dev|test|staging|prod]"
  exit 1
fi

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

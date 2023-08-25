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
  sudo rm .env
  sudo ln .env.dev .env
  sudo docker compose -f docker-compose.dev.yml up
elif [ "$MODE" = "prod" ]; then
  sudo rm .env
  sudo ln .env.prod .env
  sudo docker compose up -d
elif [ "$MODE" = "staging" ]; then
  sudo rm .env
  sudo ln .env.staging .env
  sudo docker compose -f docker-compose.staging.yml up -d
elif [ "$MODE" = "test" ]; then
  sudo rm .env
  sudo ln .env.test .env
  sudo docker compose -f docker-compose.test.yml up -d
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

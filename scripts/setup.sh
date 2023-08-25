#!/bin/bash

# Check if an argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 [dev|test|staging|prod]"
  exit 1
fi

#!/bin/bash

# Function to prompt user for Y/n choice
ask_for_confirmation() {
  read -rp "$1 (Y/n): " choice
  case "$choice" in
    "" )
      return 0  # Default to Y if user presses Enter without typing anything
      ;;
    n|N )
      return 1
      ;;
    * )
      ask_for_confirmation "$1"  # Ask again if input is not recognized
      ;;
  esac
}

if ask_for_confirmation "Do you want to initialise the submodules?"; then
  git submodule init
  git submodule update
  # Add your step here
  echo "Done."
else
  echo "Skipping the submodules."
fi

# Extract the first argument provided
MODE="$1"

# Check the value of the provided argument and run the appropriate command
if [ "$MODE" = "dev" ]; then
  sudo cp .env.example .env.dev
  sudo rm .env
  sudo ln .env.dev .env
elif [ "$MODE" = "prod" ]; then
  sudo cp .env.example .env.prod
  sudo rm .env
  sudo ln .env.prod .env
elif [ "$MODE" = "staging" ]; then
  sudo cp .env.example .env.staging
  sudo rm .env
  sudo ln .env.staging .env
elif [ "$MODE" = "test" ]; then
  sudo cp .env.example .env.test
  sudo rm .env
  sudo ln .env.test .env
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

echo "Done, please set up your env, and run 'bash ./scripts/build.sh <MODE>' to build and start the project."


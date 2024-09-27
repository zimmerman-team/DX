#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to redeploy services running through docker. 
  Specify the environment type, and you will be prompted as to which services to redeploy.
  Make sure each branch is in the correct state before running this script.

  Optionally, you can pass additional arguments like '--no-cache',
  which will be passed on to the build commands.
  This can be helpful to force a complete rebuild of the image(s)."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod] [additional arguments (optional)]"
  exit 0
fi

# Function to prompt user for Y/n choice
ask_for_confirmation() {
  read -rp "$1 (Y/n): " choice
  case "$choice" in
    ""|y|Y )
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

display_branch_and_commit_message() {
  local directory="$1"
  cd "$directory"
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  last_commit_message=$(git log -1 --pretty=%B)
  last_commit_date=$(git log -1 --pretty=%cd)

  echo "- $directory"
  echo "-- Branch:              $branch_name"
  echo "-- Last commit message: $last_commit_message"
  echo "-- Last commit date:    $last_commit_date"
  cd ..
}

# Start
# Check if an argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 bash $0 [dev|test|staging|prod]"
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

# Prep the correct env file
sudo rm -f .env
sudo ln .env.$MODE .env

# Inform the user of the branches and last commits of the submodules
echo "The following branches and last commit messages were found for the submodules:"
display_branch_and_commit_message "dx.client"
display_branch_and_commit_message "dx.server"
display_branch_and_commit_message "dx.backend"
display_branch_and_commit_message "rawgraphs-charts"
echo ""
if ask_for_confirmation "Are you sure you want to continue? If not, we will abort, and you can checkout to the correct branches"; then
  echo "Continuing..."
else
  echo "Aborting."
  exit 1
fi

# DX Backend
if ask_for_confirmation "Was there an update to: DX Backend?"; then
  echo "Rebuilding the Backend Docker image..."
  IMAGE="backend"
  if [ "$MODE" != "prod" ]; then
    IMAGE="$IMAGE-$MODE"
  fi
  . ./scripts/build.sh $MODE $IMAGE $I1 $I2 $I3 $I4 $I5 $I6
else
  echo "Skipping DX Backend."
fi

if ask_for_confirmation "Was there an update to: Rawgraphs-charts?"; then
  echo "Updating prerequisites for Rawgraphs-charts..."
  # Update rawgraphs-charts locally
  cd rawgraphs-charts
  yarn install
  yarn build
  yarn link
  cd ..
  # update dx.server and ssr package
  cd dx.server
  echo "PARSED_DATA_FILES_PATH='$PWD/dx.backend/parsed-data-files/'" > .env
  yarn install
  cd src/utils/renderChart
  yarn install
  cd ../../../
  yarn initialise-server
  rm .env
  cd ..

  echo "Rebuilding Server and Client docker images..."
  SERVERIMAGE="server"
  CLIENTIMAGE="frontend"
  if [ "$MODE" != "prod" ]; then
    SERVERIMAGE="$SERVERIMAGE-$MODE"
    CLIENTIMAGE="$CLIENTIMAGE-$MODE"
  fi
  . ./scripts/build.sh $MODE $SERVERIMAGE $CLIENTIMAGE $I1 $I2 $I3 $I4 $I5 $I6
else
  # DX Server
  if ask_for_confirmation "Was there an update to: DX Server?"; then
  echo "Rebuilding Server docker image..."
    IMAGE="server"
    if [ "$MODE" != "prod" ]; then
      IMAGE="$IMAGE-$MODE"
    fi
    . ./scripts/build.sh $MODE $IMAGE $I1 $I2 $I3 $I4 $I5
  else
    echo "Skipping DX Server."
  fi

  # DX Client
  if ask_for_confirmation "Was there an update to: DX Client?"; then
    echo "Rebuilding Client docker image..."
    IMAGE="frontend"
    if [ "$MODE" != "prod" ]; then
      IMAGE="$IMAGE-$MODE"
    fi
    . ./scripts/build.sh $MODE $IMAGE $I1 $I2 $I3 $I4 $I5 $I6
  else
    echo "Skipping DX Client."
  fi
fi

echo "Restarting services..."
. ./scripts/stop.sh $MODE
. ./scripts/start.sh $MODE -d

echo "Cleaning up docker system..."
if ask_for_confirmation "Are you sure you want to clean your docker system?"; then
  docker system purge
else
  echo "Skipping docker cleanup."
fi

echo "Redeployment script is done. Services have been rebuilt and restarted."

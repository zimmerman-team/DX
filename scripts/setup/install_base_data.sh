#!/bin/bash

print_status() {
    echo "

======================================================
                     Status Update
------------------------------------------------------
$1
======================================================
"
}

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

# Prepopulate environments
print_status "We will ask you for each of [dev | test | staging | prod]
if you want to prepopulate data for that environment."
if ask_for_confirmation "Do you want to Prepopulate data for the DEV environment?"; then
  echo "Please update the .env.dev file with the correct values before running this script. We will open the file for you in 3 seconds"
  sleep 3
  nano .env.dev
  bash ./scripts/prepopulate.sh dev
fi
if ask_for_confirmation "Do you want to Prepopulate data for the TEST environment?"; then
  echo "Please update the .env.test file with the correct values before running this script. We will open the file for you in 3 seconds"
  sleep 3
  nano .env.test
  bash ./scripts/prepopulate.sh test
fi
if ask_for_confirmation "Do you want to Prepopulate data for the STAGING environment?"; then
  echo "Please update the .env.staging file with the correct values before running this script. We will open the file for you in 3 seconds"
  sleep 3
  nano .env.staging
  bash ./scripts/prepopulate.sh staging
fi
if ask_for_confirmation "Do you want to Prepopulate data for the PROD environment?"; then
  echo "Please update the .env.prod file with the correct values before running this script. We will open the file for you in 3 seconds"
  sleep 3
  nano .env.prod
  bash ./scripts/prepopulate.sh prod
fi
echo "Done."

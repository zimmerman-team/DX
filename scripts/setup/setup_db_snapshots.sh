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

print_status "Setting up MongoDB snapshots...
We will ask you if you want to set up a snapshot for each environment."

chmod +x ./scripts/snapshot_db.sh
# Define the path to the script
SCRIPT_PATH="$(pwd)/scripts/snapshot_db.sh"
# echo script path
echo script path: $SCRIPT_PATH

add_crontab() {
  local ARG="$1"
  sudo bash -c "(crontab -l ; echo '0 0 * * * $SCRIPT_PATH $ARG') | crontab -"
}

# Function to enable snapshots and add crontab
enable_snapshots() {
  local environment="$1"
  if ask_for_confirmation "Do you want to enable snapshots for $environment?"; then
    echo "Enabling $environment snapshots..."
    add_crontab "$environment"
  else
    echo "Skipping $environment."
  fi
}

# Call the function for each environment
enable_snapshots "dev"
enable_snapshots "prod"
enable_snapshots "test"
enable_snapshots "staging"

print_status "Cron job added successfully."

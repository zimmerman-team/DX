#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to set up the repository. Specify the environment type."
  echo "Optionally sets up NodeJS with npm and yarn."
  echo "Optionally initialises git submodules and their setups."
  echo "Removes any .env file, and creates a copy of .env.example with the appropriate name, then symlinks it to .env."
  echo ""
  echo "Usage: bash $0 [dev|test|staging|prod]"
  exit 0
fi

# Check if an argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 [dev|test|staging|prod]"
  exit 1
fi

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

if ask_for_confirmation "Do you want to install NodeJS v16, npm and yarn?"; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  source ~/.bashrc
  nvm install 16
  sudo apt -y install gcc g++ make
  sudo apt install gnupg2 -y
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt update && sudo apt install yarn -y
  echo "Done."
else
  echo "Skipping NodeJS, npm and yarn installation."
fi

if ask_for_confirmation "Do you want to initialise the submodules?"; then
  git submodule init
  git submodule update
  cd rawgraphs-charts
  yarn install
  yarn build
  cd ..
  npm i -g webpack-cli
  npm i -g webpack
  cd dx.server
  yarn initialise-server
  cd ..
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
  sudo rm -f .env
  sudo ln .env.dev .env
elif [ "$MODE" = "prod" ]; then
  sudo cp .env.example .env.prod
  sudo rm -f .env
  sudo ln .env.prod .env
elif [ "$MODE" = "staging" ]; then
  sudo cp .env.example .env.staging
  sudo rm -f .env
  sudo ln .env.staging .env
elif [ "$MODE" = "test" ]; then
  sudo cp .env.example .env.test
  sudo rm -f .env
  sudo ln .env.test .env
else
  echo "Invalid mode. Use 'dev', 'test', 'staging' or 'prod'."
  exit 1
fi

echo "Setup script is done, please set up your env, and run 'bash ./scripts/build.sh <MODE>' to build and start the project."

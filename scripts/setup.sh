#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to set up the repository. Specify the environment type."
  echo "Optionally sets up NodeJS with npm and yarn."
  echo "Optionally initialises git submodules and their setups."
  echo "Removes any .env file, and creates a copy of .env.example with the appropriate name, then symlinks it to .env."
  echo "Optionally prepopulates DX with data"
  echo ""
  echo "Usage: bash $0"
  exit 0
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

if ask_for_confirmation "Do you want to install Docker?"; then
  # Add Docker's official GPG key:
  # copied from https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  echo "Done."
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo "Skipping Docker installation."
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
  cp ./monitoring/.env.example ./monitoring/.env
  cp ./.env.example ./.env.dev
  cp ./.env.example ./.env.prod
  cp ./.env.example ./.env.staging
  cp ./.env.example ./.env.test
  ln -s ./.env.prod ./.env
  echo "Done. By default, .env has been symlinked to .env.prod."
else
  echo "Skipping the submodules."
fi

echo ""
echo "We will ask you for each of [dev | test | staging | prod] if you want to prepopulate data for that environment."
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

echo "Setup script is done, please set up your env, and run 'bash ./scripts/build.sh <MODE>' to build and start the project."

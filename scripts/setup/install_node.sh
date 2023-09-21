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

print_status "Installing NVM and its prerequisites."
sudo apt update -y
sudo apt -y install gcc g++ make
sudo apt install gnupg2 -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

print_status "Installing NodeJS v16 with npm."
source ~/.bashrc
nvm install 16

print_status "Installing Yarn."
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn -y

print_status "Done installing NodeJS, NPM and yarn."

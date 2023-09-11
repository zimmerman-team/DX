#!/bin/bash

echo "Setting up Kaggle..."
echo "You need to supply your username and key. They can be found here: https://www.kaggle.com/settings/account, please hit 'create new token' under API, and then copy the username and key into the prompts below."

touch ./dx.backend/kaggle.json

# ask the user to provide the url to their kaggle username
read -p "Please enter your Kaggle username: " kaggle_username
# ask the user to provide the url to their kaggle key
read -s -p "Please enter your Kaggle key: " kaggle_key

echo "{\"username\":\"$kaggle_username\",\"key\":\"$kaggle_key\"}" > ./dx.backend/kaggle.json

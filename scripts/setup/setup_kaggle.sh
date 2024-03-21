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

print_status "Setting up Kaggle...
You need to supply your username and key.
They can be found here: https://www.kaggle.com/settings/account,
please hit 'create new token' under API,
and then copy the username and key into the prompts below."

# ask the user to provide the url to their kaggle username
read -p "Please enter your Kaggle username: " kaggle_username
# ask the user to provide the url to their kaggle key
read -s -p "Please enter your Kaggle key: " kaggle_key

echo "{\"username\":\"$kaggle_username\",\"key\":\"$kaggle_key\"}" > ./dx.backend/kaggle.json

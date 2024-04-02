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

print_status "Setting up HDX...
You need to supply your API key.
It can be found here: https://data.humdata.org/user/<YOUR USER NAME>/api-tokens,
please hit 'CREATE API TOKEN' and then copy the key into the prompt below."

# ask the user to provide their api key
read -s -p "Please enter your HDX key (input is hidden): " hdx_key

echo "key: $hdx_key" > ./dx.backend/.hdx_configuration.yaml

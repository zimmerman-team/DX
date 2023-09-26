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

print_status "Setting up Monitoring...
We've already prepared and activated the nginx configuration.
Please provide us a password for the monitoring setup
under the username 'zimmerman'."

# sudo sh -c "echo -n 'zimmerman:' >> /etc/nginx/.htpasswd"
# sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"

print_status "Preparing configuration files..."
read -p "What is the complete url to your monitoring setup: (example input: 'monitoring.dev.dx.nyuki.io') https://" url_var
read -s -p "Please enter your password for Grafana for the user 'zimmerman': " grafana_key

touch ./monitoring/.env
echo "MONITORING_USERNAME=zimmerman" >> ./monitoring/.env
echo -n "MONITORING_PASSWORD=$grafana_key" >> ./monitoring/.env
echo >> ./monitoring/.env  # Add an explicit newline character
echo "MONITORING_ROOT_URL=https://$url_var/" >> ./monitoring/.env

print_status "Done setting up Monitoring."

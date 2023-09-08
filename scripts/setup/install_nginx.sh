#!/bin/bash

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

echo "Installing NGINX..."
sudo apt update
sudo apt install nginx -y

echo "Installing certbot..."
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt-get update -y
sudo apt-get install certbot python3-certbot-nginx -y

# Configure nginx
# sudo cp ./nginx/default /etc/nginx/sites-available/default
echo "We will ask you for each of [test | staging | prod] if you want to create an NGINX configuration for that environment."
# Function to configure NGINX for a given environment
configure_nginx() {
  local config_name="$1"
  local url_var="$2"
  local root_var="$3"
  local port_var="$4"

  if ask_for_confirmation "Do you want to create an NGINX configuration for the $config_name environment?"; then
    mkdir $PWD/dx.client/$config_name/build # ensure an initual build folder exists to prevent nginx from crashing
    sudo cp ./scripts/setup/nginx_host_machine/base_app "/etc/nginx/sites-available/$config_name-app"
    sudo cp ./scripts/setup/nginx_host_machine/base_app "/etc/nginx/sites-available/$config_name-server"

    read -rp "What is the base URL for the $config_name environment (without app. or server.)?: " url_var
    sudo sed -i "s/REPL_URL/${!url_var}/g" "/etc/nginx/sites-available/$config_name-app"
    sudo sed -i "s#REPL_ROOT#$PWD/dx.client/$config_name/build#g" "/etc/nginx/sites-available/$config_name-app"
    sudo sed -i "s/REPL_URL/${!url_var}/g" "/etc/nginx/sites-available/$config_name-server"
    sudo sed -i "s/REPL_PORT/${!port_var}/g" "/etc/nginx/sites-available/$config_name-server"

    sudo ln -s "/etc/nginx/sites-available/$config_name-app" /etc/nginx/sites-enabled/
    sudo ln -s "/etc/nginx/sites-available/$config_name-server" /etc/nginx/sites-enabled/
  fi
}
configure_nginx "TEST" "test_url" "test_root" "4202"
configure_nginx "STAGING" "staging_url" "staging_root" "4201"
configure_nginx "PROD" "prod_url" "prod_root" "4200"

# Restart nginx
sudo service nginx restart

if ask_for_confirmation "Do you want to set up SSL certificates for your domains?"; then
  # Set up the ssl certificate, this will require some user input.
  echo "Setting up SSL certificates..."
  sudo certbot --nginx

  echo "Setting up cron job to renew SSL certificates..."
  # update crontab with `0 5 1 * * sudo certbot renew --preferred-challenges http-01`
  cron_command="0 5 1 * * sudo certbot renew --preferred-challenges http-01"
  temp_cron_file=$(mktemp)
  echo "$cron_command" > "$temp_cron_file"
  crontab "$temp_cron_file"
  rm "$temp_cron_file"
fi

echo "Done."

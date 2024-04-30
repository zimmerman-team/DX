#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to set up the repository. Specify the environment type."
  echo "Optionally sets up NodeJS with npm and yarn."
  echo "Optionally initialises git submodules and their setups."
  echo "Removes any .env file, and creates a copy of .env.example with the appropriate name, then symlinks it to .env."
  echo "Optionally prepopulates DX with data"
  echo ""
  echo "Usage: . $0"
  exit 0
fi

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

echo ""
echo ""
if ask_for_confirmation "Do you want to install NodeJS v16, npm and yarn?"; then
  . ./scripts/setup/install_node.sh
else
  echo "Skipping NodeJS, npm and yarn installation."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to install Docker?"; then
  . ./scripts/setup/install_docker.sh
else
  echo "Skipping Docker installation."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to initialise the submodules?"; then
  . ./scripts/setup/install_submodules.sh
else
  echo "Skipping the submodules."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to prepopulate your DX with our base data?"; then
  . ./scripts/setup/install_base_data.sh
else
  echo "Skipping prepopulating."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to install NGINX with SSL enabled?"; then
  . ./scripts/setup/install_nginx.sh
else
  echo "Skipping NGINX."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to set up a connection to Kaggle?"; then
  . ./scripts/setup/setup_kaggle.sh
else
  touch ./dx.backend/kaggle.json
  echo "Skipping Kaggle Setup."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to set up a connection to HDX?"; then
  . ./scripts/setup/setup_hdx.sh
else
  touch ./dx.backend/.hdx_configuration.yaml
  echo "Skipping HDX Setup."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to set up the Monitoring environment?"; then
  . ./scripts/setup/setup_monitoring.sh
else
  echo "Skipping Monitoring Setup."
fi

echo ""
echo ""
if ask_for_confirmation "Do you want to set up automatic database snapshots?"; then
  . ./scripts/setup/setup_db_snapshots.sh
else
  echo "Skipping DB Snapshot setup."
fi

echo ""
echo ""
echo "Setup script is done, please set up your env, and run 'bash ./scripts/build.sh <MODE>' to build the project."

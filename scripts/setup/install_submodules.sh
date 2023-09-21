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

source ~/.bashrc # ensure nvm is available from previously installed script
print_status "Installing submodules..."
git submodule init
git submodule update

print_status "Installing and linking rawgraphs-charts."
cd rawgraphs-charts
yarn install
yarn build
yarn link
cd ..

print_status "Building dx-server."
npm i -g webpack-cli
npm i -g webpack
cd dx.server
# Ensure .env is available for the execSync index of the chart rendering
echo "PARSED_DATA_FILES_PATH='$PWD/dx.backend/parsed-data-files/'" > .env
yarn install
# install renderChart package
cd src/utils/renderChart
yarn install
cd ../../../
yarn initialise-server
rm .env
cd ..

print_status "Preparing environment files."
cp ./monitoring/.env.example ./monitoring/.env
cp ./.env.example ./.env.dev
cp ./.env.example ./.env.prod
cp ./.env.example ./.env.staging
cp ./.env.example ./.env.test
ln -s ./.env.prod ./.env

# update the .env files with their correct values
# string replace .env.dev `REACT_APP_API=http://server.dx/`` with `REACT_APP_API=http://localhost:4200`
sed -i 's/REACT_APP_API=http:\/\/server.dx\//REACT_APP_API=http:\/\/localhost:4200/g' ./.env.dev

# string replace .env.dev `MONGO_HOST=mongo` with `MONGO_HOST=mongo-dev`
sed -i 's/MONGO_HOST=mongo/MONGO_HOST=mongo-dev/g' ./.env.dev
sed -i 's/MONGO_HOST=mongo/MONGO_HOST=mongo-test/g' ./.env.test
sed -i 's/MONGO_HOST=mongo/MONGO_HOST=mongo-staging/g' ./.env.staging

sed -i 's/MAIN_DOMAIN=localhost/MAIN_DOMAIN=/g' ./.env.dev

sed -i 's/APP_SUBDOMAIN=client/APP_SUBDOMAIN=/g' ./.env.dev
sed -i 's/APP_SUBDOMAIN=client/APP_SUBDOMAIN=/g' ./.env.test
sed -i 's/APP_SUBDOMAIN=client/APP_SUBDOMAIN=/g' ./.env.staging

sed -i 's/API_SUBDOMAIN=server/API_SUBDOMAIN=/g' ./.env.dev
sed -i 's/API_SUBDOMAIN=server/API_SUBDOMAIN=/g' ./.env.test
sed -i 's/API_SUBDOMAIN=server/API_SUBDOMAIN=/g' ./.env.staging

sed -i 's/BACKEND_SUBDOMAIN=backend/BACKEND_SUBDOMAIN=/g' ./.env.dev
sed -i 's/BACKEND_SUBDOMAIN=backend/BACKEND_SUBDOMAIN=backend-test/g' ./.env.test
sed -i 's/BACKEND_SUBDOMAIN=backend/BACKEND_SUBDOMAIN=backend-staging/g' ./.env.staging

sed -i 's/ENV_TYPE=/ENV_TYPE=dev/g' ./.env.dev
sed -i 's/ENV_TYPE=/ENV_TYPE=test/g' ./.env.test
sed -i 's/ENV_TYPE=/ENV_TYPE=staging/g' ./.env.staging

print_status "Done... (By default, .env has been symlinked to .env.prod.)
Please update the .env files with their correct values,
specifically look at REACT_APP_API and the DX Client section."

#!/bin/bash

echo "Installing submodules..."
git submodule init
git submodule update
cd rawgraphs-charts
yarn install
yarn build
yarn link
cd ..
npm i -g webpack-cli
npm i -g webpack
cd dx.server
# Ensure .env is available for the execSync index of the chart rendering
RUN echo "PARSED_DATA_FILES_PATH='$PWD/dx.backend/parsed-data-files/'" > .env
yarn initialise-server
rm .env
cd ..
cp ./monitoring/.env.example ./monitoring/.env
cp ./.env.example ./.env.dev
cp ./.env.example ./.env.prod
cp ./.env.example ./.env.staging
cp ./.env.example ./.env.test
ln -s ./.env.prod ./.env
echo "Done... (By default, .env has been symlinked to .env.prod.)"

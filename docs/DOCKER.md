# Installing and running DX with Docker
- [Introduction](#introduction)
- [Submodules](#submodules)
- [Environment](#env)
- [Services](#services)
- [Running](#running)
    - [Processing changes](#processing-changes)
    - [Removing built docker images](#removing-built-docker-images)
    - [Connecting to live docker containers](#connecting-to-live-docker-containers)
    - [Connecting to docker logs](#connecting-to-docker-logs)
    - [Other notes](#other-notes)
- [Installing Docker](#installing-docker)
    - [Linux](#linux)
    - [MacOS](#macos)

## Introduction
We want to have a full stack DX application runnable with the click of a finger. This includes all the [services](#services) that are required to run the DX app.

The services use the default docker compose network. Each service registers itself to the network through the service name. This allows the docker containers to connect to eachother. Where locally you would use `localhost:27017`, a docker container connecting to a PostgreSQL container would refer to `database:27017`. By providing a port like `ports: 8000:8000`, you allow the localhost port 8000 to connect through to the docker container's port 8000.

## Submodules
Initialise the following git submodules with:
```
git submodule init
git submodule update
```
_Note: Some of these submodules might still be private, use your access token to access them if necessary._

## .env
Make sure to set up your local .env file, we've provided an example under [.env.example](../.env.example).

## Services
| service | network name | ports | image | Additional notes |
|---|---|---|---|---|
| mongo | dx-mongo | 27017 | mongo:latest | Accessed through `mongodb://USER:PASS!@mongo:27017` where USER and PASS are set in the `MONGO_INITDB_` fields in .env.<br />We mount `/data/db` to our `mongo_data` docker 'volume', which is persisted. |
| server | dx-server | 4200 | ./dx.server | Builds a nodejs image with the DX Server, run with pm2. Directories are mounted to support file manipulation. |
| frontend | dx-frontend | 80: | . | First, creates a build directory of the DX client with the rawgraphs charts connected. Then sets up NGINX to connect to each of the services. | 

## Running
Ensure [docker](#installing-docker) is installed. 

The following command is used to run all services (It will build images for each of the services on it's first run):
```
sudo docker compose up
```

### Development mode
You can run the client instead of building by running the `dev` service. This enables the client on [localhost:3000](localhost:3000) or any other port you have specified, while enabling auto-updates with hot-loading. Because of the dependency tree, this starts all the required services. Run with:
```
sudo docker compose up dev
```

### Processing changes
If you've made changes to a specific codebase, re-build that service with 
```
sudo docker compose up --build <service name>
```

### Removing built docker images
```
sudo docker images
sudo docker image rm <ID>
```

### Connecting to live docker containers 
```
sudo docker ps
sudo docker exec -i -t _<CONTAINER ID>_ /bin/bash
```

### Connecting to docker logs
```
sudo docker ps
sudo docker logs _<CONTAINER ID>_
```

### Other notes:
 - use `--detach` or `-d` to detach the docker containers from the current terminal.
 - use `--build` to rebuild the images.


## Installing Docker
### Linux
Install the prerequisites:
```
sudo apt-get install curl
sudo apt-get install gnupg
sudo apt-get install ca-certificates
sudo apt-get install lsb-release
```

Set up the docker gpg files
```
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install docker and docker compose:
```
sudo apt-get update

### Install docker and docker compose on Ubuntu
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

(optional:) Verify installation. You should see "This message shows that your installation appears to be working correctly."
```
sudo docker run hello-world
```

### MacOS
[Install Docker Desktop](https://docs.docker.com/desktop/install/mac-install/)

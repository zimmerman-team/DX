# Running DX Locally

## Introduction
You can run DX locally by checking the individual README's of the services, and installing the dependencies (MongoDB).

## Hybrid
You could consider wanting to run the backend side of the DX app through Docker, but locally developing the front-end. You can achieve this by starting all of the services except for the client. Although a small lifehack can be to start all services, and just change the PORT in the .env file for your client, and run the client manually alongside the dockerised client.

#### At this point, we also have hotloading support for the server and the client in the Docker dev version!

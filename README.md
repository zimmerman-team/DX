# DX
A central repository for the DataXplorer project.

## Introduction
TODO: Add nice introduction

## Setting up
Running and setting up is split into two parts: docker and manual. Because of the extensiveness of these sections they are contained in their own files.
- [Docker guide](./docs/DOCKER.md)
- [Local guide](./docs/LOCAL.md)

## Submodules
Initialise the following git submodules with:
```
git submodule init
git submodule update
cd dx.rawgraphs-ssr
git submodule init
git submodule update
cd ..
```
- [DX Client](https://github.com/zimmerman-team/dx.client)
    - We currently run the `develop` branch
- [DX Server](https://github.com/zimmerman-team/dx.server)
    - We currently run the `develop` branch
- [DX Rawgraphs Charts](https://github.com/zimmerman-team/rawgraphs-charts)
    - We currently run the `feat/echarts` branch
- [DX Backend](https://github.com/zimmerman-team/dx.backend)
    - We currently run the `main` branch.

_Note: Some of these submodules might still be private, use your access token to access them if necessary._

## Environment file
Use the .env.example file to guide you to what needs to be setup. For example, `cp .env.example .env`

## Running
We've set up a [docker-compose](docker-compose.yml) file that starts all of the services.
- MongoDB
- The Data Explorer Server
- Serverside rendering for e-charts
- NGINX With The Data Explorer Client

If the submodules are in place, and the .env file is set up; You can run all of these services using
```
docker compose up
```

## Code Management
Style your commits in the following form, to support semantic release.
```
feat: A new feature
fix: A bug fix
docs: Documentation only changes
style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
refactor: A code change that neither fixes a bug nor adds a feature
perf: A code change that improves performance
test: Adding missing or correcting existing tests
chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
```

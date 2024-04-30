# DX

A central repository for the DataXplorer project.
This contains all the repositories required to run the DX project as submodules.

## Introduction

#### DataXplorer turns data into impact within just a few minutes

DataXplorer is an AI-powered purpose-driven data exploration solution built with the
goal of making the visual representation of data easy and powerful for everyone.

To get started immediately, run `. scripts/setup.sh`. _Note, the . is important to ensure the context of the build scripts is correct._

### Mission

Our mission is to create lasting impact for organizations that bring positive change to our world by helping them to unlock the power of data.

Our trusted and easy-to-use data solutions boost an organization's performance by powering its core mission.

### DataXplorer

Organizations face a challenge in clearly communicating
data they collect, analyze and disseminate. By leveraging data as a strategic asset, we help organizations around the world to communicate their lasting change more clearly
and effectively.

Making sense of it all is our passion;
presenting it with impact is what we know how to do best.

To enable your organization to lead in your field through the power of data, we provide DataXplorer, an AI-powered purpose-driven data platform solution. DataXplorer empowers people with meaningful data to make better decisions in driving towards an
equitable future for all.

## Setting up

Running and setting up is split into two parts: docker and manual. Because of the extensiveness of these sections they are contained in their own files.

However, our `scripts/setup.sh` script is able to set up your project folder for you.
It will:

- Install NodeJS 16 with NPM and Yarn. (optional)
- Install Docker. (optional)
- Prepare the project
  - Initialise the submodules
  - Prepare the rawgraphs charts
  - Globally install webpack(-cli) for building DX Server
  - Initialise the server's dependencies
  - Ensure .env files are prepared for the main project and the monitoring setup (make sure to edit the values in the environment type you are setting up)

We also have specific guides for local and docker setups.

- [Docker guide](./docs/DOCKER.md)
- [Local guide](./docs/LOCAL.md)

### Submodules

Initialise the following git submodules with:

```
git submodule init
git submodule update
cd dx.server
yarn initialise-server
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
- [Monitoring](https://github.com/zimmerman-team/Central-Logging)
  - We currently run the `project/dx` branch.
- [AI API](https://github.com/zimmerman-team/general-ai-api)
  - We currently run the `main` branch.

_Note: Some of these submodules might still be private, use your access token to access them if necessary._

### Environment file

Use the .env.example file to guide you to what needs to be setup. For example, `cp .env.example .env`
In the environment file we also explain the differences between the dev, test, staging and production versions of the .env file.

A recommended approach is to do the following:

```
cp .env.example .env.staging && cp .env.example .env.test
```

Then, if you are running either staging or test, simply symlink the file to .env as desired as shown below. This allows you to maintain separate environment files without manually editing the .env file each time.

```
rm .env
ln .env.staging .env
```

Note: This recommended approach is required for the provided `build` and `start` scripts, used with docker.

### Environment Variables

- `GOOGLE_API_KEY`: This key can be gotten from the google cloud console. Once you're signed in to the google cloud console, you can head over to the apis and credentials section, select the youtube api as one of the apis for your project and then generate an api key.
- `SHUTTERSTOCK_API_TOKEN`: This can be gotten from the shutterstock developer dashboard. Once you're signed in you create an application and generate a token.
- `UNSPLASH_ACCESS_KEY`: This can be gotten from the unsplash developer dashboard. Once you're signed in you create an application and grab the access key.
- `VIMEO_ACCESS_TOKEN`: This can be gotten from the vimeo developer dashboard. Once you're signed in you create an application and generate an access token.

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

## Environments

### `dev`

Local development, in docker, this environment supports hotloading on the server and client submodules.

### `test`

In docker, provides access to mongodb, a backend and a server instance, and creates a `build` folder in `./dx.client/test/`. With a locally hosted webserver like NGINX you can point to this build folder as the location root. This build implicitly makes use of the separate server instance running at port 4202, which in turn uses the internal docker network to communicate to the other services.

### `staging`

In docker, provides access to mongodb, a backend and a server instance, and creates a `build` folder in `./dx.client/staging/`. With a locally hosted webserver like NGINX you can point to this build folder as the location root. This build implicitly makes use of the separate server instance running at port 4201, which in turn uses the internal docker network to communicate to the other services.

### `prod`

In docker, provides access to mongodb, a backend and a server instance, and creates a `build` folder in `./dx.client/prod/`. Additionally, creates a in-docker locally hosted NGINX instance that provides access to addresses like [server.localhost](server.localhost), [backend.localhost](backend.localhost), and [client.localhost](client.localhost). Additionally, With a locally hosted webserver you can again point to the build folder and directly use it.

## Scripts
These scripts are provided in the ./scripts/ directory:

- setup.sh
- build.sh
- start.sh
- stop.sh
- monitoring.sh
- redeploy.sh

They take an argument: `dev | test | staging | prod`

To get started immediately, run `. scripts/setup.sh`. _Note, the . is important to ensure the context of the build scripts is correct._

You can setup and run the project in no-time. This is based on docker, so make sure it is [installed](./docs/DOCKER.md#installing-docker).

The exception to the above arguments is `monitoring.sh`. This script takes `start | stop | restart | dev`, the latter starting the docker containers without detaching from the logs.

Additional scripts are also available.
- backup.sh: Available in `dev` environment, it snapshots the public datasets in the dev environment.
- patchCharts.sh: Available in `dev | test | staging | prod`, updates existing charts to contain the updated values for `isMappingValid`.
- prepopulate.sh: Available in `dev | test | staging | prod`, inserts sample files and database values into the selected environment's MongoDB.
- snapshot_db.sh: Available in `dev | test | staging | prod`, creates a snapshot of the existing MongoDB database.
- snapshot_db_restore.sh: Available in `dev | test | staging | prod`, upserts a snapshot of the MongoDB database.

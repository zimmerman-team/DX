# Create the react frontend build
FROM node:16.19.1-alpine3.17 AS client

ARG REACT_APP_API
ARG REACT_APP_GOOGLE_API_CLIENT_ID
ARG REACT_APP_GOOGLE_API_DEV_KEY
ENV REACT_APP_API=$REACT_APP_API
ENV REACT_APP_GOOGLE_API_CLIENT_ID=$REACT_APP_GOOGLE_API_CLIENT_ID
ENV REACT_APP_GOOGLE_API_DEV_KEY=$REACT_APP_GOOGLE_API_DEV_KEY

# Install and link the charts
WORKDIR /app/charts/
COPY ./rawgraphs-charts ./
RUN yarn install
RUN yarn build
RUN yarn link

# Build the react app
WORKDIR /app/client/
COPY ./dx.client ./
RUN yarn link "@rawgraphs/rawgraphs-charts"
RUN yarn install
RUN yarn build
RUN yarn docker-prod

# NGINX SETUP
FROM nginx:latest

# Environment variables used by the nginx config
ARG MAIN_DOMAIN
ARG APP_SUBDOMAIN
ARG API_SUBDOMAIN
ARG BACKEND_SUBDOMAIN

WORKDIR /app

# Copy the NGINX config files
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./nginx/hostfile /etc/hosts
COPY ./nginx/proxy_params /etc/nginx/proxy_params
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# client
#    reference to client             client-image      local-image
COPY --from=client /app/client/build /app/frontend/build
COPY ./nginx/sites-enabled/client  /etc/nginx/sites-enabled/client
RUN sed -i "s|MAIN_DOMAIN|${MAIN_DOMAIN}|g" /etc/nginx/sites-enabled/client
RUN sed -i "s|APP_SUBDOMAIN|${APP_SUBDOMAIN}|g" /etc/nginx/sites-enabled/client

# server
COPY ./nginx/sites-enabled/server  /etc/nginx/sites-enabled/server
RUN sed -i "s|MAIN_DOMAIN|${MAIN_DOMAIN}|g" /etc/nginx/sites-enabled/server
RUN sed -i "s|API_SUBDOMAIN|${API_SUBDOMAIN}|g" /etc/nginx/sites-enabled/server

# backend
COPY ./nginx/sites-enabled/backend  /etc/nginx/sites-enabled/backend
RUN sed -i "s|MAIN_DOMAIN|${MAIN_DOMAIN}|g" /etc/nginx/sites-enabled/backend
RUN sed -i "s|BACKEND_SUBDOMAIN|${BACKEND_SUBDOMAIN}|g" /etc/nginx/sites-enabled/backend

# Done, starting NGINX

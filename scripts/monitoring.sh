#!/bin/bash

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Used to start, restart or stop the monitoring services."
  echo "When stopping, keep in mind that all services are stopped."
  echo "the 'dev' argument is provided to start the services without detaching."
  echo ""
  echo "Usage: bash $0 [start | restart | stop | dev] [service name (optional) (up to 8 service names)]"
  exit 0
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 [start | restart | stop | dev] [service name (optional) (up to 8 service names)]"
  exit 1
fi

I1="$2"
I2="$3"
I3="$4"
I4="$5"
I5="$6"
I6="$7"
I7="$8"
I8="$9"

if [ "$1" = "start" ]; then
  echo "Starting..."
  sudo docker compose -f docker-compose.monitoring.yml up -d $I1 $I2 $I3 $I4 $I5 $I6 $I7 $I8
  echo "Done."
elif [ "$1" = "restart" ]; then
  echo "Starting..."
  sudo docker compose -f docker-compose.monitoring.yml down
  sudo docker compose -f docker-compose.monitoring.yml up -d $I1 $I2 $I3 $I4 $I5 $I6 $I7 $I8
  echo "Done."
elif [ "$1" = "stop" ]; then
  echo "Starting..."
  sudo docker compose -f docker-compose.monitoring.yml down
  echo "Done."
elif [ "$1" = "dev" ]; then
  echo "Starting..."
  sudo docker compose -f docker-compose.monitoring.yml up $I1 $I2 $I3 $I4 $I5 $I6 $I7 $I8
  echo "Done."
else
  echo "Invalid mode. Use 'start', 'restart', 'stop' or 'dev'."
  exit 1
fi

echo "Monitoring script is done."

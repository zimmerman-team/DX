#!/bin/bash

# Set up cronjob
echo "Setting up cron job for indexing federated sources..."

read -p "Enter the port to request the reindexing on (e.g., 4004, 4005, 4006) [4004]: " port
port=${port:-4004}
echo "Using port $port for reindexing requests."

if (crontab -l 2>/dev/null; echo "0 1 * * * /usr/bin/curl http://localhost:$port/external-sources/index >> /var/log/index-external-sources-cron.log 2>&1") | crontab -; then
    echo "Cron job set up successfully."
else
    echo "Failed to set up cron job. Please check if you have the necessary permissions."
    exit 1
fi

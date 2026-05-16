#!/bin/bash
set -e
set -x
cd $(dirname "$0")/..
mkdir -p logs


docker compose up -d pgsqldb
sleep 15
docker compose build
docker compose run --rm pdm install
LOG_FILE="logs/init_$(date -Is).log"
nohup docker compose run --rm pdm init &> "$LOG_FILE" && echo "SUCCESS" || echo "FAILURE" &
tail -f "$LOG_FILE"

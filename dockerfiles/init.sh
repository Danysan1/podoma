#!/bin/bash
set -e
set -x
cd $(dirname "$0")/..

docker compose up -d pgsqldb
sleep 20
docker compose run --rm pdm install
LOG_FILE="log/init_$(date -Is).log"
nohup docker compose run --rm pdm init &> "$LOG_FILE" && echo "SUCCESS" || echo "FAILURE" &
tail -f "$LOG_FILE"

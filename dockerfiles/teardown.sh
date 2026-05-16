#!/bin/bash
set -e
set -x
cd $(dirname "$0")/..

df -h
ls -lh /mnt/volume/docker/volumes/podoma_workdir/_data/

docker compose down --remove-orphans
#rm -f /mnt/volume/docker/volumes/podoma_workdir/_data/italy-internal.time*
rm -f /mnt/volume/docker/volumes/podoma_workdir/_data/*.csv
docker volume rm podoma_db-data
docker volume rm podoma_pdm-data

df -h

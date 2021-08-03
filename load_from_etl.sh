#!/usr/bin/env bash

data_name=$1
db_name=$2
shards="${3}"
data_dir="/mnt/samba/data/gdm/${data_name}/"
pg_port=15431
seq_url="postgres://postgres@localhost:${pg_port}/${db_name}"
tag_name=pg_loadmop

set -x
#rsync --whole-file --verbose --human-readable --progress --recursive --archive --no-compress --delete titan.jsaw.io:/tmp/gdm/${data_name}/ /data/tmp/gdm/${data_name}/ && \
#rsync -avAXEWSlHh titan.jsaw.io:/tmp/gdm/${data_name}/ /data/tmp/gdm/${data_name}/ --no-compress --info=progress2 && \
if [ "${shards}" != "" ]; then
  shards="--shards=${shards}"
fi
rm -rf "${data_dir}/split" && \
(docker stop "${tag_name}" || true) && \
docker run --detach --rm --name "${tag_name}" --publish "${pg_port}:5432" -e POSTGRES_HOST_AUTH_METHOD=trust postgres:9.6 && \
sleep 5 && \
createdb -h localhost -U postgres -p "${pg_port}" "${db_name}" && \
SEQUELIZER_URL="${seq_url}" bundle exec bin/loadmop create gdm ${db_name} "${data_dir}" --force --allow-nulls "${shards}" && \
SEQUELIZER_URL="${seq_url}" bundle exec bin/loadmop ancestorize ${db_name} && \
echo "ALTER SCHEMA public RENAME TO ${db_name};" | psql -U postgres -h localhost -p "${pg_port}" ${db_name} && \
echo "DROP SCHEMA IF EXISTS ${db_name} CASCADE;" | psql postgres://ryan:r@titan.jsaw.io/all_gdm_dbs && \
pg_dump -U postgres -h localhost -p "${pg_port}" --schema ${db_name} ${db_name} | psql postgres://ryan:r@titan.jsaw.io/all_gdm_dbs && \
docker stop "${tag_name}" && \
true

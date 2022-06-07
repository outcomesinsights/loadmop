#!/usr/bin/env bash

data_name=$1
db_name=$2
shards=${4}
data_dir="/mnt/samba/data/gdm/${data_name}/"
pg_port=15432
seq_url="postgres://postgres@localhost:${pg_port}/${db_name}"
pg_version=14
tag_name="pg_loadmop${pg_version}"
destination_url="${3:-postgres://ryan:r@helios.jsaw.io/staging_for_titan}"

set -x
#rsync --whole-file --verbose --human-readable --progress --recursive --archive --no-compress --delete titan.jsaw.io:/tmp/gdm/${data_name}/ /data/tmp/gdm/${data_name}/ && \
#rsync -avAXEWSlHh titan.jsaw.io:/tmp/gdm/${data_name}/ /data/tmp/gdm/${data_name}/ --no-compress --info=progress2 && \
if [ "${shards}" != "" ]; then
  shards="--shards=${shards}"
fi

(
  cd "${data_dir}" && \
  rm -rf split
#  for parquet_file in **/*.parquet; do
#    csv_file="${parquet_file%.parquet}.csv"
#    if ! -e "${csv_file}"; then
#      echo "CSVing ${parquet_file} => ${csv_file}"
#        #| csvcut --not-column oi_id,oi_original_file,source_field_generator,source_table \
#      parquet-tools csv "${parquet_file}" \
#        | xsv select '!oi_id,oi_original_file,source_field_generator,source_table' \
#        | sed -e '/^,\+$/d' \
#        > "${csv_file}"
#    else
#      echo "${parquet_file} => ${csv_file} exists, skipping"
#    fi
#  done
)
(docker stop "${tag_name}" || true) && \
docker run --detach --rm --name "${tag_name}" --publish "${pg_port}:5432" -e POSTGRES_HOST_AUTH_METHOD=trust postgres:"${pg_version}" && \
sleep 5 && \
createdb -h localhost -U postgres -p "${pg_port}" "${db_name}" && \
SEQUELIZER_URL="${seq_url}" bundle exec bin/loadmop create gdm ${db_name} "${data_dir}" --force --allow-nulls ${shards} && \
SEQUELIZER_URL="${seq_url}" bundle exec bin/loadmop ancestorize ${db_name} && \
echo "ALTER SCHEMA public RENAME TO ${db_name};" | psql -U postgres -h localhost -p "${pg_port}" ${db_name} && \
echo "DROP SCHEMA IF EXISTS ${db_name} CASCADE;" | psql "${destination_url}" && \
pg_dump -U postgres -h localhost -p "${pg_port}" --schema ${db_name} ${db_name} | psql "${destination_url}" && \
docker stop "${tag_name}" && \
true

#!/usr/bin/env bash

data_name=$1
db_name=$2
remote_dir=${3}

set -x
dropdb ${db_name} ; createdb ${db_name} 
rsync -avr --delete titan.jsaw.io:${remote_dir} /data/tmp/gdm/${data_name}/ && \
bundle exec bin/loadmop create gdm ${db_name} /data/tmp/gdm/${data_name}/ --force --allow-nulls && \
bundle exec bin/loadmop ancestorize ${db_name} && \
echo "ALTER SCHEMA public RENAME TO ${db_name};" | psql -U ryan ${db_name} && \
pg_dump --create --schema ${db_name} ${db_name} | psql postgres://ryan:r@titan.jsaw.io/all_gdm_dbs && \
true

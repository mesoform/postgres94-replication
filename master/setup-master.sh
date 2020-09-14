#!/bin/bash

PG_REP_PASSWORD=$(cat ${PG_REP_PASSWORD_FILE})

source /usr/local/bin/docker-entrypoint.sh
docker_setup_env
docker_temp_server_start
docker_process_sql <<<"CREATE ROLE $PG_REP_USER WITH REPLICATION PASSWORD '$PG_REP_PASSWORD' LOGIN"
docker_temp_server_stop

echo "host replication all ${HBA_ADDRESS} md5" >> "$PGDATA/pg_hba.conf"

# replication specific configuration
echo "wal_level = hot_standby" >> $PGDATA/postgresql.conf
echo "archive_mode = on" >> $PGDATA/postgresql.conf
echo "archive_command = 'cd .'" >> $PGDATA/postgresql.conf
echo "max_wal_senders = 5" >> $PGDATA/postgresql.conf
echo "wal_keep_segments = 32" >> $PGDATA/postgresql.conf
echo "hot_standby = on" >> $PGDATA/postgresql.conf
echo "synchronous_standby_names = '*'" >> $PGDATA/postgresql.conf
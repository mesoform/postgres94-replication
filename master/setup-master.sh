#!/usr/bin/env bash

PG_REP_PASSWORD=$(cat ${PG_REP_PASSWORD_FILE})

set -e
source /usr/local/bin/docker-entrypoint.sh
#############################################
## I'm pretty sure there will be a bit of a loop going on here where
## some things shouldn't run if it is a fresh install and others should
## run when it is a reinstall. Maybe some of it just needs to move to the entrypoint.sh
#############################################
docker_setup_env
if [ "$(id -u)" = '0' ]; then
	# then restart script as postgres user
    exec gosu postgres "$BASH_SOURCE" "$@"
fi
docker_temp_server_start
docker_process_sql <<<"CREATE ROLE $PG_REP_USER WITH REPLICATION PASSWORD '$PG_REP_PASSWORD' LOGIN"
docker_temp_server_stop
##############################################

echo "host replication all ${HBA_ADDRESS} md5" >> "$PGDATA/pg_hba.conf"

# replication specific configuration
echo "wal_level = hot_standby" >> $PGDATA/postgresql.conf
echo "archive_mode = on" >> $PGDATA/postgresql.conf
echo "archive_command = 'cd .'" >> $PGDATA/postgresql.conf
echo "max_wal_senders = 5" >> $PGDATA/postgresql.conf
echo "wal_keep_segments = 32" >> $PGDATA/postgresql.conf
echo "hot_standby = on" >> $PGDATA/postgresql.conf
echo "synchronous_standby_names = '*'" >> $PGDATA/postgresql.conf
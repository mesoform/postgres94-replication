#!/bin/bash

PG_REP_PASSWORD=$(cat ${PG_REP_PASSWORD_FILE})

echo "host replication all ${HBA_ADDRESS} md5" >> "$PGDATA/pg_hba.conf"

# replication specific configuration
echo "wal_level = hot_standby" >> $PGDATA/postgresql.conf
echo "archive_mode = on" >> $PGDATA/postgresql.conf
echo "archive_command = 'cd .'" >> $PGDATA/postgresql.conf
echo "max_wal_senders = 8" >> $PGDATA/postgresql.conf
echo "wal_keep_segments = 8" >> $PGDATA/postgresql.conf
echo "hot_standby = on" >> $PGDATA/postgresql.conf
echo "synchronous_standby_names = '*'" >> $PGDATA/postgresql.conf

set -e
psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB -c \
  "CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD'";
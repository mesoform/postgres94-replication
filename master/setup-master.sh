#!/bin/bash

PG_REP_PASSWORD=$(cat ${PG_REP_PASSWORD_FILE})

config_file=$PGDATA/postgresql.conf

# Check if configuration file exists. If not, it probably means that database is not initialized yet
if [ ! -f $config_file ]; then
  return
fi

# Reinitialize config
sed -i "s/wal_level =.*$//g" $config_file
sed -i "s/archive_mode =.*$//g" $config_file
sed -i "s/archive_command =.*$//g" $config_file
sed -i "s/archive_timeout =.*$//g" $config_file
sed -i "s/max_wal_senders =.*$//g" $config_file
sed -i "s/wal_keep_segments =.*$//g" $config_file
sed -i "s/hot_standby =.*$//g" $config_file
sed -i "s/synchronous_standby_names =.*$//g" $config_file

echo "host replication all ${HBA_ADDRESS} md5" >> "$PGDATA/pg_hba.conf"

set -e
psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB -c "CREATE ROLE $PG_REP_USER WITH REPLICATION PASSWORD '$PG_REP_PASSWORD' LOGIN"

# replication specific configuration
echo "wal_level = hot_standby" >> $PGDATA/postgresql.conf
echo "archive_mode = on" >> $PGDATA/postgresql.conf
echo "archive_command = 'cd .'" >> $PGDATA/postgresql.conf
echo "max_wal_senders = 5" >> $PGDATA/postgresql.conf
echo "wal_keep_segments = 32" >> $PGDATA/postgresql.conf
echo "hot_standby = on" >> $PGDATA/postgresql.conf
echo "synchronous_standby_names = '*'" >> $PGDATA/postgresql.conf
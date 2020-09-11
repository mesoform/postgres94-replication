#!/bin/bash

function update_conf () {
  wal=$1
  # PGDATA is defined in upstream postgres dockerfile
  config_file=$PGDATA/postgresql.conf

  # Check if configuration file exists. If not, it probably means that database is not initialized yet
  if [ ! -f $config_file ]; then
    return
  fi

  # Reinitialize config
  sed -i "s/wal_level =.*$//g" $config_file
  sed -i "s/archive_mode =.*$//g" $config_file
  sed -i "s/archive_command =.*$//g" $config_file
  sed -i "s/max_wal_senders =.*$//g" $config_file
  sed -i "s/wal_keep_segments =.*$//g" $config_file
  sed -i "s/hot_standby =.*$//g" $config_file
  sed -i "s/synchronous_standby_names =.*$//g" $config_file

  if [ "$wal" = true ] ; then
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

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c \
      "CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD'";
  fi
}

if [ "${1:0:1}" = '-' ]; then
  set -- postgres "$@"
fi

if [ "$1" = 'postgres' ]; then
  wal_enable=true

  # Update postgresql configuration
  update_conf $wal_enable

  # Run the postgresql entrypoint
  /usr/local/bin/docker-entrypoint.sh postgres
fi
#!/bin/bash

function update_conf () {
  replication=$1
  # PGDATA is defined in upstream postgres dockerfile
  config_file=$PGDATA/postgresql.conf

  # Check if configuration file exists. If not, it probably means that database is not initialized yet
  if [ ! -f $config_file ]; then
    return
  fi
  # Reinitialize config
  sed -i "s/log_timezone =.*$//g" $PGDATA/postgresql.conf
  sed -i "s/timezone =.*$//g" $PGDATA/postgresql.conf
  sed -i "s/wal_level =.*$//g" $config_file
  sed -i "s/archive_mode =.*$//g" $config_file
  sed -i "s/archive_command =.*$//g" $config_file
  sed -i "max_wal_senders =.*$//g" $config_file
  sed -i "wal_keep_segments =.*$//g" $config_file
  sed -i "hot_standby =.*$//g" $config_file
  sed -i "synchronous_standby_names =.*$//g" $config_file

  # Configure replication
  if [ "$replication" = true ] ; then
    /docker-entrypoint-initdb.d/setup-master.sh
  fi
  echo "log_timezone = $DEFAULT_TIMEZONE" >> $config_file
  echo "timezone = $DEFAULT_TIMEZONE" >> $config_file
}

if [ "${1:0:1}" = '-' ]; then
  set -- postgres "$@"
fi

if [ "$1" = 'postgres' ]; then

  replication_enable=true

  # Update postgresql configuration
  update_conf $replication_enable

  # Run the postgresql entrypoint
  docker-entrypoint.sh postgres
fi
#!/bin/bash

export PG_REP_PASSWORD_FILE=$PG_REP_PASSWORD_FILE
export HBA_ADDRESS=$HBA_ADDRESS
export POSTGRES_USER=$POSTGRES_USER
export POSTGRES_DB=$POSTGRES_DB
export PG_REP_USER=$PG_REP_USER

function update_conf () {
  wal=$1
  # PGDATA is defined in upstream postgres dockerfile
  config_file=$PGDATA/postgresql.conf

  # Reinitialize config
  sed -i "s/wal_level =.*$//g" $config_file
  sed -i "s/archive_mode =.*$//g" $config_file
  sed -i "s/archive_command =.*$//g" $config_file
  sed -i "s/max_wal_senders =.*$//g" $config_file
  sed -i "s/wal_keep_segments =.*$//g" $config_file
  sed -i "s/hot_standby =.*$//g" $config_file
  sed -i "s/synchronous_standby_names =.*$//g" $config_file

  if [ "$wal" = true ] ; then
    /docker-entrypoint-initdb.d/setup-master.sh
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
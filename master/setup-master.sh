#!/bin/bash

PG_REP_PASSWORD=$(cat $PG_REP_PASSWORD_FILE)

echo "host replication all ${HBA_ADDRESS} md5" >> "$PGDATA/pg_hba.conf"

cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = hot_standby
archive_mode = on
archive_command = 'cd .'
max_wal_senders = 8
wal_keep_segments = 8
hot_standby = on
synchronous_standby_names = '*'
EOF

set -e
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD';
EOSQL
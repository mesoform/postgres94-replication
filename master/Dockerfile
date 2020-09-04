FROM postgres:9.4-alpine

RUN apk add --update htop

# Add replication script
COPY ./setup-master.sh /docker-entrypoint-initdb.d/setup-master.sh

RUN chmod 0666 /docker-entrypoint-initdb.d/setup-master.sh
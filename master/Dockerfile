FROM postgres:9.4-alpine

ENV DEFAULT_TIMEZONE UTC

RUN apk add --update htop

# Add replication script
COPY setup-master.sh /docker-entrypoint-initdb.d/

#Healthcheck to make sure container is ready
RUN chmod 0666 /docker-entrypoint-initdb.d/setup-master.sh

HEALTHCHECK CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1

# Add and configure entrypoint and command
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]

VOLUME ["/var/run/postgresql", "/usr/share/postgresql/", "/var/lib/postgresql/data", "/tmp"]
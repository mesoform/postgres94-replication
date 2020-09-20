FROM postgres:9.4

RUN apt update
RUN apt install htop

# Add replication script
COPY setup-master.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/setup-master.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
#Healthcheck to make sure container is ready
HEALTHCHECK CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["postgres"]

VOLUME ["/var/run/postgresql", "/usr/share/postgresql/", "/var/lib/postgresql/data", "/tmp"]
FROM postgres:9.4-alpine

RUN apk add --update htop

# Add replication script
COPY setup-master.sh /docker-entrypoint-initdb.d/
RUN chmod 0666 /docker-entrypoint-initdb.d/setup-master.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres"]

VOLUME ["/var/run/postgresql", "/usr/share/postgresql/", "/var/lib/postgresql/data", "/tmp"]
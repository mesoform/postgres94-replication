FROM postgres:9.4-alpine

RUN apk add --update iputils
RUN apk add --update htop

# COPY ./setup-slave.sh /docker-entrypoint-initdb.d
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["postgres"]
FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/mysql/* \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' \
    /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

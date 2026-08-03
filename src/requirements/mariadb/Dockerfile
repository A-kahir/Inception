FROM debian:12

RUN apt-get update && \
    apt-get install -y mariadb-server

COPY conf/my.cnf /etc/mysql/

COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
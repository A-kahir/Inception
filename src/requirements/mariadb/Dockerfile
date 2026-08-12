FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server

COPY conf/my.cnf /etc/mysql/

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

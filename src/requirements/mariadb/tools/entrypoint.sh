#!/bin/bash
set -e

if [! -d "/var/lib/mysql"]
    then
    echo "=> Intializing MariaDB"
    mariadb-install-db -datadir=/var/lib/mysql
    mysql_safe --skip-networking &
    pid="$!"
    until mariadb-admin ping --silent;
    do
        sleep 1
    done

    mariadb << delim
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
delim

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shudown
    wait "$pid"
fi

exec mysqld_safe

#!/bin/bash

set -e

if [ ! -f "/var/lib/mysql/aria_log_control" ]; then
    mysqld_safe \
        --datadir=/var/lib/mysql \
        --port=3306 \
        --skip-networking &
    pid=$!

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    mariadb-admin \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown

    wait "$pid"
fi

exec mariadbd \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0 \
    --port=3306

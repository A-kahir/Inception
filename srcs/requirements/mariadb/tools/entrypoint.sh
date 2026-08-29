#!/bin/bash

set -e

if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Initializing MariaDB..."

    mariadb-install-db \
        --user=mysql \
        --datadir=/var/lib/mysql

    mysqld_safe \
        --datadir=/var/lib/mysql \
        --skip-networking &

    pid=$!

    echo "Waiting for MariaDB..."

    until mariadb-admin ping --silent; do
        sleep 1
    done

    echo "Creating database and user..."

    mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.initialized

    mariadb-admin \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        shutdown

    wait "$pid"

    echo "MariaDB initialization completed."
fi

echo "Starting MariaDB..."

exec mysqld_safe \
    --datadir=/var/lib/mysql \
    --bind-address=0.0.0.0 \
    --port=3306

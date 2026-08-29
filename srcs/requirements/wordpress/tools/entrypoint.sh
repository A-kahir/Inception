#!/bin/bash

set -e

echo "Waiting for MariaDB..."

until mariadb-admin ping \
    -h mariadb \
    -P 3306 \
    -u"$MYSQL_USER" \
    -p"$MYSQL_PASSWORD" \
    --silent
do
    echo "MariaDB is not ready yet..."
    sleep 2
done

echo "MariaDB is ready!"

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Installing WordPress..."

    wp core download \
        --allow-root \
        --path=/var/www/html

    wp config create \
        --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --path=/var/www/html

    wp core install \
        --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html

    echo "WordPress installed successfully!"
fi

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F

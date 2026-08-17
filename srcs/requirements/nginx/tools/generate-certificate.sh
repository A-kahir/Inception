#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/server.crt ] || [ ! -f /etc/nginx/ssl/server.key ]
    then
        openssl genrsa \
            -out /etc/nginx/ssl/server.key 2048

        openssl req \
            -new \
            -x509 \
            -subj "/C=MA/ST=Morocco/L=Kouribga/O=42/OU=Inception/CN=localhost"\
            -key /etc/nginx/ssl/server.key \
            -out /etc/nginx/ssl/server.crt \
            -days 365
fi

FROM debian:12

RUN apt-get update && apt-get install -y \
    nginx \
    openssl


COPY tools/generate-certificate.sh /generate-certificate.sh
COPY tools/entrypoint.sh /entrypoint.sh
COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /generate-certificate.sh /entrypoint.sh

WORKDIR /var/www/html

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
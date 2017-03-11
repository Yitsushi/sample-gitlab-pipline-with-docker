FROM alpine:3.4

MAINTAINER Balazs Nadasdi <balazs.nadasdi@cheppers.com>

RUN apk add --no-cache nginx php5-fpm supervisor
# No daemon Nginx
RUN mkdir -p /run/nginx && \
      echo "daemon off;" >> /etc/nginx/nginx.conf && \
      sed -i -e '/^$/d' -e '/^ *#/d' -e '/location/,/}/ { /.*/d }' -e '/server/,/}/ { /.*/d }' /etc/nginx/nginx.conf && \
      sed -i -e "/^http .*/a include /etc/nginx/conf.d/*.conf;" /etc/nginx/nginx.conf
# PHP
RUN sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php5/php-fpm.conf && \
      sed -i "s|^listen = .*|listen = /var/run/php5-fpm.sock|g" /etc/php5/php-fpm.conf && \
      sed -i "s|;chdir = .*|chdir = /webroot|g" /etc/php5/php-fpm.conf && \
      sed -i 's|^;listen.owner = .*|listen.owner = nginx|g' /etc/php5/php-fpm.conf && \
      sed -i 's|^;listen.group = .*|listen.group = nginx|g' /etc/php5/php-fpm.conf && \
      sed -i 's|^;listen.mode|listen.mode|g' /etc/php5/php-fpm.conf

COPY conf/nginx-app.conf /etc/nginx/conf.d/app.conf
COPY conf/supervisord.conf /etc/supervisord.conf
COPY app /webroot

EXPOSE 80

CMD ["supervisord", "-n"]

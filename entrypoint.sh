#!/bin/sh

PREFIX=/usr/local/squid

chown -R squid:squid $PREFIX
chmod a+x /entrypoint-user.sh

cat $PREFIX/etc/ssl_cert/myCA.pem \
  | sed 'H;1h;$!d;x; s/^.*\(-----BEGIN CERTIFICATE-----.*-----END CERTIFICATE-----\)\n---\nServer certificate.*$/\1/' \
  > /var/www/localhost/htdocs/squid-self-signed.crt

mini_httpd -u minihttpd -d /var/www/localhost/htdocs

su squid -s /bin/sh -c /entrypoint-user.sh
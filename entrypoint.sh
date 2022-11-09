#!/bin/sh

chown -R squid:squid /usr/local/squid
chmod a+x /entrypoint-user.sh

if [ ! -f "$PREFIX/etc/ssl_cert/myCA.pem" ]; then
  apk add openssl
fi

su squid -s /bin/sh -c /entrypoint-user.sh
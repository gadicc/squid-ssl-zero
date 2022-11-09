#!/bin/sh

PREFIX=/usr/local/squid

if [ ! -d "$PREFIX/etc" ]; then
  rm -rf $PREFIX/etc
  cp -a /etc/squid $PREFIX/etc
  sed -i 's/^http_port/# http_port/' $PREFIX/etc/squid.conf
  cat /tmp/squid-extra.conf >> $PREFIX/etc/squid.conf
  chown -R squid:squid $PREFIX/etc
fi

if [ ! -f "$PREFIX/etc/ssl_cert/myCA.pem" ]; then
  apk add openssl
  if [ -z "$KEY_SUBJ" ]; then
    KEY_SUBJ="/C=SQ/ST=Squidditch/L=Squidditch/O=Squid World/OU=IT Department/CN=squid.localhost"
  fi

  #openssl req -nodes -new -x509 -subj "$KEY_SUBJ" \
  #  -keyout signingCA.key -out signingCA.crt

  #openssl req -new -nodes -x509 -subj "$KEY_SUBJ" \
  #  -sha256 -days 36135 \
  #  -key signingCA.key -out signingCA.pem

  mkdir -p $PREFIX/etc/ssl_cert
  PEM=$PREFIX/etc/ssl_cert/myCA.pem

  openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 \
    -extensions v3_ca -keyout $PEM -out $PEM -subj "$KEY_SUBJ"
  chown squid:squid $PEM
fi

if [ ! -d "$PREFIX/logs" ]; then
  mkdir $PREFIX/logs
  chown squid:squid $PREFIX/logs
fi

if [ ! -d "$PREFIX/cache" ]; then
  mkdir $PREFIX/cache
  chown squid:squid $PREFIX/cache
  squid -f $PREFIX/etc/squid.conf -zN
fi

if [ ! -d "$PREFIX/ssl_db" ]; then
  /usr/lib/squid/security_file_certgen -c -s $PREFIX/ssl_db -M 4MB
  chown squid:squid -R $PREFIX/ssl_db
fi

sh

#!/bin/sh

PREFIX=/usr/local/squid
mkdir -p $PREFIX
cd $PREFIX

if [ ! -f "$PREFIX/etc/squid.conf" ]; then
  mkdir -p etc
  cp /etc/squid/squid.conf etc
  sed -i 's/^http_port/# http_port/' etc/squid.conf
  sed -i 's/^refresh_pattern \./# refresh_pattern ./' etc/squid.conf
  cat /tmp/squid-extra.conf >> etc/squid.conf
fi

if [ ! -f "etc/ssl_cert/myCA.pem" ]; then
  if [ -z "$KEY_SUBJ" ]; then
    KEY_SUBJ="/C=SQ/ST=Squidditch/L=Squidditch/O=Squid World/OU=IT Department/CN=squid.localhost"
  fi

  #openssl req -nodes -new -x509 -subj "$KEY_SUBJ" \
  #  -keyout signingCA.key -out signingCA.crt

  #openssl req -new -nodes -x509 -subj "$KEY_SUBJ" \
  #  -sha256 -days 36135 \
  #  -key signingCA.key -out signingCA.pem

  mkdir -p etc/ssl_cert
  PEM=etc/ssl_cert/myCA.pem

  openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 \
    -extensions v3_ca -keyout $PEM -out $PEM -subj "$KEY_SUBJ"
fi

if [ ! -d logs ]; then
  mkdir logs
fi

if [ ! -d cache ]; then
  mkdir cache
  squid -f etc/squid.conf -zN
fi

if [ ! -d ssl_db ]; then
  /usr/lib/squid/security_file_certgen -c -s ssl_db -M 4MB
fi

rm -f squid.pid
squid -f etc/squid.conf -N

# gadicc/squid-ssl-zero

*Zero-config squid caching proxy with SSL intercept (sslbump)*

Copyright (c) 2022 by Gadi Cohen <dragon@wastelands.net>.  MIT Licensed.

## Features:

  * Zero-config necessary, run immediately with `docker run`.
  * Alpine-based and super small (21 MB)
  * Squid 5 with the new SslBump: Peek and Splice.
  * squid.conf & self-signed CA cert created if missing.
  * Editable persistant volume for cache, logs, etc.
  * Mini-httpd as additional way to retrieve CA cert

Note: SSL requests will be intercepted via self-signed certificates
using the same name.  For this to work, you need to add the CA cert
wherever you need it.  Example for ubuntu/docker below.

## Usage:

```bash
$ docker run -d -p 3128:3128 -p 3129:80 \
  --name squid --restart=always \
  -v /usr/local/squid:/usr/local/squid \
  gadicc/squid-ssl-zero
```

All necessary files will be created on first run.  You can edit them
between runs.  You can also add
`-v /usr/local/squid-www:/var/www/localhost/htdocs`
if you want to add any extra files to be available via http on port 3129.

Logs are in `/usr/local/squid/logs`.

## In your other containers

Example for an Ubuntu based container, other systems may vary:

```Dockerfile
ARG http_proxy="http://172.17.0.1:3128"
ENV http_proxy=${http_proxy}
ENV https_proxy=${http_proxy}

ENV DEBIAN_FRONTEND=noninteractive

# Option 1: Retrieve CA cert via openssl (usually pre-installed)
RUN echo quit \
  | openssl s_client -proxy $(echo ${https_proxy} | cut -b 8-) -servername google.com -connect google.com:443 -showcerts \
  | sed 'H;1h;$!d;x; s/^.*\(-----BEGIN CERTIFICATE-----.*-----END CERTIFICATE-----\)\n---\nServer certificate.*$/\1/' \
  > /usr/local/share/ca-certificates/squid-self-signed.crt

# Option 2: Retrieve CA cert via http (curl, wget, etc)
RUN curl http://172.17.0.1:3129/squid-self-signed.crt |
  > /usr/local/share/ca-certificates/squid-self-signed.crt

RUN update-ca-certificates

# Useful for Python / Conda
ENV REQUESTS_CA_BUNDLE=/usr/local/share/ca-certificates/squid-self-signed.crt
```


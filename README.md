# gadicc/squid-ssl-zero

*Zero-config squid caching proxy with SSL intercept (sslbump)*

Copyright (c) 2022 by Gadi Cohen <dragon@wastelands.net>.  MIT Licensed.

## Features:

  * Zero-config necessary, run immediately with `docker run`.
  * Alpine-based and super small (21 MB)
  * Squid 5 with the new SslBump: Peek and Splice.
  * squid.conf & self-signed CA cert created if missing.
  * Editable persistant volume for cache, logs, etc.
  * Monitors `etc` directory and reloads on write events.
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

All necessary files will be created on first run (if you didn't
provide your own).  You can edit them between runs, and during
runs (the write will be detected and squid will be reloaded).

You can also add
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

# Recommended method.  See below for alternatives.
ADD http://172.17.0.1:3129/squid-self-signed.crt /usr/local/share/ca-certificates/squid-self-signed.crt
RUN update-ca-certificates

# Useful for Python / Conda
ENV REQUESTS_CA_BUNDLE=/usr/local/share/ca-certificates/squid-self-signed.crt
```

**Alternative method to retrieve the CA cert** (without the HTTP server)

```bash
echo quit \
  | openssl s_client -proxy $(echo ${https_proxy} | cut -b 8-) -servername google.com -connect google.com:443 -showcerts \
  | sed 'H;1h;$!d;x; s/^.*\(-----BEGIN CERTIFICATE-----.*-----END CERTIFICATE-----\)\n---\nServer certificate.*$/\1/' \
  > /usr/local/share/ca-certificates/squid-self-signed.crt
```

## Default Caching

You can edit this all in `/usr/local/squid/etc/squid.conf`:
(Created for you on first run if you don't provide one):

```conf
cache_dir ufs /usr/local/squid/cache 20000 16 256 # 20GB
maximum_object_size 20 GB

# REFRESH_PATTERN
# You can define these by regex, for all options see:
# http://www.squid-cache.org/Doc/config/refresh_pattern/
# Default:
refresh_pattern .		0	20%	4320
# SUPER agressive (breaks HTTP standard but can be very useful)
# refresh_pattern . 52034400 50% 52034400 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-store ignore-private refresh-ims store-stale
```

## storeid_file_rewrite

Useful when many different URLs point to the same resource (possibly
as a result of an included authentication token in the URL query
parameters).

See the [man page](https://manpages.debian.org/testing/squid/storeid_file_rewrite.8.en.html) and the example
[storeid_file_rewrite.txt](./storeid_file_rewrite.txt).
The file is automatically reloaded on save.

Testing:

```bash
$ docker exec -it <containerId> /bin/sh
$ cd /usr/lib/squid
$ URL='https://cdn-lfs.huggingface.co/repos/24/cb/24cbc2f7542236eb613b4f16b6802d7c2bef443e86cf9d076719733866e66c3a/f2a06cf32cf585d03b55fef302142a5321b761ec440113925f64f4ceaffc7730?some-irrelevent-query'
$ echo $URL | ./storeid_file_rewrite /usr/local/squid/etc/storeid_file_rewrite.txt
OK store-id=https://cdn-lfs.huggingface.co/repos/24/cb/24cbc2f7542236eb613b4f16b6802d7c2bef443e86cf9d076719733866e66c3a/f2a06cf32cf585d03b55fef302142a5321b761ec440113925f64f4ceaffc7730
```

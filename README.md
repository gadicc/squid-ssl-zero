# gadicc/squid-sslbump

*One-shot container with SSL caching*

Copyright (c) 2022 by Gadi Cohen <dragon@wastelands.net>.  MIT Licensed.

## Features:

  * Zero-config necessary, run immediately with `docker run`.
  * Alpine-based and super small.
  * Volume used for etc, cache, logs, etc.

## Usage:

```bash
$ docker run -v /usr/local/squid:/usr/local/squid \
  -it -p 3128:3128 gadicc/squid-ssl-zero
```

All necessary files will be created on first run.  You can edit them
between runs.

## In your other containers

```
ARG http_proxy="http://172.17.0.1:3128"
ENV http_proxy=${http_proxy}
ENV https_proxy=${http_proxy}

ENV DEBIAN_FRONTEND=noninteractive

RUN echo quit | openssl s_client -proxy $(echo ${http_proxy} | cut -b 8-) -showcerts -servername google.com -connect google.com:443 > cacert.pem
RUN update-ca-certificates
```


FROM alpine:latest

RUN apk add squid
RUN apk add openssl
RUN apk add mini_httpd
RUN apk add perl

ADD squid-extra.conf /tmp
ADD entrypoint.sh /root
ADD entrypoint-user.sh /
ENTRYPOINT [ "sh", "/root/entrypoint.sh" ]
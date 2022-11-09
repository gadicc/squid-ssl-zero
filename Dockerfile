FROM alpine:latest

RUN apk add squid

ADD squid-extra.conf /tmp
ADD entrypoint.sh /root
ADD entrypoint-user.sh /
ENTRYPOINT [ "sh", "/root/entrypoint.sh" ]
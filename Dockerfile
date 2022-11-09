FROM alpine:latest

RUN apk add squid

ADD squid-extra.conf /tmp
ADD entrypoint.sh /
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
FROM alpine:3.10

ENV VERSION=4.0.6

ENV CONFFILE="/etc/GeoIP.conf"

ENV AccountID=0
ENV LicenseKey=000000000000
ENV EditionIDs="GeoLite2-Country GeoLite2-City"
ENV DatabaseDirectory="/usr/local/share/GeoIP"
ENV PreserveFileTimes="0"
ENV LockFile="${DatabaseDirectory}/.geoipupdate.lock"
ENV Proxy=""
ENV ProxyUserPassword=""

ENV CRON_SCHEDULE="35 12 * * *"

COPY entrypoint.sh /entrypoint.sh

RUN apk add --update --no-cache ca-certificates \
 && apk add --update --no-cache --virtual .build-deps \
        build-base \
        git \
        go \
        perl \
 && cd /tmp \
 && git clone -b v${VERSION} https://github.com/maxmind/geoipupdate.git \
 && cd geoipupdate \
 && make build/geoipupdate \
 && cp build/geoipupdate /usr/local/bin/geoipupdate \
 && strip /usr/local/bin/geoipupdate \
 && rm -rf /tmp/* \
 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
 && addgroup -g 101 -S geoip \
 && adduser -u 101 -D -S -G geoip geoip

ENTRYPOINT [ "sh", "/entrypoint.sh" ]

CMD [ "/usr/sbin/crond", "-f" ]
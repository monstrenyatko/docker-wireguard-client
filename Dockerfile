FROM alpine:3

LABEL maintainer="Oleg Kovalenko <monstrenyatko@gmail.com>"

RUN apk update && apk upgrade && \
    apk add --no-cache curl shadow iptables ip6tables wireguard-tools && \
    rm -rf /root/.cache && mkdir -p /root/.cache && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# remove sysctls call from the wg-quick script to avoid `--privilege` option
# required run option `--sysctls net.ipv4.conf.all.src_valid_mark=1` to keep same functionality
COPY wg-quick.patch /
RUN buildDeps='patch'; \
    apk add --no-cache $buildDeps && \
    patch --verbose -p0 < /wg-quick.patch && \
    apk del $buildDeps && \
    rm -rf /root/.cache && mkdir -p /root/.cache && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

COPY run.sh firewall.sh firewall6.sh routing.sh routing6.sh /
RUN chmod +x /run.sh /firewall.sh /firewall6.sh /routing.sh /routing6.sh

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
    CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/run.sh"]
CMD ["vpnc-app"]

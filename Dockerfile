FROM monstrenyatko/alpine:2024-06-01

LABEL maintainer="Oleg Kovalenko <monstrenyatko@gmail.com>"

RUN apk update && \
    apk add iptables ip6tables wireguard-tools && \
    # clean-up
    rm -rf /root/.cache && mkdir -p /root/.cache && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# remove sysctls call from the wg-quick script to avoid `--privilege` option
# required run option `--sysctls net.ipv4.conf.all.src_valid_mark=1` to keep same functionality
COPY wg-quick.patch /
RUN buildDeps='patch'; \
    apk add $buildDeps && \
    patch --verbose -p0 < /wg-quick.patch && \
    # clean-up
    apk del $buildDeps && \
    rm -rf /root/.cache && mkdir -p /root/.cache && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

ENV APP_NAME="vpnc-app"

COPY run.sh firewall.sh firewall6.sh routing.sh routing6.sh /app/
RUN chown -R root:root /app
RUN chmod -R 0644 /app
RUN find /app -type d -exec chmod 0755 {} \;
RUN find /app -type f -name '*.sh' -exec chmod 0755 {} \;

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
    CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/app/run.sh"]
CMD ["vpnc-app"]

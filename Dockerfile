FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/dashboard:v0.1.50@sha256:804a2b35799147cf9aa6bad7374568be516b2b4ffbee0831a7a47ab15d5dfb4d as builder

FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/tdexd:v0.9.0@sha256:77729e6c0019752059cc5bf624675e261abd8b856e0a7e8f59889b7ec0a35eb3

## Dashaboard 
##
ENV USE_PROXY "false"
ENV IS_PACKAGED "true"

## Daemon 
##
ENV TDEX_LOG_LEVEL 5
ENV TDEX_EXPLORER_ENDPOINT https://liquid.network/liquid/api
ENV TDEX_OPERATOR_LISTENING_PORT 9090
ENV TDEX_TRADE_LISTENING_PORT  9090
ENV TDEX_NO_OPERATOR_TLS "true"
ENV TDEX_CONNECT_PROTO http

USER root

RUN apt-get update && apt-get install -y tini wget 
RUN wget https://github.com/mikefarah/yq/releases/download/v4.12.2/yq_linux_arm.tar.gz -O - |\
    tar xz && mv yq_linux_arm /usr/bin/yq


RUN mkdir -p /patch/
RUN mkdir -p /usr/share/caddy/
RUN mkdir -p /root/.tdex-daemon/

COPY --from=builder /patch/web-entrypoint.sh /patch/web-entrypoint.sh
COPY --from=builder /usr/share/caddy/ /usr/share/caddy/
COPY --from=builder /usr//bin/caddy /usr//bin/caddy
COPY --from=builder /config/caddy/ /config/caddy/
COPY --from=builder /data/caddy/ /data/caddy/
# Override the Caddyfile of the dashaboard image  
ADD Caddyfile /etc/caddy/Caddyfile

ADD docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/dashboard:v0.1.43@sha256:55f482c26bf2f5907dde9ce8309fa8c183cedac5f4028924099ab85e85f22a53 as builder

FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/tdexd:v0.8.19@sha256:5a2c0db9f74812e67aa98f50f396e81edd23ef49cb6797b084027ba6124db707

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

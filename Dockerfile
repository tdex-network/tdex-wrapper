FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/dashboard:v0.1.36@sha256:57bc9a2d1a4db7dfe4208de6bbec9edbfaad69133ef80c788a984466b9ebbc90 as builder

FROM --platform=linux/arm64/v8 ghcr.io/tdex-network/tdexd:v0.8.17@sha256:10c648982648c71c7c31456c1fc64a3f5c03763a1879cc926e321cd6081c2415

ENV USE_PROXY "false"
ENV IS_PACKAGED "true"
ENV TDEX_DAEMON_URL "tdex.embassy:9090"

ENV TDEX_LOG_LEVEL 5
ENV TDEX_EXPLORER_ENDPOINT https://liquid.network/liquid/api
ENV TDEX_OPERATOR_LISTENING_PORT 9090
ENV TDEX_TRADE_LISTENING_PORT  9090
ENV TDEX_NO_OPERATOR_TLS "true"
ENV TDEX_CONNECT_ADDR "tdex.embassy:9090"
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
COPY --from=builder /etc/caddy/ /etc/caddy/
COPY --from=builder /config/caddy/ /config/caddy/
COPY --from=builder /data/caddy/ /data/caddy/

ADD docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

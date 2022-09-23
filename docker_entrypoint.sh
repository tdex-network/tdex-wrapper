#!/bin/sh

set -e

export TDEX_DAEMON_URL=$(yq e '.tor-address' /root/start9/config.yaml):9090
export TDEX_CONNECT_ADDR=$(yq e '.tor-address' /root/start9/config.yaml):9090

echo 'Starting TDEX Daemon...'
tdexd &

echo 'Starting TDEX Dashboard...'
../patch/web-entrypoint.sh
exec tini -p SIGTERM -- caddy run --config /etc/caddy/Caddyfile --adapter caddyfile 

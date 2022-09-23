#!/bin/sh

set -e

echo 'Starting TDEX Daemon...'
tdexd &

echo 'Starting TDEX Dashboard...'
../patch/web-entrypoint.sh
exec tini -p SIGTERM -- caddy run --config /etc/caddy/Caddyfile --adapter caddyfile 

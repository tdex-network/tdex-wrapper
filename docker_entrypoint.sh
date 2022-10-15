#!/bin/sh

set -e
# turn on bash's job control
set -m
  
export TRADER_HIDDEN_SERVICE=$(yq e '.tor-address' /root/start9/config.yaml):9090
export TDEX_CONNECT_ADDR=$(yq e '.tor-address' /root/start9/config.yaml):9090

# Start the primary process and put it in the background
echo 'Starting TDEX Daemon...'
tdexd &
  
# Start the helper process
echo 'Starting TDEX Dashboard...'
../patch/web-entrypoint.sh
exec tini -p SIGTERM -- caddy run --config /etc/caddy/Caddyfile --adapter caddyfile 

  
# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns
  
# now we bring the primary process back into the foreground
# and leave it there
fg %1
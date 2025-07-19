#!/usr/bin/env sh
set -e

# 1) start the CMP sidecar in the background, pointing at your baked-in config/plugin.yaml
/usr/local/bin/argocd-cmp-server avp \
    --config-dir-path=/home/argocd/cmp-server/config \
    --socket-path=/home/argocd/cmp-server/plugins/avp-v1.sock &

# 2) now replace this process with the real repo-server
exec /usr/local/bin/argocd repo-server "$@"
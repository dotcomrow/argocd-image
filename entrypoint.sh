#!/usr/bin/env sh
# launch CMP server in background, binding its socket
exec /var/run/argocd/argocd-cmp-server avp \
  --config-dir-path=/home/argocd/cmp-server/config \
  --socket-path=/home/argocd/cmp-server/plugins/avp.sock &

# now run the real repo-server
exec argocd-repo-server "$@"

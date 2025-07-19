#!/usr/bin/env sh
set -e

# 1) launch the CMP plugin server in the background
#    'avp-v1' must match your plugin.yaml metadata.name
/usr/local/bin/argocd-cmp-server avp-v1 &

# 2) now replace this shell with the real repo-server process
exec /usr/local/bin/argocd-repo-server "$@"

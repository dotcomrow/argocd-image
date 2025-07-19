FROM quay.io/argoproj/argocd:v2.8.2

USER root


# now apt will work on both amd64 and arm64
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl ca-certificates awscli gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install AVP
ENV AVP_VERSION=1.18.1
RUN curl -sL \
    https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 \
      -o /usr/local/bin/argocd-vault-plugin && \
    chmod +x /usr/local/bin/argocd-vault-plugin

# prepare plugin dirs
RUN mkdir -p /home/argocd/cmp-server/config /home/argocd/cmp-server/plugins && \
    chown -R 999:999 /home/argocd/cmp-server

# build our entrypoint
RUN cat << 'EOF' > /usr/local/bin/entrypoint.sh
#!/usr/bin/env sh
# launch cmp-server in background, binding its socket
exec /var/run/argocd/argocd-cmp-server avp \
  --config-dir-path=/home/argocd/cmp-server/config \
  --socket-path=/home/argocd/cmp-server/plugins/avp.sock &

# now hand off to the real repo-server
exec argocd-repo-server "$@"
EOF
RUN chmod +x /usr/local/bin/entrypoint.sh

USER 999

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["argocd-repo-server"]
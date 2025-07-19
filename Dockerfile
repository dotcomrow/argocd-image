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

# 3) Copy your plugin.yaml into the baked config dir
COPY --chown=999:999 plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

# 4) Entrypoint: start CMP sidecar then repo-server
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER 999

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["argocd-repo-server"]
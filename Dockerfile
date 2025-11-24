FROM quay.io/argoproj/argocd:v3.2.0

# Switch to root to install tools and AVP
USER root

# Install utilities (curl, certs, awscli, gpg) if you need them for other plugins/hooks
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      ca-certificates \
      awscli \
      gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Argo CD Vault Plugin (AVP)
ENV AVP_VERSION=1.18.1
RUN curl -sL \
      "https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64" \
      -o /usr/local/bin/argocd-vault-plugin && \
    chmod +x /usr/local/bin/argocd-vault-plugin

# Wire up the CMP plugin definition and entrypoint
RUN mkdir -p /home/argocd/cmp-server/config /home/argocd/cmp-server/plugins
COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml
COPY entrypoint.sh /usr/local/bin/cmp-entrypoint.sh
RUN chmod 755 /usr/local/bin/cmp-entrypoint.sh && \
    chown -R 999:999 /home/argocd/cmp-server

# Drop back to the argocd user (UID 999) as expected by Argo CD
USER 999

# Start Tini -> cmp server -> repo server
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/cmp-entrypoint.sh"]
CMD ["/usr/local/bin/argocd-repo-server"]

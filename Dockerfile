FROM argoproj/argocd:v2.7.9

# Switch to root so we can install packages
USER root

# Install curl, awscli, gpg + certs, then clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl ca-certificates awscli gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the Argo CD Vault Plugin
ENV AVP_VERSION=1.18.1
RUN curl -sL \
    https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64 \
    -o /usr/local/bin/argocd-vault-plugin && \
    chmod +x /usr/local/bin/argocd-vault-plugin

# Pre-create the CMP socket dir and chown to argocd:argocd (UID/GID 999)
RUN mkdir -p /home/argocd/cmp-server/plugins && \
    chown -R 999:999 /home/argocd/cmp-server

# Drop back to the unprivileged ArgoCD user
USER 999

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

# Drop back to the argocd user (UID 999) as expected by Argo CD
USER 999

# IMPORTANT:
# - Do NOT override ENTRYPOINT or CMD.
# - The base image already starts argocd-repo-server.
# - Argo CD will invoke /usr/local/bin/argocd-vault-plugin according to your
#   configManagementPlugins definition in argocd-cm.

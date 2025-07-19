FROM quay.io/argoproj/argocd:v2.7.9

USER root

# Install curl and download AVP
RUN apk add --no-cache curl \
 && curl -sL \
      https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v1.18.1/argocd-vault-plugin_1.18.1_linux_amd64 \
      -o /usr/local/bin/argocd-vault-plugin \
 && chmod +x /usr/local/bin/argocd-vault-plugin

# Create plugin socket dir with correct permissions
RUN mkdir -p /home/argocd/cmp-server/plugins \
 && chown -R 999:999 /home/argocd/cmp-server

USER 999

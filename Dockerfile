FROM argoproj/argocd:latest

USER root

# redirect all of Impish's dead endpoints to old-releases
RUN sed -i \
      -e 's|http://archive.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' \
      -e 's|http://security.ubuntu.com/ubuntu|http://old-releases.ubuntu.com/ubuntu|g' \
      -e 's|http://ports.ubuntu.com/ubuntu-ports|http://old-releases.ubuntu.com/ubuntu|g' \
    /etc/apt/sources.list

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

# prep CMP socket dir
RUN mkdir -p /home/argocd/cmp-server/plugins && \
    chown -R 999:999 /home/argocd/cmp-server

USER 999

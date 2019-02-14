FROM node:10-alpine

ENV HUB_VERSION 2.9.0
ENV MANPATH /share/man
ENV MANPAGER /usr/bin/less

RUN apk add --no-cache ca-certificates git libc6-compat jq man
ADD https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz /hub.tgz
RUN tar -C / --strip 1 -xzf /hub.tgz

# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.4.9
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

ARG NODE_VERSION=26.0.0
ARG YARN_VERSION=1.22.22

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/node/bin:${PATH}
ENV BUNDLE_PATH=/usr/local/bundle

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      ca-certificates \
      curl \
      git \
      libsqlite3-dev \
      libvips \
      libyaml-dev \
      netcat-openbsd \
      pkg-config \
      python-is-python3 \
      sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Node + Yarn to match project runtime versions.
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@${YARN_VERSION} && \
    rm -rf /tmp/node-build-master

WORKDIR /workspaces/boxwalker


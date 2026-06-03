FROM ruby:3.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libsqlite3-dev \
    nodejs \
    npm \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler rails

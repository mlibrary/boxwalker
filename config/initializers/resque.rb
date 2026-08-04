# frozen_string_literal: true

# config/initializers/resque.rb
require "resque"

Resque.redis = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
Resque.redis.namespace = "resque:boxrunner"

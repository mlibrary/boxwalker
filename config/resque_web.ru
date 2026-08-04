# frozen_string_literal: true

# Rackup config for the Resque dashboard (Resque::Server).
#
# We run the dashboard directly via `rackup`/Puma instead of the `resque-web`
# binary, because resque 2.7's WebRunner relies on the old `Rack::Handler` API
# that was removed in Rack 3.
#
#   bundle exec rackup -o 0.0.0.0 -p 5678 config/resque_web.ru
require "resque"
require "resque/server"

Resque.redis = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
Resque.redis.namespace = ENV.fetch("RESQUE_NAMESPACE", "resque:boxrunner")

run Resque::Server.new

#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", File.dirname(__FILE__))
BASE_COMPOSE_PATH = File.join(ROOT, "compose.yml")
OVERRIDE_COMPOSE_PATH = File.join(ROOT, ".devcontainer", "docker-compose.yml")
DEVCONTAINER_JSON_PATH = File.join(ROOT, ".devcontainer", "devcontainer.json")

errors = []

base_compose = YAML.load_file(BASE_COMPOSE_PATH)
override_compose = YAML.load_file(OVERRIDE_COMPOSE_PATH)
devcontainer = JSON.parse(File.read(DEVCONTAINER_JSON_PATH))

base_services = (base_compose["services"] || {}).keys
override_services = (override_compose["services"] || {}).keys

required_base_services = %w[app solr zookeeper]
missing_base_services = required_base_services - base_services
unless missing_base_services.empty?
  errors << "Base compose is missing required services: #{missing_base_services.join(", ")}"
end

unless override_services == ["app"]
  errors << "Devcontainer override must define only the app service; found: #{override_services.join(", ")}"
end

compose_files = Array(devcontainer["dockerComposeFile"])
expected_compose_files = ["../compose.yml", "docker-compose.yml"]
unless compose_files == expected_compose_files
  errors << "devcontainer.json dockerComposeFile must be #{expected_compose_files.inspect}; found: #{compose_files.inspect}"
end

if errors.empty?
  puts "Devcontainer sync check passed"
  exit 0
end

warn "Devcontainer sync check failed:"
errors.each { |error| warn "- #{error}" }
exit 1



# frozen_string_literal: true

require "net/http"

module Solr
  class BuildSuggest
    def self.call
      base_uri = ENV.fetch("SOLR_URL", Blacklight.default_index.connection.base_uri).to_s.chomp("/")
      uri = URI("#{base_uri}/suggest?suggest.build=true")

      ::Net::HTTP.start(uri.host, uri.port) do |http|
        http.read_timeout = 600
        response = http.request_get(uri.path, "Accept" => "application/json")
        response.value # raises exception if not 2XX status
        puts response.body
      end
    end
  end
end

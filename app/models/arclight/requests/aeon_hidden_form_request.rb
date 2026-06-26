# frozen_string_literal: true

module Arclight
  module Requests
    ##
    # This class should be used to turn configuration into a URL and
    # POST form specifically aimed at Aeon's external request
    # endpoint (https://support.atlas-sys.com/hc/en-us/articles/360011820054-External-Request-Endpoint)
    class AeonHiddenFormRequest
      def initialize(document, presenter)
        @document = document
        @presenter = presenter
      end

      def config
        @config ||= @document.repository_config.request_config_for_type("aeon_hidden_form_request")
      end

      def url
        config["request_url"].to_s
      end

      def form_mapping
        static_mappings.merge(dynamic_mappings).merge(transform_mappings)
      end

      def static_mappings
        config["request_mappings"]["static"]
      end

      def dynamic_mappings
        config["request_mappings"]["accessor"].transform_values do |v|
          @document.send(v.to_sym)
        end
      end

      def transform_mappings
        config["request_mappings"]["transform"].transform_values do |v|
          raw = @document.send(v["field"].to_sym)
          matched = raw.match(v["regex"])
          matched[1]
        end
      end

      def url_params
        config["request_mappings"]["url_params"].to_query
      end
    end
  end
end

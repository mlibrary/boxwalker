# frozen_string_literal: true

module Arclight
  module Requests
    class AeonWebEad
      attr_reader :document, :ead_url

      def initialize(document, ead_url)
        @document = document
        @ead_url = ead_url
      end

      def request_url
        request_config["request_url"]
      end

      def url
        "#{request_url}?#{form_mapping.to_query}"
      end

      def parsed_ead_url
        request_id = document.repository_config.try(:request_id)
        return ead_url unless request_id&.key?("prefix")

        value = document.request_field(request_id.fetch("field"))
        pattern = request_id["pattern"]
        match = Regexp.new(pattern).match(value) if pattern
        value = match[1] if match

        "#{request_id['prefix']}#{value}#{request_id['postfix']}"
      end

      def form_mapping
        form_hash = Rack::Utils.parse_nested_query(request_config["request_mappings"])
        form_hash.transform_values { |value| respond_to?(value) ? public_send(value) : value }
      end

      private

      def request_config
        document.repository_config.request_config_for_type("aeon_web_ead")
      end
    end
  end
end

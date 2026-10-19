# frozen_string_literal: true

module VideoEmbed
  module Kaltura
    PARTNER_ID  = '1758271'
    UICONF_ID   = '56928822' # PlayKit (v7) player, same one MiVideo uses
    PLAYER_HOST = 'https://cdnapisec.kaltura.com'
    HOSTS       = %w[kaltura.com mivideo.it.umich.edu].freeze
    # Host itself or any subdomain.
    HOST_PATTERN = /(?:\A|\.)(?:#{HOSTS.map { |h| Regexp.escape(h) }.join('|')})\z/i
    ENTRY_ID_PATTERN = /\A\d_[a-z0-9]{8}\z/i
    module_function
    def entry_id(href)
      uri = VideoEmbed.parse_http_uri(href)
      return unless uri&.host&.match?(HOST_PATTERN)
      [query_entry_id(uri), *uri.path.to_s.split('/')]
        .find { |s| s&.match?(ENTRY_ID_PATTERN) }
    end
    def embed_url(href)
      id = entry_id(href)
      return unless id
      query = { iframeembed: true, entry_id: id }.to_query
      "#{PLAYER_HOST}/p/#{PARTNER_ID}/embedPlaykitJs/uiconf_id/#{UICONF_ID}?#{query}"
    end
    def query_entry_id(uri)
      URI.decode_www_form(uri.query.to_s).to_h['entry_id']
    rescue ArgumentError # bad percent-encoding
      nil
    end
  end
end

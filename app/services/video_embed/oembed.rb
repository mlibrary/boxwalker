# frozen_string_literal: true

require "open-uri"
require "json"

module VideoEmbed
  # Looks up oEmbed HTML for a URL by reading the page's <head> for an
  # oEmbed discovery link. Results (including "nothing found") are cached.
  module Oembed
    LINK_SELECTOR = 'link[rel="alternate"][type="application/json+oembed"]'
    TIMEOUT = 3
    CACHE_TTL = 1.day
    ALLOWED_TAGS = %w[iframe blockquote p a div span br strong em img].freeze
    ALLOWED_ATTRIBUTES = %w[src href width height title allow allowfullscreen loading class].freeze
    # Returns sanitized embed HTML (String) or nil.
    def self.html_for(href)
      uri = VideoEmbed.parse_http_uri(href) or return
      key = "video_embed/oembed/#{Digest::SHA256.hexdigest(uri.to_s)}"
      Rails.cache.fetch(key, expires_in: CACHE_TTL) { fetch(uri).to_s }.presence
    end

    def self.fetch(uri)
      page = read(uri)
      href = Nokogiri::HTML(page).at_css(LINK_SELECTOR)&.[]("href") or return
      endpoint = URI.join(uri.to_s, href)
      html = JSON.parse(read(endpoint))["html"]
      Rails::Html::SafeListSanitizer.new
                                    .sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
                                    .presence if html.is_a?(String)
    rescue StandardError => e
      Rails.logger.warn("[VideoEmbed::Oembed] #{uri}: #{e.class}: #{e.message}")
      nil
    end

    private_class_method :fetch
    # open-uri follows redirects and raises on HTTP errors (rescued above).
    def self.read(uri)
      uri.open(open_timeout: TIMEOUT, read_timeout: TIMEOUT).read
    end

    private_class_method :read
  end
end

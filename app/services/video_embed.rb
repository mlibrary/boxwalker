# frozen_string_literal: true

module VideoEmbed
  # URI::HTTPS < URI::HTTP, this accepts both schemes.
  def self.parse_http_uri(href)
    uri = URI.parse(href.to_s.strip)
    uri if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end
end


module QuodHelper
  QUOD_HOST = "quod.lib.umich.edu"

  IMAGE_CLASS_PATTERN =
    %r{quod\.lib\.umich\.edu/[a-z]/(\w+)/(x-[^/?#]+)/([^/?#]+)}

  TEXT_CLASS_PATTERN =
    %r{quod\.lib\.umich\.edu/[a-z]/(\w+)/([^/?#]+)/(\d+)}

  def quod_embed_url(href)
    return if href.blank?
    return unless href.include?(QUOD_HOST)

    return href if href.include?("/api/embed/")

    case href
    when IMAGE_CLASS_PATTERN
      collid, idno, filename = Regexp.last_match.captures
      "https://#{QUOD_HOST}/cgi/i/image/api/embed/#{collid}:#{idno}:#{filename}"
    when TEXT_CLASS_PATTERN
      collid, idno, seq = Regexp.last_match.captures
      "https://#{QUOD_HOST}/cgi/t/text/api/embed/#{collid}:#{idno}:#{seq}"
    end
  end
end
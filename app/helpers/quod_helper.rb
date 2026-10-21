module QuodHelper
  QUOD_HOST = "quod.lib.umich.edu".freeze

  # /b/bhl/x-bl000001/bl000001
  IMAGE_CLASS_PATH =
    %r{\A/[a-z]/(?<collid>\w+)/(?<idno>x-[^/]+)/(?<filename>[^/]+)/?\z}

  # /m/micounty/bad0872.0001.001/5
  TEXT_CLASS_PATH =
    %r{\A/[a-z]/(?<collid>\w+)/(?<idno>[^/]+)/(?<seq>\d+)/?\z}

  def quod_embed_url(href)
    return if href.blank?

    uri = begin
            URI.parse(href.strip)
          rescue URI::InvalidURIError
            return
          end

    return unless uri.host&.casecmp?(QUOD_HOST)

    path = uri.path.to_s
    return uri.to_s if path.include?("/api/embed/")

    if (m = IMAGE_CLASS_PATH.match(path))
      "https://#{QUOD_HOST}/cgi/i/image/api/embed/#{m[:collid]}:#{m[:idno]}:#{m[:filename]}"
    elsif (m = TEXT_CLASS_PATH.match(path))
      "https://#{QUOD_HOST}/cgi/t/text/api/embed/#{m[:collid]}:#{m[:idno]}:#{m[:seq]}"
    end
  end
end

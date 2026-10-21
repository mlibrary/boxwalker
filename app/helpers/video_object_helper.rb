# frozen_string_literal: true

module VideoObjectHelper
  def kaltura_embed_url(href)
    VideoEmbed::Kaltura.embed_url(href)
  end

  def kaltura_iframe_tag(embed_url, title: nil)
    tag.iframe(
      "",
      src: embed_url,
      title: title.presence || "Media player",
      allow: "autoplay; fullscreen; encrypted-media",
      allowfullscreen: true,
      loading: "lazy",
      class: "kaltura-embed-iframe",
      style: "width: 100%; aspect-ratio: 16 / 9; height: auto; border: 0;"
    )
  end

  def oembed_html(href)
    VideoEmbed::Oembed.html_for(href)&.html_safe # already sanitized
  end
end

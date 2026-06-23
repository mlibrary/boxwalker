module HomepageHelper
  def config_features
    @config_features ||= begin
                           YAML.safe_load(::File.read(config_filename))
                         rescue Errno::ENOENT
                           {}
                         end
  end

  def config_filename
    Rails.root.join("config", "featured_images.yml")
  end

  def random_feature
    img_index = config_features["image_list"].keys.sample
    config_features["image_list"][img_index]
  end

  # Image can be an absolute URL to any external image, or alternatively,
  # a name of a local file within assets/images/homepage
  def feature_img_url(image)
    return image if image.match(/^#{URI.regexp(%w[http https])}$/)

    image_url([ "homepage", image ].join("/"))
  end

  def collection_count_home
    search_service = Blacklight.repository_class.new(blacklight_config)
    query = search_service.search(
      q: "level_ssim:Collection",
      rows: 1
    )
    query.response["numFound"]
  end
end

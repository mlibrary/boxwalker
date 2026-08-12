# frozen_string_literal: true

module UmArclightHelper
  # Shorthand to distinguish the homepage among other index presenter driven pages
  def homepage?
    current_page?(root_path) && !has_search_parameters?
  end

  def formatted_last_indexed(timestamp)
    date = DateTime.parse(timestamp)
    date.strftime("%F")
  end

  SKIPPABLE_KEYS = [
    "containers",
    "physdesc_tesim",
    "creators_ssim",
    "abstract_tesim",
    "scopecontent_tesim",
    "note_tesim",
    "odd_tesim"
  ]
  def is_interesting_component?(document)
    blacklight_config.component_fields.keys.find do |key|
      SKIPPABLE_KEYS.exclude?(key) && document.fetch(key, nil).present?
    end || document.is_linkable?
  end
end

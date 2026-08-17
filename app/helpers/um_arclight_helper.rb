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

  # Keys are the display keys registered in the Blacklight config.
  # Fields are the Solr document keys associated with the display keys.
  SKIPPABLE_KEYS = [
    "physdesc",
    "creators",
    "abstract",
    "scopecontent",
    "extent",
    "note",
    "odd"
  ]
  def is_interesting_component?(document)
    blacklight_config.component_fields.find do |key, field_config|
      SKIPPABLE_KEYS.exclude?(field_config.key) && document.fetch(field_config.field, nil).present?
    end || document.is_linkable?
  end
end

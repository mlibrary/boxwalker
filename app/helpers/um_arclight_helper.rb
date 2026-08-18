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


  # Render an html <title> appropriate string for a set of search parameters, based on local requirements
  #
  # @param search_state_or_params [Blacklight::SearchState, ActionController::Parameters]
  # @return [String]
  # Adapted from https://github.com/projectblacklight/blacklight/blob/main/app/helpers/blacklight/catalog_helper_behavior.rb#L151
  def render_search_as_breadcrumbs_to_page_title(search_state_or_params)
    search_state = if search_state_or_params.is_a? Blacklight::SearchState
      search_state_or_params
    else
      controller.search_state_class.new(params, blacklight_config, self)
    end

    constraints = []
    suffixes = []
    prefix = t("blacklight.search.page_title.prefix")
    add_prefix = true

    if search_state.query_param.present?
      unless search_state.search_field&.key.blank? || default_search_field?(search_state.search_field.key)
        q_label = label_for_search_field(search_state.search_field.key)
      end

      constraints += if q_label.present?
        [ t("blacklight.search.page_title.constraint", label: q_label, value: search_state.query_param) ]
      else
        [ search_state.query_param ]
      end
    end

    if search_state.filters.any?
      repository = collection = nil
      has_level_collection = false

      search_state.filters.each do |filter|
        if filter.key == "repository"
          repository = filter.values.first
        elsif filter.key == "collection"
          collection = filter.values.first
        elsif filter.key == "level"
          has_level_collection = filter.values.first == "Collection"
        else
          constraints << render_search_to_page_title_filter(filter.key, filter.values)
        end
      end
      suffixes << repository unless repository.nil?
      if collection.nil?
        suffixes.unshift "Collections" if has_level_collection && suffixes.present?
      else
        suffixes.unshift collection
        add_prefix = constraints.present?
      end
    end

    title = []
    title += [ constraints.join(t('blacklight.search.page_title.joiner')) ] unless constraints.empty?
    unless suffixes.empty?
      title << "-" unless title.empty?
      title << suffixes.join(" - ")
    end
    title.unshift prefix if add_prefix
    title.join(" ")
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

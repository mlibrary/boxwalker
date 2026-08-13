# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def component?
    parent_ids.present?
  end

  def physloc
    fetch("collection_physloc_tesim", [])[0]
  end

  def collection_date
    fetch("collection_date_inclusive_ssm", [])[0]
  end

  def collection_creator
    fetch("collection_creator_ssm", [])[0]
  end

  def repository_id
    repository_config&.slug
  end

  def has_online_content?
    online_content?
  end

  def restrictions
    fetch("accessrestrict_html_tesm", [])[0]
  end

  def accessrestrict
    fetch("accessrestrict_tesim", [])
  end

  def userestrict
    fetch("userestrict_tesim", [])
  end

  def phystech
    fetch("phystech_tesim", [])
  end

  def restricted_component?
    component? && (accessrestrict.present? || userestrict.present? || phystech.present?)
  end

  def document_id
    fetch("ead_ssi", nil)&.strip
  end

  def is_linkable?
    online_content? || number_of_children > 0 || restricted_component?
  end

  def collection_has_requestable_components?
    repository_config.request_config_present_for_type?("aeon_hidden_form_request")
  end

  def container_types
    fetch("container_types_ssim", [])
  end

  def is_checkbox_requestable?
    config_present = repository_config.request_config_present_for_type?("aeon_hidden_form_request")
    container_requestable = container_types.any? do |container_type|
      %w[box folder reel map-case tube object volume bundle].any? do |type|
        container_type.casecmp(type) == 0
      end
    end
    config_present && !container_types.empty? && container_requestable
  end

  # TODO: should the Aeon stuff live in a separate class?
  def aeon_item_sub_title_value
    subtitle = ActionController::Base.helpers.strip_tags(normalized_title)
    subtitle += " (#{extent})" if extent
    subtitle
  end

  def aeon_item_sub_title_visually_hidden
    aeon_item_sub_title_value
  end

  def aeon_item_volume_value
    containers.join(", ")
  end

  def aeon_item_citation_value
    reference  # May need to fall back to the ID
  end

  def aeon_item_info_1_value
    accessrestrict
  end
end

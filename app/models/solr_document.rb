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
    fetch("has_online_content_ssim", [])[0]
  end

  def restrictions
    fetch("accessrestrict_html_tesm", [])[0]
  end

  def document_id
    fetch("ead_ssi", nil)&.strip
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

end

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
end

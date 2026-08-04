# frozen_string_literal: true

# Rebuild the Solr suggester index
# https://lucene.apache.org/solr/guide/8_0/suggester.html
class BuildSuggestJob < ApplicationJob
  queue_as :index

  def perform
    Solr::BuildSuggest.call
  end
end

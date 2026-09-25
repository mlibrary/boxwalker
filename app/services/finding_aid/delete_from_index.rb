# frozen_string_literal: true

module FindingAid
  class DeleteFromIndex
    def self.call(document_id)
      connection = Blacklight.default_index.connection
      connection.delete_by_query("_root_:#{RSolr.solr_escape(document_id)}")
      connection.commit
    end
  end
end

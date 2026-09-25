# frozen_string_literal: true

module FindingAid
  class DeleteFromIndex
    def self.call(finding_aid_id)
      connection = Blacklight.default_index.connection
      normalized_id = UmArclight::NormalizedId.new(finding_aid_id).to_s
      connection.delete_by_query("_root_:#{RSolr.solr_escape(normalized_id)}")
      connection.commit
    end
  end
end

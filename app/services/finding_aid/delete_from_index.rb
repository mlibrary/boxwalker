# frozen_string_literal: true
require "rsolr"

module FindingAid
  class DeleteFromIndex
    def self.call(eadid)
      escaped_eadid = RSolr.solr_escape(eadid)
      connection = Blacklight.default_index.connection
      connection.delete_by_query("_root_:#{escaped_eadid}")
      connection.delete_by_query("id:#{escaped_eadid}")
      connection.commit
    end
  end
end

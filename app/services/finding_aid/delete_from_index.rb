# frozen_string_literal: true

module FindingAid
  class DeleteFromIndex
    def self.call(eadid)
      connection = Blacklight.default_index.connection
      connection.delete_by_query("ead_ssi:#{eadid}")
      connection.delete_by_query("parent_ssim:#{eadid}")
      connection.delete_by_query("id:#{eadid}")
      connection.commit
    end
  end
end

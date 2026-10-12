# frozen_string_literal: true

class DeleteFindingAidJob < ApplicationJob
  queue_as :delete

  def perform(eadid)
    FindingAid::DeleteGeneratedFiles.call(eadid)
    FindingAid::DeleteFromIndex.call(eadid)
  end
end

# frozen_string_literal: true

class DeleteFindingAidJob < ApplicationJob
  queue_as :delete

  def perform(finding_aid_id)
    FindingAid::DeleteFromIndex.call(finding_aid_id)
  end
end

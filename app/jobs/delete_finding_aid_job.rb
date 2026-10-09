# frozen_string_literal: true

class DeleteFindingAidJob < ApplicationJob
  queue_as :delete

  def perform(document_id)
    FindingAid::DeleteFromIndex.call(document_id)
  end
end

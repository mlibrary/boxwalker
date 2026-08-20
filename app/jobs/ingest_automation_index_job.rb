# frozen_string_literal: true

class IngestAutomationIndexJob < ApplicationJob
  queue_as :index

  def perform(src_path, repo_id)
    ead_id = FindingAid::IndexFromEad.call(src_path, repo_id)
    IngestAutomationJob.perform_later("index.success", src_path: src_path, repo_id: repo_id, ead_id: ead_id)

  rescue FindingAidIndexError => e
    IngestAutomationJob.perform_later("index.failure", src_path: src_path, repo_id: repo_id, ead_id: nil, err_msg: e.message)
  end
end

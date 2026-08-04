# frozen_string_literal: true

class IngestAutomationPackageJob < ApplicationJob
  queue_as :index

  def perform(identifier, format)
    FindingAid::PackageArtifact.call(identifier, format)
    IngestAutomationJob.perform_later("#{format}.success", ead_id: identifier)
  rescue ::Box::GenerateError => e
    IngestAutomationJob.perform_later("#{format}.failure", ead_id: identifier, err_msg: e.message)
  end
end

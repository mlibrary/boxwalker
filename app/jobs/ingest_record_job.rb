# frozen_string_literal: true

class IngestRecordJob < ApplicationJob
  queue_as :ingest

  def perform(id)
    FindingAid::IngestRecord.call(id)
  end
end

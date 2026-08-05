# frozen_string_literal: true

class IngestAutomationJob < ApplicationJob
  queue_as :ingest

  def perform(event, details)
    unless Rails.configuration.x.arclight.enable_ingest_automation
      logger.debug <<~EOM
        Ingest automation attempted, but disabled...
        Set config.x.arclight.enable_ingest_automation = true if you want it to run.
        event: #{event}, details: #{details}
      EOM
      return
    end

    IngestAutomation::Dispatch.call(event, details, logger: logger)
  end
end

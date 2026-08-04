# frozen_string_literal: true

module IngestAutomation
  class Dispatch
    def self.call(event, details, logger: Rails.logger)
      case event
      when "ingest.file"
        logger.info "Beginning Finding Aid ingest to repository '#{details[:repo_id]}' of EAD file #{details[:file_path]}"
        ::IngestAutomationIndexJob.perform_later(details[:file_path], details[:repo_id])
      when "index.success"
        logger.info "Finding Aid successfully indexed -- ID: #{details[:ead_id]}, source path: #{details[:src_path]}, archived path: #{details[:archive_path]}"
        ::IngestAutomationPackageJob.perform_later(details[:ead_id], "html")
      when "html.success"
        logger.info "HTML generated for Finding Aid -- ID: #{details[:ead_id]}"
        ::IngestAutomationPackageJob.perform_later(details[:ead_id], "pdf")
      when "pdf.success"
        logger.info "PDF generated for Finding Aid -- ID: #{details[:ead_id]}"
        ::IngestAutomationJob.perform_later("ingest.success", ead_id: details[:ead_id])
      when "ingest.success"
        logger.info "Ingest completed for Finding Aid -- ID: #{details[:ead_id]}"
        # do some accounting
      when "index.failure", "html.failure", "pdf.failure"
        logger.error "Ingest failed for Finding Aid -- event: #{event}, details: #{details.inspect}"
      else
        logger.error "Unknown ingest event for Finding Aid -- event: #{event}, details: #{details.inspect}"
      end
    end
  end
end

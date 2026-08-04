# frozen_string_literal: true

require "arclight"
require "arclight/repository"

# Read the repository configuration
repo_config = YAML.safe_load(File.read("./config/repositories.yml"))

namespace :arclight do
  # FIXME: SHAMELESS copy of dul_arclight:reindex_everything for now
  desc "Reingest all finding aids in the data directory via background jobs"
  task ingest_everything: :environment do
    path = ENV.fetch("FINDING_AID_DATA")

    puts "Looking in #{path} ..."

    # Find our configured repositories, get their IDs
    repo_config.keys.each do |repo_id|
      puts "repo ID : #{repo_id}"
      puts "working directory : "
      Dir.glob(File.join(path, "ead", repo_id, "*.xml")) do |ead_path|
        puts "Queuing #{ead_path} for Ingest..."
        IngestAutomationJob.perform_later("ingest.file", repo_id: repo_id, file_path: ead_path)
      end
    end

    puts "All collections queued for Ingest."
  end
end

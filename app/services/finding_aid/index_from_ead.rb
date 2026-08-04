# frozen_string_literal: true

module FindingAid
  class IndexFromEad
    def self.call(src_path, repo_id)
      ead_id = nil
      dest_path = nil

      File.open(src_path, "r:UTF-8:UTF-8") do |file|
        # A Traject reader that yields Nokogiri docs from source XML.
        Box::Traject::CompressedReader.new(file, {}).each do |doc|
          indexer = Traject::Indexer::NokogiriIndexer.new(
            # Keep indexing/writes inline to avoid Rails threading side effects.
            "processing_thread_pool" => 0,
            "solr_writer.thread_pool" => 0,
            "solr_writer.batch_size" => 1,
            "solr.url" => ENV.fetch("SOLR_URL", Blacklight.default_index.connection.base_uri).to_s.chomp("/"),
            "repository" => repo_id
          )

          # Initializer args override config-provided settings.
          indexer.load_config_file(Rails.root.join("config/traject/ead2_config.rb"))

          # Process one source record through traject and writer.
          context = indexer.process_record(doc)

          # Flush writer and run after_processing hooks.
          indexer.complete

          # Make an archive copy of source file available for downloads.
          ead_id = context.output_hash["id"]&.first
          dest_dir = File.join(Box.finding_aid_data, "xml", repo_id)
          dest_path = File.join(dest_dir, "#{ead_id}.xml")
          FileUtils.mkdir_p(dest_dir)
          FileUtils.copy_file(src_path, dest_path, preserve: true, dereference: true, remove_destination: true)
        end

        ead_id
      end
    rescue => e
      raise FindingAidIndexError, e.message
    end
  end
end

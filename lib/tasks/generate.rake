require "arclight"
require "arclight/repository"

require_relative "../../app/services/package/generator"
require "fileutils"

namespace :arclight do
  artifact = nil

  desc "Clear package assets cache"
  task clear_package_assets: :environment do
    working_path_name = File.join(ENV.fetch("FINDING_AID_DATA", Rails.root.join("data").to_s), "pdf", "tmp")
    Dir.glob(File.join(working_path_name, "*/assets")).each do |asset_path|
      FileUtils.remove_dir(asset_path, true)
    end
  end

  # desc 'Generate packages for indexed finding aids via background jobs'
  # task generate_enqueue: :environment do
  #   args = {}
  #   if ENV['REPOSITORY_ID']
  #     repository_config = Arclight::Repository.find_by(slug: ENV['REPOSITORY_ID'])
  #     args[:repository_ssm] = repository_config.name
  #   elsif ENV['EADID']
  #     args[:eadid] = ENV['EADID']
  #   end
  #   args[:format] = ENV['FORMAT'] || 'html'
  #   Package::Queue.new.setup(**args)
  # end

  desc "Build a full HTML out of an EAD document, use EADID=<id>"
  task generate_html: :environment do
    raise "Please specify your EAD ID, ex. EADID=<id>" unless ENV["EADID"]

    identifier = ENV["EADID"]

    artifact = Package::Generator.new identifier: identifier
    artifact.generate_html
  end

  desc "Build a PDF out of an EAD document, use EADID=<id>"
  task generate_pdf: :environment do
    raise "Please specify your EAD ID, ex. EADID=<id>" unless ENV["EADID"]

    identifier = ENV["EADID"]

    artifact = Package::Generator.new identifier: identifier
    artifact.generate_pdf
  end
end

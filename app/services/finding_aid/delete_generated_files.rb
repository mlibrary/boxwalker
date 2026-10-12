module FindingAid
  class DeleteGeneratedFiles
    def self.call(eadid)
      data_dir = ENV.fetch("FINDING_AID_DATA")
      files_to_delete = Dir.glob("#{data_dir}/pdf/**/#{eadid}.pdf") \
        + Dir.glob("#{data_dir}/pdf/**/#{eadid}.html") \
        + Dir.glob("#{data_dir}/pdf/tmp/**/#{eadid}.local.html") \
        + Dir.glob("#{data_dir}/xml/**/#{eadid}.xml")
      FileUtils.rm(files_to_delete, force: true, verbose: true)
    end
  end
end

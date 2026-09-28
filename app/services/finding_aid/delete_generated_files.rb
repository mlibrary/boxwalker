module FindingAid
  class DeleteGeneratedFiles
    def self.call(eadid)
      response = Blacklight.default_index.find(eadid)
      doc = response.documents.first
      raise Boxwalker::Error, "No document found for id #{eadid}" if doc.nil?
      download_utility = DownloadUtility.new(doc)
      FileUtils.rm([
        download_utility.pdf_file_path,
        download_utility.html_file_path,
        download_utility.xml_file_path
      ])
    end
  end
end
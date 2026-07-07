class DownloadUtility
  attr_accessor :document

  def initialize(document)
    @document = document
  end

  def ead_available?
    File.exist?(ead_file_path)
  end

  def finding_aid_data
    ENV.fetch("FINDING_AID_DATA", "data")
  end

  def ead_file_path
    File.join(finding_aid_data, "xml", repo_slug, "#{ead_slug}.xml")
  end

  def html_available?
    File.exist?(html_file_path)
  end

  def html_file_path
    File.join(finding_aid_data, "pdf", repo_slug, "#{ead_slug}.html")
  end

  def pdf_available?
    File.exist?(pdf_file_path)
  end

  def pdf_file_path
    path = File.join(finding_aid_data, "pdf", repo_slug, "#{ead_slug}.pdf")
    p "Path: #{path}"
    path
  end

  def xml_available?
    ead_available?
  end

  def xml_file_path
    ead_file_path
  end

  private

  def repo_slug
    p document
    document&.repository_config&.slug || "repo_slug"
  end

  def ead_slug
    document&.document_id || "ead_slug"
  end
end

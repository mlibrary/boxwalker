# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::DeleteGeneratedFiles do
  let(:eadid) { 'eadid.slug' }
  let(:data_dir) { Dir.mktmpdir }
  let(:pdf_bhl_path) { File.join(data_dir, "pdf", "bhl") }
  let(:pdf_tmp_bhl_path) { File.join(data_dir, "pdf", "tmp", "bhl") }
  let(:xml_bhl_path) { File.join(data_dir, "xml", "bhl") }

  before do
    allow(ENV).to receive(:fetch).and_return(data_dir)

    FileUtils.mkdir_p(pdf_bhl_path)
    FileUtils.mkdir_p(pdf_tmp_bhl_path)
    FileUtils.mkdir_p(File.join(data_dir, "xml", "bhl"))
    FileUtils.touch(File.join(pdf_bhl_path, "eadid.slug.pdf"))
    FileUtils.touch(File.join(pdf_bhl_path, "eadid.slug.html"))
    FileUtils.touch(File.join(pdf_tmp_bhl_path, "eadid.slug.local.html"))
    FileUtils.touch(File.join(xml_bhl_path, "eadid.slug.xml"))
  end

  it 'deletes generated PDF, HTML and XML files' do
    described_class.call(eadid)
    expect(File).to_not exist(File.join(pdf_bhl_path, "eadid.slug.pdf"))
    expect(File).to_not exist(File.join(pdf_bhl_path, "eadid.slug.html"))
    expect(File).to_not exist(File.join(pdf_tmp_bhl_path, "eadid.slug.local.html"))
    expect(File).to_not exist(File.join(xml_bhl_path, "eadid.slug.xml"))
  end
end

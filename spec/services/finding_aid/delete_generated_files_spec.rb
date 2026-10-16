# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::DeleteGeneratedFiles do
  let(:eadid) { 'Some*Funky*EadId.With.Dots' }
  let(:normalize_eadid) { UmArclight::NormalizedId.new(eadid).to_s }
  let(:data_dir) { Dir.mktmpdir }
  let(:pdf_bhl_path) { File.join(data_dir, "pdf", "bhl") }
  let(:pdf_tmp_bhl_path) { File.join(data_dir, "pdf", "tmp", "bhl") }
  let(:xml_bhl_path) { File.join(data_dir, "xml", "bhl") }

  before do
    allow(ENV).to receive(:fetch).and_return(data_dir)

    FileUtils.mkdir_p(pdf_bhl_path)
    FileUtils.mkdir_p(pdf_tmp_bhl_path)
    FileUtils.mkdir_p(xml_bhl_path)
    FileUtils.touch(File.join(pdf_bhl_path, normalize_eadid + ".pdf"))
    FileUtils.touch(File.join(pdf_bhl_path, normalize_eadid + ".html"))
    FileUtils.touch(File.join(pdf_tmp_bhl_path, normalize_eadid + ".local.html"))
    FileUtils.touch(File.join(xml_bhl_path, normalize_eadid + ".xml"))
  end

  it 'deletes generated PDF, HTML and XML files' do
    described_class.call(eadid)
    expect(File).to_not exist(File.join(pdf_bhl_path, normalize_eadid + ".pdf"))
    expect(File).to_not exist(File.join(pdf_bhl_path, normalize_eadid + ".html"))
    expect(File).to_not exist(File.join(pdf_tmp_bhl_path, normalize_eadid + ".local.html"))
    expect(File).to_not exist(File.join(xml_bhl_path, normalize_eadid + ".xml"))
  end
end

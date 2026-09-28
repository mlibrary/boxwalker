# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::DeleteGeneratedFiles do
  let(:eadid) { 'eadid.slug' }
  let(:connection) { instance_double(RSolr::Client) }
  let(:index) { instance_double(Blacklight::Solr::Repository, connection: connection) }
  let(:data_dir) { Dir.mktmpdir }
  let(:pdf_bhl_path) { File.join(data_dir, "pdf", "bhl") }
  let(:xml_bhl_path) { File.join(data_dir, "xml", "bhl") }

  before do
    allow(Blacklight).to receive(:default_index).and_return(index)
    allow(index).to receive(:find).and_return(
      Blacklight::Solr::Response.new({
        "response": {
          "docs": [ {
            'id': eadid,
            'ead_ssi': eadid,
            'normalized_title_ssm': [ 'Finding Aid' ],
            'authors_creators_tesim': [ 'Finding Aid written by E. A. Document' ],
            'repository_ssm': [ 'University of Michigan Bentley Historical Library' ]
          } ]
        }
      }, nil, blacklight_config: CatalogController.blacklight_config)
    )
    allow(ENV).to receive(:fetch).and_return(data_dir)

    FileUtils.mkdir_p(pdf_bhl_path)
    FileUtils.mkdir_p(File.join(data_dir, "xml", "bhl"))
    FileUtils.touch(File.join(pdf_bhl_path, "eadid.slug.pdf"))
    FileUtils.touch(File.join(pdf_bhl_path, "eadid.slug.html"))
    FileUtils.touch(File.join(xml_bhl_path, "eadid.slug.xml"))
  end

  it 'deletes generated PDF, HTML and XML files' do
    described_class.call(eadid)
    expect(File).to_not exist(File.join(pdf_bhl_path, "eadid.slug.pdf"))
    expect(File).to_not exist(File.join(pdf_bhl_path, "eadid.slug.html"))
    expect(File).to_not exist(File.join(xml_bhl_path, "eadid.slug.xml"))
  end
end

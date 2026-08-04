# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::IngestRecord do
  let(:id) { 'id' }
  let(:findingaid) do
    instance_double(
      'Findingaid',
      id: 1,
      reposlug: 'reposlug',
      eadslug: 'eadslug',
      state: 'uploaded',
      error: nil,
      eadurl: 'title'
    )
  end
  let(:path) { File.join(ENV['FINDING_AID_DATA'], 'findingaids', findingaid.id.to_s) }
  let(:repository) { instance_double(Blacklight.repository_class) }
  let(:catalog_controller) { instance_double('CatalogController', helpers: helpers) }
  let(:helpers) { double('helpers', blacklight_config: 'blacklight_config') }
  let(:response) { instance_double('Blacklight::Solr::Response', documents: [ document ]) }
  let(:document) { instance_double('SolrDocument') }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FINDING_AID_DATA').and_return('/tmp')

    stub_const('Findingaid', Class.new do
      def self.find(_id); end
    end)
    allow(Findingaid).to receive(:find).with(id).and_return(findingaid)
    allow(findingaid).to receive(:state=)
    allow(findingaid).to receive(:save!).and_return(true)
    allow(findingaid).to receive(:eadurl=)
    allow(findingaid).to receive(:eadurl).and_return('title')
    allow(IngestAutomationIndexJob).to receive(:perform_now).with(path, findingaid.reposlug).and_return(true)
    allow(Blacklight.repository_class).to receive(:new).with('blacklight_config').and_return(repository)
    allow(repository).to receive(:search).and_return(response)
    allow(CatalogController).to receive(:new).and_return(catalog_controller)
    allow(document).to receive(:[]).with('title_ssm').and_return([ 'title' ])
    allow(Rails.logger).to receive(:info)
  end

  it 'indexes and marks finding aid as indexed' do
    expect { described_class.call(id) }.not_to raise_error

    expect(IngestAutomationIndexJob).to have_received(:perform_now).with(path, findingaid.reposlug)
    expect(findingaid).to have_received(:state=).with('indexing')
    expect(findingaid).to have_received(:eadurl=).with('title')
    expect(findingaid).to have_received(:state=).with('indexed')
    expect(findingaid).to have_received(:save!).twice
  end
end

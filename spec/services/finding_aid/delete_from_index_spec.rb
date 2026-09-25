# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::DeleteFromIndex do
  let(:document_id) { 'eadid.slug' }
  let(:connection) { instance_double(RSolr::Client) }
  let(:index) { instance_double(Blacklight::Solr::Repository, connection: connection) }

  before do
    allow(Blacklight).to receive(:default_index).and_return(index)
    allow(connection).to receive(:delete_by_query)
    allow(connection).to receive(:commit)
  end

  it 'deletes the Solr document block and commits' do
    expect { described_class.call(document_id) }.not_to raise_error
    expect(connection).to have_received(:delete_by_query).with("_root_:eadid.slug")
    expect(connection).to have_received(:commit)
  end

  it 'escapes the Solr document id' do
    described_class.call("eadid:slug")

    expect(connection).to have_received(:delete_by_query).with("_root_:eadid\\:slug")
  end
end

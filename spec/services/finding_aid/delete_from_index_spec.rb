# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::DeleteFromIndex do
  let(:eadid) { 'eadid.slug' }
  let(:connection) { instance_double(RSolr::Client) }
  let(:index) { instance_double(Blacklight::Solr::Repository, connection: connection) }

  before do
    allow(Blacklight).to receive(:default_index).and_return(index)
    allow(connection).to receive(:delete_by_query)
    allow(connection).to receive(:commit)
  end

  it 'deletes documents matching the ead id and commits' do
    expect { described_class.call(eadid) }.not_to raise_error
    expect(connection).to have_received(:delete_by_query).with("ead_ssi:#{eadid}")
    expect(connection).to have_received(:delete_by_query).with("parent_ssim:#{eadid}")
    expect(connection).to have_received(:delete_by_query).with("id:#{eadid}")
    expect(connection).to have_received(:commit)
  end
end

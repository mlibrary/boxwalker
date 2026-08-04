# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr::BuildSuggest do
  let(:http) { instance_double(Net::HTTP) }
  let(:response) { instance_double(Net::HTTPOK, value: nil, body: '{"responseHeader":{"status":0}}') }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('SOLR_URL', anything).and_return('http://solr.example.com:8983/solr/')
    allow(Net::HTTP).to receive(:start).and_yield(http)
    allow(http).to receive(:read_timeout=)
    allow(http).to receive(:request_get).and_return(response)
    allow($stdout).to receive(:puts)
  end

  it 'requests the Solr suggester build endpoint' do
    expect { described_class.call }.not_to raise_error
    expect(Net::HTTP).to have_received(:start).with('solr.example.com', 8983)
    expect(http).to have_received(:request_get).with('/solr/suggest', 'Accept' => 'application/json')
    expect(response).to have_received(:value)
  end

  context 'when Solr returns a non-2XX response' do
    before do
      allow(response).to receive(:value).and_raise(Net::HTTPServerException.new('500', response))
    end

    it 'raises the error' do
      expect { described_class.call }.to raise_error(Net::HTTPServerException)
    end
  end
end

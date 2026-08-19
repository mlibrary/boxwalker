# frozen_string_literal: true

require 'rails_helper'

# End-to-end test of the ingest automation state machine (Layer 2).
# Drives the whole event chain with the inline ActiveJob adapter, mocking only the
# two external boundaries (indexer + packager). Proves the wiring
# ingest.file -> index.success -> html.success -> pdf.success -> ingest.success
# without Solr or Redis.
RSpec.describe 'Ingest automation pipeline', type: :job do
  include ActiveJob::TestHelper

  let(:ead_id)  { 'umich-bhl-032' }
  let(:repo_id) { 'bhl' }
  let(:file)    { '/tmp/umich-bhl-032.xml' }
  let(:events)  { [] }

  before do
    # Enable the feature flag for the whole chain.
    arclight = double('arclight', enable_ingest_automation: true)
    allow(Rails.configuration.x).to receive(:arclight).and_return(arclight)

    # Mock external boundaries only.
    allow(FindingAid::IndexFromEad).to receive(:call).with(file, repo_id).and_return(ead_id)
    allow(FindingAid::PackageArtifact).to receive(:call)

    # Record every dispatched event to assert the full sequence.
    allow(IngestAutomation::Dispatch).to receive(:call).and_wrap_original do |orig, event, details, **kw|
      events << event
      orig.call(event, details, **kw)
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'runs ingest.file -> index -> html -> pdf -> ingest.success' do
    perform_enqueued_jobs do
      IngestAutomationJob.perform_later('ingest.file', repo_id: repo_id, file_path: file)
    end

    expect(FindingAid::IndexFromEad).to have_received(:call).with(file, repo_id)
    expect(FindingAid::PackageArtifact).to have_received(:call).with(ead_id, 'html')
    expect(FindingAid::PackageArtifact).to have_received(:call).with(ead_id, 'pdf')
    # The event sequence proves html was packaged before pdf.
    expect(events).to eq(%w[ingest.file index.success html.success pdf.success ingest.success])
  end

  it 'halts on index failure' do
    allow(FindingAid::IndexFromEad).to receive(:call).and_raise(FindingAidIndexError, 'bad xml')

    perform_enqueued_jobs do
      IngestAutomationJob.perform_later('ingest.file', repo_id: repo_id, file_path: file)
    end

    expect(events).to include('index.failure')
    expect(FindingAid::PackageArtifact).not_to have_received(:call)
  end
end

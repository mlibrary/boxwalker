# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomation::Dispatch do
  let(:logger) { instance_double(Logger, info: nil, error: nil) }

  before do
    allow(IngestAutomationIndexJob).to receive(:perform_later)
    allow(IngestAutomationPackageJob).to receive(:perform_later)
    allow(IngestAutomationJob).to receive(:perform_later)
  end

  it 'dispatches ingest.file to IndexFindingAidJob' do
    details = { repo_id: 'repo', file_path: '/tmp/example.xml' }

    described_class.call('ingest.file', details, logger: logger)

    expect(IngestAutomationIndexJob).to have_received(:perform_later).with('/tmp/example.xml', 'repo')
  end

  it 'dispatches index.success to html packaging' do
    details = { ead_id: 'eadid', src_path: '/tmp/example.xml', archive_path: '/tmp/archive.xml' }

    described_class.call('index.success', details, logger: logger)

    expect(IngestAutomationPackageJob).to have_received(:perform_later).with('eadid', 'html')
  end

  it 'dispatches html.success to pdf packaging' do
    described_class.call('html.success', { ead_id: 'eadid' }, logger: logger)

    expect(IngestAutomationPackageJob).to have_received(:perform_later).with('eadid', 'pdf')
  end

  it 'dispatches pdf.success to ingest.success event' do
    described_class.call('pdf.success', { ead_id: 'eadid' }, logger: logger)

    expect(IngestAutomationJob).to have_received(:perform_later).with('ingest.success', ead_id: 'eadid')
  end

  it 'log unknown event' do
    details = { ead_id: 'eadid' }

    described_class.call('unknown.event', details, logger: logger)

    expect(logger).to have_received(:error).with("Unknown ingest event for Finding Aid -- event: unknown.event, details: #{details.inspect}")
  end
end

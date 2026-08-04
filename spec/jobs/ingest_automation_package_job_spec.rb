# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomationPackageJob, type: :job do
  include ActiveJob::TestHelper

  let(:identifier) { 'eadid.slug' }
  let(:format) { 'html' }

  before do
    stub_const('Box::GenerateError', Class.new(StandardError))
    allow(FindingAid::PackageArtifact).to receive(:call)
    allow(IngestAutomationJob).to receive(:perform_later)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job on the index queue' do
    expect { described_class.perform_later(identifier, format) }
      .to have_enqueued_job(described_class).with(identifier, format).on_queue('index')
  end

  it 'delegates packaging to the service' do
    expect { described_class.perform_now(identifier, format) }.not_to raise_error
    expect(FindingAid::PackageArtifact).to have_received(:call).with(identifier, format)
  end

  it 'enqueues a success event when packaging succeeds' do
    expect { described_class.perform_now(identifier, format) }.not_to raise_error
    expect(IngestAutomationJob).to have_received(:perform_later)
      .with('html.success', ead_id: identifier)
  end

  it 'enqueues a failure event when packaging fails' do
    allow(FindingAid::PackageArtifact).to receive(:call).and_raise(Box::GenerateError, 'boom')
    expect { described_class.perform_now(identifier, format) }.not_to raise_error
    expect(IngestAutomationJob).to have_received(:perform_later)
      .with('html.failure', ead_id: identifier, err_msg: 'boom')
  end
end

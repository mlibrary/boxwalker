# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomationIndexJob, type: :job do
  include ActiveJob::TestHelper

  let(:src_path) { 'path/to/file.xml' }
  let(:repo_id) { 'repo' }
  let(:ead_id) { 'ead123' }

  before do
    allow(FindingAid::IndexFromEad).to receive(:call).and_return(ead_id)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { described_class.perform_later(src_path, repo_id) }
      .to have_enqueued_job(described_class).with(src_path, repo_id).on_queue('index')
  end

  it 'delegates indexing to the service' do
    expect { described_class.perform_now(src_path, repo_id) }.not_to raise_error
    expect(FindingAid::IndexFromEad).to have_received(:call).with(src_path, repo_id)
  end

  it 'enqueues an index.failure event when indexing fails' do
    allow(FindingAid::IndexFromEad).to receive(:call).and_raise(FindingAidIndexError, 'boom')
    allow(IngestAutomationJob).to receive(:perform_later)
    expect { described_class.perform_now(src_path, repo_id) }.not_to raise_error
    expect(IngestAutomationJob).to have_received(:perform_later)
      .with('index.failure', src_path: src_path, repo_id: repo_id, ead_id: nil, err_msg: 'boom')
  end

  it 'enqueues an index success event when indexing succeed' do
    allow(IngestAutomationJob).to receive(:perform_later)
    expect { described_class.perform_now(src_path, repo_id) }.not_to raise_error
    expect(IngestAutomationJob).to have_received(:perform_later)
                                     .with('index.success', src_path: src_path, repo_id: repo_id, ead_id: ead_id)
  end
end

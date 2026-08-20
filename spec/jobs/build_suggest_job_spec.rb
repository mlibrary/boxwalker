# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildSuggestJob, type: :job do
  include ActiveJob::TestHelper

  before do
    allow(Solr::BuildSuggest).to receive(:call)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job on the index queue' do
    expect { described_class.perform_later }
      .to have_enqueued_job(described_class).on_queue('index')
  end

  it 'delegates to the build suggest service' do
    expect { described_class.perform_now }.not_to raise_error
    expect(Solr::BuildSuggest).to have_received(:call)
  end
end

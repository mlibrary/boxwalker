# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteFindingAidJob, type: :job do
  include ActiveJob::TestHelper

  let(:finding_aid_id) { 'eadid.slug' }

  before do
    allow(FindingAid::DeleteFromIndex).to receive(:call)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job on the delete queue' do
    expect { described_class.perform_later(finding_aid_id) }
      .to have_enqueued_job(described_class).with(finding_aid_id).on_queue('delete')
  end

  it 'delegates deletion to the service' do
    expect { described_class.perform_now(finding_aid_id) }.not_to raise_error
    expect(FindingAid::DeleteFromIndex).to have_received(:call).with(finding_aid_id)
  end
end

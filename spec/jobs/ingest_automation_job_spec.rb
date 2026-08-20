# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngestAutomationJob, type: :job do
  before do
    allow(IngestAutomation::Dispatch).to receive(:call)
  end

  describe 'queue' do
    it 'is enqueued on the default queue' do
      expect(described_class.new("event", {}).queue_name).to eq('ingest')
    end

    it 'enqueues the job' do
      expect { described_class.perform_later("event", {}) }
        .to have_enqueued_job(described_class).on_queue('ingest')
    end
  end

  describe '#perform' do
    it 'does not dispatch when automation is disabled' do
      arclight_options = double('arclight_options', enable_ingest_automation: false)
      allow(Rails.configuration.x).to receive(:arclight).and_return(arclight_options)

      expect { described_class.perform_now('event', {}) }.not_to raise_error
      expect(IngestAutomation::Dispatch).not_to have_received(:call)
    end

    it 'delegates event handling when automation is enabled' do
      details = { repo_id: 'repo', file_path: '/tmp/file.xml' }
      arclight_options = double('arclight_options', enable_ingest_automation: true)
      allow(Rails.configuration.x).to receive(:arclight).and_return(arclight_options)

      expect { described_class.perform_now('ingest.file', details) }.not_to raise_error
      expect(IngestAutomation::Dispatch).to have_received(:call).with('ingest.file', details, logger: anything)
    end
  end
end

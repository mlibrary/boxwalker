# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::IndexFromEad do
  let(:src_path) { Rails.root.join('spec/fixtures/bhl/umich-bhl-032.xml') }
  let(:repo_id) { 'bhl' }

  context 'when source open fails' do
    before do
      allow(File).to receive(:open).with(src_path, 'r:UTF-8:UTF-8').and_raise(StandardError, 'boom')
    end

    it 'raises FindingAidIndexError' do
      expect { described_class.call(src_path, repo_id) }
        .to raise_error(FindingAidIndexError, 'boom')
    end
  end

  context 'when source open succeed' do
    let(:src_path) { Rails.root.join('spec/fixtures/bhl/umich-bhl-032.xml') }
    let(:dest_path) { Rails.root.join('data/xml/bhl/umich-bhl-032.xml').to_s }
    let(:dest_dir) { Rails.root.join('data/xml/bhl').to_s  }

    before do
      allow(FileUtils).to receive(:mkdir_p).with(dest_dir).and_return(true)
      allow(FileUtils).to receive(:copy_file).with(src_path, dest_path, preserve: true, dereference: true, remove_destination: true).and_return(true)
    end

    it 'return ead_id and make an archive copy of source file available for downloads' do
      expect(described_class.call(src_path, repo_id)).to eq "umich-bhl-032"
      expect(FileUtils).to have_received(:mkdir_p).with(dest_dir)
      expect(FileUtils).to have_received(:copy_file).with(src_path, dest_path, preserve: true, dereference: true, remove_destination: true)
    end
  end
end

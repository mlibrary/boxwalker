# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingAid::PackageArtifact do
  let(:identifier) { 'eadid.slug' }
  let(:generator) { instance_double(Package::Generator) }

  before do
    generator_class = Class.new do
      def initialize(identifier:); end

      def generate_html; end

      def generate_pdf; end
    end
    stub_const('Package::Generator', generator_class)

    allow(Package::Generator).to receive(:new).with(identifier: identifier).and_return(generator)
    allow(generator).to receive(:generate_html)
    allow(generator).to receive(:generate_pdf)
  end

  context 'when the format is html' do
    it 'generates html' do
      expect { described_class.call(identifier, 'html') }.not_to raise_error
      expect(generator).to have_received(:generate_html)
      expect(generator).not_to have_received(:generate_pdf)
    end
  end

  context 'when the format is pdf' do
    it 'generates pdf' do
      expect { described_class.call(identifier, 'pdf') }.not_to raise_error
      expect(generator).to have_received(:generate_pdf)
      expect(generator).not_to have_received(:generate_html)
    end
  end

  context 'when the format is unsupported' do
    it 'raises a GenerateError without generating' do
      expect { described_class.call(identifier, 'txt') }
        .to raise_error(Boxwalker::GenerateError, identifier)
      expect(Package::Generator).not_to have_received(:new)
    end
  end

  context 'when generation fails' do
    before do
      allow(generator).to receive(:generate_html).and_raise(StandardError, 'boom')
    end

    it 're-raises as a GenerateError' do
      expect { described_class.call(identifier, 'html') }
        .to raise_error(Boxwalker::GenerateError, identifier)
    end
  end
end

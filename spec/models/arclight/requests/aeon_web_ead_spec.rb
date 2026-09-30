# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arclight::Requests::AeonWebEad do
  subject(:request) { described_class.new(document, "https://findingaids.example.edu/sample.xml") }

  let(:request_id) { nil }
  let(:repository) do
    Struct.new(:request_id) do
      def request_config_for_type(_type)
        {
          "request_url" => "https://aeon.example.edu/logon",
          "request_mappings" => "Action=10&Form=31&Value=parsed_ead_url"
        }
      end
    end.new(request_id)
  end
  let(:document) do
    instance_double(
      SolrDocument,
      repository_config: repository,
      request_field: "-//example//TEXT example::sample.xml//EN"
    )
  end

  it "substitutes the EAD download URL for parsed_ead_url" do
    expect(request.form_mapping["Value"]).to eq("https://findingaids.example.edu/sample.xml")
    expect(request.url).to include("Value=https%3A%2F%2Ffindingaids.example.edu%2Fsample.xml")
  end

  it "supports the configured SCRC and Clements request mappings" do
    %w[scrc clements].each do |slug|
      configured_repository = Arclight::Repository.find_by(slug: slug)
      configured_document = instance_double(
        SolrDocument,
        repository_config: configured_repository,
        request_field: nil
      )

      configured_request = described_class.new(
        configured_document,
        "https://findingaids.example.edu/#{slug}.xml"
      )

      expect(configured_request.form_mapping["Value"]).to eq(
        "https://findingaids.example.edu/#{slug}.xml"
      )
    end
  end

  context "when the repository config builds an external EAD URL" do
    let(:request_id) do
      {
        "field" => "publicid_ssi",
        "pattern" => "example::(.*)//EN",
        "prefix" => "https://quod.example.edu/eads/",
        "postfix" => "?view=xml"
      }
    end

    it "extracts the request identifier and applies the configured URL parts" do
      expect(request.parsed_ead_url).to eq("https://quod.example.edu/eads/sample.xml?view=xml")
    end
  end
end

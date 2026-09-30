# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolrDocument do
  describe "#finding_aid_id" do
    it "returns the Solr id for a collection instead of its raw EAD id" do
      document = described_class.new(
        "id" => "umich-wcl-f-103.1dub",
        "ead_ssi" => "umich-wcl-F-103.1dub"
      )

      expect(document.finding_aid_id).to eq("umich-wcl-f-103.1dub")
    end

    it "returns the root Solr id for a component" do
      document = described_class.new(
        "id" => "umich-wcl-f-103.1dub_component",
        "_root_" => "umich-wcl-f-103.1dub",
        "ead_ssi" => "umich-wcl-F-103.1dub"
      )

      expect(document.finding_aid_id).to eq("umich-wcl-f-103.1dub")
    end
  end

  describe "request metadata" do
    subject(:document) do
      described_class.new(
        "collection_ssm" => [ "Test collection" ],
        "collection_unitid_ssm" => [ "TEST 1" ],
        "collection_physloc_tesim" => [ "Offsite" ],
        "collection_date_inclusive_ssm" => [ "1900-1950" ],
        "collection_creator_ssm" => [ "Test creator" ],
        "publicid_ssi" => "-//example//TEXT sample.xml//EN"
      )
    end

    it "reads denormalized collection fields from standalone component documents" do
      expect(document.collection_name).to eq("Test collection")
      expect(document.collection_unitid).to eq("TEST 1")
      expect(document.physloc).to eq("Offsite")
      expect(document.collection_date).to eq("1900-1950")
      expect(document.collection_creator).to eq("Test creator")
    end

    it "reads a configured Aeon request field" do
      expect(document.request_field("publicid_ssi")).to eq("-//example//TEXT sample.xml//EN")
    end
  end
end

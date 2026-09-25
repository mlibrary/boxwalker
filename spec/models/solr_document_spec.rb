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
end

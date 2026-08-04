# frozen_string_literal: true

require "rails_helper"
require "traject"
require "traject/nokogiri_reader"

RSpec.describe "config/traject/ead2_config.rb" do
  subject(:result) { indexer.map_record(record) }

  let(:fixture_path) { Rails.root.join("spec/fixtures/bhl/umich-bhl-032.xml") }

  let(:record) do
    File.open(fixture_path, "r:UTF-8:UTF-8") do |file|
      Box::Traject::CompressedReader.new(file, {}).first
    end
  end

  let(:indexer) do
    Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.settings do
        provide "repository", "bhl"
        provide "writer_class_name", "Traject::ArrayWriter"
      end
      i.load_config_file(Rails.root.join("config/traject/ead2_config.rb"))
    end
  end

  describe "identification" do
    it "maps id from eadid" do
      expect(result["id"]).to eq [ "umich-bhl-032" ]
    end

    it "maps ead_ssi from eadid" do
      expect(result["ead_ssi"]).to eq [ "umich-bhl-032" ]
    end

    it "maps unitid_ssm" do
      expect(result["unitid_ssm"]).to include "032 Bimu 2"
    end
  end

  describe "title" do
    # CompressedReader collapses whitespace in the XML string, but Nokogiri's .text
    # still concatenates text nodes across <emph> element boundaries which can
    # introduce adjacent spaces from both sides of the tag.
    it "maps title_ssm from archdesc/did/unittitle" do
      expect(result["title_ssm"].first).to match(/Women in.*Science.*and.*Engineering.*Program/)
    end

    it "maps title_tesim from archdesc/did/unittitle" do
      expect(result["title_tesim"].first).to match(/Women in.*Science.*and.*Engineering.*Program/)
    end

    it "maps normalized_title_ssm combining title and date" do
      expect(result["normalized_title_ssm"].first).to match(/Women in.*Science.*and.*Engineering.*Program/)
    end

    it "maps collection_title_tesim from normalized_title_ssm" do
      expect(result["collection_title_tesim"]).to eq result["normalized_title_ssm"]
    end

    it "maps collection_ssim from normalized_title_ssm" do
      expect(result["collection_ssim"]).to eq result["normalized_title_ssm"]
    end
  end

  describe "level" do
    it "maps level_ssm as 'collection' regardless of archdesc @level" do
      expect(result["level_ssm"]).to eq [ "collection" ]
    end

    it "maps level_ssim with the original level label and Collection" do
      expect(result["level_ssim"]).to include "Record Group"
      expect(result["level_ssim"]).to include "Collection"
    end
  end

  describe "dates" do
    it "maps unitdate_inclusive_ssm with direct <did> children" do
      # This fixture's unitdate[@type="bulk"] is nested inside <unittitle>, not
      # a direct <did> child, so only direct-child inclusive dates are mapped.
      expect(result["unitdate_inclusive_ssm"]).to include "1974-1996"
      expect(result["unitdate_inclusive_ssm"]).to include "2004-2019"
    end

    it "maps normalized_date_ssm" do
      expect(result["normalized_date_ssm"].first).not_to be_nil
    end

    it "maps date_range_isim as an array of integers" do
      expect(result["date_range_isim"]).to all be_an(Integer)
      expect(result["date_range_isim"]).not_to be_empty
    end
  end

  describe "repository" do
    it "maps repository_ssm from the configured repository name" do
      expect(result["repository_ssm"]).to eq [ "University of Michigan Bentley Historical Library" ]
    end

    it "maps repository_ssim from the configured repository name" do
      expect(result["repository_ssim"]).to eq [ "University of Michigan Bentley Historical Library" ]
    end
  end

  describe "creator" do
    it "maps creator_ssm from origination" do
      expect(result["creator_ssm"].first).to include "University of Michigan"
    end

    it "maps creator_ssim from origination" do
      expect(result["creator_ssim"].first).to include "University of Michigan"
    end

    it "maps creator_corpname_ssim" do
      expect(result["creator_corpname_ssim"]).to include "University of Michigan. Women in Science and Engineering Program."
    end
  end

  describe "physical description" do
    it "maps extent_ssm with one entry per physdesc" do
      expect(result["extent_ssm"]).to include "3.0 linear feet"
      expect(result["extent_ssm"]).to include "79.7 GB (online)"
      expect(result["extent_ssm"]).to include "1 archived websites"
    end

    it "maps extent_tesim from extent_ssm" do
      expect(result["extent_tesim"]).to eq result["extent_ssm"]
    end
  end

  describe "controlled access" do
    it "maps access_subjects_ssim from controlaccess subjects" do
      expect(result["access_subjects_ssim"]).to include "Women in science."
      expect(result["access_subjects_ssim"]).to include "Women engineers."
    end

    it "maps access_subjects_ssm from access_subjects_ssim" do
      expect(result["access_subjects_ssm"]).to eq result["access_subjects_ssim"]
    end

    it "maps genreform_ssim from controlaccess" do
      expect(result["genreform_ssim"]).to include "Photographs."
    end
  end

  describe "searchable notes" do
    it "maps bioghist_tesim" do
      expect(result["bioghist_tesim"]).not_to be_empty
    end

    it "maps scopecontent_tesim" do
      expect(result["scopecontent_tesim"]).not_to be_empty
    end

    # Note: this fixture nests <accessrestrict> inside <descgrp>, not directly under
    # <archdesc>, so the XPath /ead/archdesc/accessrestrict does not find it.
    it "maps accessrestrict_tesim as nil when nested inside <descgrp>" do
      expect(result["accessrestrict_tesim"]).to be_nil
    end

    it "maps acqinfo_ssim from descgrp/acqinfo" do
      expect(result["acqinfo_ssim"]).not_to be_empty
    end
  end

  describe "counters" do
    it "maps component_level_isim as 0 for top-level" do
      expect(result["component_level_isim"]).to eq [ 0 ]
    end

    it "maps sort_isi as 0 for top-level" do
      expect(result["sort_isi"]).to eq [ 0 ]
    end

    it "maps total_component_count_is" do
      expect(result["total_component_count_is"].first).to be > 0
    end
  end

  describe "components" do
    it "maps nested component documents" do
      expect(result["components"]).not_to be_empty
    end

    it "maps 7 top-level c01 components" do
      expect(result["components"].length).to eq 7
    end

    describe "first component" do
      subject(:component) { result["components"].first }

      it "has an id built from root id and ref id" do
        expect(component["id"].first).to start_with "umich-bhl-032_"
      end

      it "has normalized_title_ssm" do
        expect(component["normalized_title_ssm"].first).to include "Administrative"
      end

      it "has collection_ssim pointing to root" do
        expect(component["collection_ssim"]).to eq result["normalized_title_ssm"]
      end

      it "has repository_ssim from root" do
        expect(component["repository_ssim"]).to eq [ "University of Michigan Bentley Historical Library" ]
      end

      it "has component_level_isim of 1" do
        expect(component["component_level_isim"]).to eq [ 1 ]
      end

      it "has parent_ssi pointing to root id" do
        expect(component["parent_ssi"]).to include "umich-bhl-032"
      end
    end
  end
end

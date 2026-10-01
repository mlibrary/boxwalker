# frozen_string_literal: true

require "rails_helper"
require "traject"
require "traject/nokogiri_reader"

RSpec.describe "um_arclight/traject/ead2_config.rb" do
  before(:context) do
    fixture_path = Rails.root.join("spec/fixtures/bhl/umich-bhl-032.xml")
    record = File.open(fixture_path, "r:UTF-8:UTF-8") do |file|
      CompressedReader.new(file, {}).first
    end
    indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
      i.settings do
        provide "repository", "bhl"
        provide "writer_class_name", "Traject::ArrayWriter"
      end
      i.load_config_file(Rails.root.join("lib/um_arclight/traject/ead2_config.rb"))
    end
    @result = indexer.map_record(record)
  end

  let(:result) { @result }

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

    it "maps title_subjects_ssim from controlaccess" do
      expect(result["title_subjects_ssim"]).to include "Some Fabricated Title"
    end
  end

  describe "searchable notes" do
    it "maps bioghist_tesim" do
      expect(result["bioghist_tesim"]).not_to be_empty
    end

    it "maps scopecontent_tesim" do
      expect(result["scopecontent_tesim"]).not_to be_empty
    end

    # Note: this fixture nests <accessrestrict> inside <descgrp>. The notes loop maps
    # accessrestrict_tesim from the union XPath (direct | descgrp), so it is populated.
    it "maps accessrestrict_tesim from descgrp/accessrestrict" do
      expect(result["accessrestrict_tesim"]).not_to be_empty
    end

    it "maps acqinfo_ssim from descgrp/acqinfo" do
      expect(result["acqinfo_ssim"]).not_to be_empty
    end

    # access_terms_ssm previously queried only direct /archdesc/userestrict, so it was
    # empty for descgrp-nested finding aids like this one. The union now captures it.
    it "maps access_terms_ssm from descgrp/userestrict" do
      expect(result["access_terms_ssm"].join(" ")).to include "Copyright is held by the Regents"
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

      it "inherits only the collection <accessrestrict> in parent_access_restrict_tesm" do
        expect(component["parent_access_restrict_tesm"]).to contain_exactly(
          "Restrictions apply; see item listing for details.",
          "Access to select audiovisual content in the Programming series is restricted to the reading room of the Bentley Historical Library."
        )
      end

      it "inherits the collection <userestrict> in parent_access_terms_tesm" do
        expect(component["parent_access_terms_tesm"].join(" ")).to include "Copyright is held by the Regents"
      end
    end
  end

  # The component's own <userestrict> is displayed by the `terms` row
  # (catalog_controller.rb), so the inherited parent rows must show only the
  # collection-level text and must not duplicate the component's own text.
  describe "component with its own userestrict" do
    def find_component(node, id_fragment)
      (node["components"] || []).each do |child|
        return child if child["id"]&.first&.to_s&.include?(id_fragment)

        found = find_component(child, id_fragment)
        return found if found
      end
      nil
    end

    before(:context) do
      fixture_path = Rails.root.join("spec/fixtures/bhl/umich-bhl-032.xml")
      xml = File.read(fixture_path, encoding: "UTF-8")
      target = '<c02 id="aspace_284d207da04e9640277a58b23d9576af" level="file">' \
               "<did><unittitle>Background/History</unittitle></did>"
      xml = xml.sub(
        target,
        target + "<userestrict><p>Component-specific use and permissions statement.</p></userestrict>"
      )
      record = CompressedReader.new(StringIO.new(xml), {}).first
      indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
        i.settings do
          provide "repository", "bhl"
          provide "writer_class_name", "Traject::ArrayWriter"
        end
        i.load_config_file(Rails.root.join("lib/um_arclight/traject/ead2_config.rb"))
      end
      @injected_result = indexer.map_record(record)
    end

    subject(:component) do
      find_component(@injected_result, "aspace_284d207da04e9640277a58b23d9576af")
    end

    it "keeps the component's own text in userestrict_html_tesm" do
      expect(component["userestrict_html_tesm"].map(&:text).join(" "))
        .to include "Component-specific use and permissions statement."
    end

    it "shows only the collection copyright in parent_access_terms_tesm" do
      joined = component["parent_access_terms_tesm"].join(" ")
      expect(joined).to include "Copyright is held by the Regents"
      expect(joined).not_to include "Component-specific use and permissions statement."
    end

    it "does not leak the component's own text into parent_access_restrict_tesm" do
      expect(component["parent_access_restrict_tesm"].join(" "))
        .not_to include "Component-specific use and permissions statement."
    end
  end

  # ARC-190 / ARC-193: collection note fields must index regardless of whether the
  # element sits directly under <archdesc> or inside an <archdesc>/<descgrp> wrapper.
  # A synthetic EAD places dual fields in the DIRECT location (the placement the old
  # descgrp-only query dropped) and puts the three formerly descgrp-only bug fields
  # (altformavail, bibliography, custodhist) inside <descgrp> (the placement the old
  # direct-only query dropped).
  describe "dual-location notes (union XPath)" do
    before(:context) do
      xml = <<~EAD
        <ead>
          <eadheader>
            <eadid>test-dual-001</eadid>
            <filedesc><titlestmt><titleproper>Dual Location Test</titleproper></titlestmt></filedesc>
          </eadheader>
          <archdesc level="collection">
            <did><unittitle>Dual Location Test Collection</unittitle></did>
            <relatedmaterial><head>Related Material</head><p>DIRECT related material text.</p></relatedmaterial>
            <separatedmaterial><head>Separated Material</head><p>DIRECT separated material text.</p></separatedmaterial>
            <accessrestrict><head>Restrictions</head><p>DIRECT access restriction text.</p></accessrestrict>
            <prefercite><head>Preferred Citation</head><p>DIRECT preferred citation text.</p></prefercite>
            <descgrp type="add">
              <altformavail><head>Alternative Form</head><p>DESCGRP alternative form text.</p></altformavail>
              <bibliography><head>Bibliography</head><p>DESCGRP bibliography text.</p></bibliography>
              <custodhist><head>Custodial History</head><p>DESCGRP custodial history text.</p></custodhist>
              <userestrict><head>Terms</head><p>DESCGRP use restriction text.</p></userestrict>
            </descgrp>
          </archdesc>
        </ead>
      EAD
      record = CompressedReader.new(StringIO.new(xml), {}).first
      indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
        i.settings do
          provide "repository", "bhl"
          provide "writer_class_name", "Traject::ArrayWriter"
        end
        i.load_config_file(Rails.root.join("lib/um_arclight/traject/ead2_config.rb"))
      end
      @dual_result = indexer.map_record(record)
    end

    let(:dual_result) { @dual_result }

    context "dual fields in the DIRECT location (ARC-190 / ARC-193)" do
      it "indexes relatedmaterial_tesim from directly under archdesc" do
        expect(dual_result["relatedmaterial_tesim"].join(" ")).to include "DIRECT related material text."
      end

      it "indexes separatedmaterial_tesim from directly under archdesc" do
        expect(dual_result["separatedmaterial_tesim"].join(" ")).to include "DIRECT separated material text."
      end

      it "indexes accessrestrict_tesim from directly under archdesc" do
        expect(dual_result["accessrestrict_tesim"].join(" ")).to include "DIRECT access restriction text."
      end

      it "indexes prefercite_tesim from directly under archdesc" do
        expect(dual_result["prefercite_tesim"].join(" ")).to include "DIRECT preferred citation text."
      end
    end

    context "descgrp-only fields" do
      it "indexes altformavail_tesim from descgrp" do
        expect(dual_result["altformavail_tesim"].join(" ")).to include "DESCGRP alternative form text."
      end

      it "indexes bibliography_tesim from descgrp" do
        expect(dual_result["bibliography_tesim"].join(" ")).to include "DESCGRP bibliography text."
      end

      it "indexes custodhist_tesim from descgrp" do
        expect(dual_result["custodhist_tesim"].join(" ")).to include "DESCGRP custodial history text."
      end

      it "indexes userestrict_tesim from descgrp" do
        expect(dual_result["userestrict_tesim"].join(" ")).to include "DESCGRP use restriction text."
      end
    end

    context "no double-counting and preserved special cases" do
      it "does not duplicate single-location data (accessrestrict appears once)" do
        expect(dual_result["accessrestrict_tesim"].length).to eq 1
      end

      it "maps heading fields for normal note fields" do
        expect(dual_result["relatedmaterial_heading_ssm"]).to include "Related Material"
      end

      it "suppresses prefercite_heading_ssm" do
        expect(dual_result["prefercite_heading_ssm"]).to be_nil
      end
    end
  end

  describe "searchable notes nested in descgrp[@type='admin'] (SCRC)" do
    before(:context) do
      fixture_path = Rails.root.join("spec/fixtures/scrc/umich-scl-asis.xml")
      record = File.open(fixture_path, "r:UTF-8:UTF-8") do |file|
        CompressedReader.new(file, {}).first
      end
      indexer = Traject::Indexer::NokogiriIndexer.new.tap do |i|
        i.settings do
          provide "repository", "scrc"
          provide "writer_class_name", "Traject::ArrayWriter"
        end
        i.load_config_file(Rails.root.join("lib/um_arclight/traject/ead2_config.rb"))
      end
      @scrc_result = indexer.map_record(record)
    end

    let(:scrc_result) { @scrc_result }

    it "maps relatedmaterial_html_tesm from descgrp[@type='admin']/relatedmaterial" do
      expect(scrc_result["relatedmaterial_html_tesm"].join).to include "Cloyd Dake Gull Papers"
    end

    it "maps relatedmaterial_tesim from descgrp[@type='admin']/relatedmaterial" do
      expect(scrc_result["relatedmaterial_tesim"].join).to include "Cloyd Dake Gull Papers"
    end

    it "maps relatedmaterial_heading_ssm from descgrp[@type='admin']/relatedmaterial/head" do
      expect(scrc_result["relatedmaterial_heading_ssm"]).to eq [ "Related Material" ]
    end

    it "maps separatedmaterial_html_tesm from descgrp[@type='admin']/separatedmaterial" do
      expect(scrc_result["separatedmaterial_html_tesm"].join).to include "cataloged separately"
    end

    it "maps separatedmaterial_tesim from descgrp[@type='admin']/separatedmaterial" do
      expect(scrc_result["separatedmaterial_tesim"].join).to include "cataloged separately"
    end

    it "still maps notes placed directly under archdesc" do
      expect(scrc_result["bioghist_tesim"]).not_to be_empty
      expect(scrc_result["scopecontent_tesim"]).not_to be_empty
    end
  end
end

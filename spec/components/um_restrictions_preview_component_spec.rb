# frozen_string_literal: true

require "rails_helper"

RSpec.describe UmRestrictionsPreviewComponent, type: :component do
  include ViewComponent::TestHelpers

  def document(attrs = {})
    SolrDocument.new({ "id" => "x" }.merge(attrs))
  end

  describe "#render?" do
    it "renders when the component has its own accessrestrict" do
      doc = document("accessrestrict_html_tesm" => [ "<p>Restricted</p>" ])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "renders when the component has only its own userestrict" do
      doc = document("userestrict_html_tesm" => [ "<p>Reading room only</p>" ])
      expect(described_class.new(document: doc).render?).to be true
    end

    it "does not render when neither restriction nor terms is present" do
      expect(described_class.new(document: document).render?).to be false
    end

    it "does not render for a document with children" do
      doc = document(
        "userestrict_html_tesm" => [ "<p>Reading room only</p>" ],
        "child_component_count_isi" => 3
      )
      expect(described_class.new(document: doc).render?).to be false
    end
  end

  describe "rendered output" do
    it "shows the Use & Permissions section from the component's own userestrict" do
      doc = document("userestrict_html_tesm" => [ "<p>Access is restricted to the reading room.</p>" ])
      render_inline(described_class.new(document: doc))

      expect(page).to have_css("dt.blacklight-terms", text: "Use & Permissions")
      expect(page).to have_css("dd.blacklight-terms", text: "Access is restricted to the reading room.")
      expect(page).not_to have_css("dt.blacklight-restrictions")
    end

    it "shows both the Restrictions and Use & Permissions sections when both are present" do
      doc = document(
        "accessrestrict_html_tesm" => [ "<p>Open for research.</p>" ],
        "userestrict_html_tesm" => [ "<p>Copyright held by the Regents.</p>" ]
      )
      render_inline(described_class.new(document: doc))

      expect(page).to have_css("dt.blacklight-restrictions", text: "Restrictions")
      expect(page).to have_css("dd.blacklight-restrictions", text: "Open for research.")
      expect(page).to have_css("dt.blacklight-terms", text: "Use & Permissions")
      expect(page).to have_css("dd.blacklight-terms", text: "Copyright held by the Regents.")
    end
  end
end

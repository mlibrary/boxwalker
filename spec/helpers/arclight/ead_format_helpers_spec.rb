# frozen_string_literal: true

require "rails_helper"

# Covers the UM customization in
# config/initializers/arclight_ead_format_href.rb, which restores hyperlinking
# of href-bearing EAD elements (notably <title href>) that stock Arclight drops.
RSpec.describe Arclight::EadFormatHelpers, type: :helper do
  describe "#render_html_tags" do
    it "renders <title href> as an external anchor (ARC-190 regression)" do
      value = '<p>The University of Kentucky holds digitized ' \
              '<title href="https://kentuckyoralhistory.org/catalog/xt77h41jkz2v">' \
              "Interview A</title> and " \
              '<title href="https://kentuckyoralhistory.org/catalog/xt73r20rtp92">' \
              "Interview B</title></p>"

      html = helper.render_html_tags(value: value)

      expect(html).to include('<a href="https://kentuckyoralhistory.org/catalog/xt77h41jkz2v"')
      expect(html).to include('<a href="https://kentuckyoralhistory.org/catalog/xt73r20rtp92"')
      expect(html).to include('class="external-link"')
      expect(html).to include('target="_blank"')
      expect(html).to include(">Interview A</a>")
      expect(html).to include(">Interview B</a>")
      # Links must not leak through as raw <title> tags anymore.
      expect(html).not_to include("<title")
    end

    it "still renders a bare <title> (no href) as a span, not a link" do
      html = helper.render_html_tags(value: "<p>See <title>Some Work</title></p>")

      expect(html).to include("<span>Some Work</span>")
      expect(html).not_to include("<a ")
    end

    it "still hyperlinks stock EAD link elements like <extref>" do
      value = '<p>See <extref href="https://example.org/x">Example</extref></p>'

      html = helper.render_html_tags(value: value)

      expect(html).to include('<a href="https://example.org/x"')
      expect(html).to include('class="external-link"')
      expect(html).to include(">Example</a>")
    end
  end
end

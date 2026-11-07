# frozen_string_literal: true

require "rails_helper"

RSpec.describe UmDocumentDownloadComponent, type: :component do
  include ViewComponent::TestHelpers

  def download_file(type, href)
    Arclight::DocumentDownloads::File.new(type: type, data: { "href" => href }, document: nil)
  end

  let(:downloads) do
    instance_double(
      Arclight::DocumentDownloads,
      files: [
        download_file("pdf", "/catalog/abc/pdf"),
        download_file("ead", "/catalog/abc/xml")
      ]
    )
  end

  before { render_inline(described_class.new(downloads: downloads)) }

  it "labels the dropdown items with their file formats" do
    expect(page).to have_link("Finding aid (PDF)", href: "/catalog/abc/pdf")
    expect(page).to have_link("EAD (XML)", href: "/catalog/abc/xml")
  end

  it "gives the PDF icon an accessible name" do
    expect(page).to have_css('a[href="/catalog/abc/pdf"] svg.bi-file-earmark-pdf[role="img"][aria-label="PDF"]')
  end

  it "gives the EAD icon an accessible name" do
    expect(page).to have_css('a[href="/catalog/abc/xml"] svg.bi-file-earmark-code[role="img"][aria-label="XML"]')
  end
end

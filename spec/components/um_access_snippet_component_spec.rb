# frozen_string_literal: true

require "rails_helper"

RSpec.describe UmAccessSnippetComponent, type: :component do
  include ViewComponent::TestHelpers

  it "links directly to the access section without a Turbo visit" do
    document = SolrDocument.new("id" => "x", "accessrestrict_html_tesm" => [ "<p>Open for research.</p>" ])
    presenter = Arclight::ShowPresenter.new(document, vc_test_controller.view_context, CatalogController.blacklight_config)
    component = described_class.new(document: presenter)
    allow(component).to receive(:materials_access).and_return("")

    render_inline(component)

    expect(page).to have_css('a[href="#using-these-materials"][data-turbo="false"]', text: "More ...")
  end
end

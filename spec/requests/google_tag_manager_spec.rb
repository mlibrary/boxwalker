# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Google Tag Manager", type: :request do
  let(:empty_response) do
    Blacklight::Solr::Response.new({ response: { numFound: 0, start: 0, docs: [] } }, {}, blacklight_config: CatalogController.blacklight_config)
  end

  before do
    # CI specs run without built CSS or Solr, which the search page depends on
    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(empty_response)
  end

  it "renders both snippets when the id is set" do
    allow(Rails.configuration.settings).to receive(:google_tag_manager_id).and_return("GTM-TEST000")

    get "/catalog"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("'dataLayer','GTM-TEST000'")
    expect(response.body).to include("ns.html?id=GTM-TEST000")
  end

  it "renders neither snippet when the id is blank" do
    allow(Rails.configuration.settings).to receive(:google_tag_manager_id).and_return("")

    get "/catalog"

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("googletagmanager.com")
  end
end

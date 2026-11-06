# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search session persistence", type: :request do
  let(:empty_response) do
    Blacklight::Solr::Response.new(
      { response: { numFound: 0, start: 0, docs: [] } },
      {},
      blacklight_config: CatalogController.blacklight_config
    )
  end

  before do
    allow_any_instance_of(ActionView::Base).to receive(:stylesheet_link_tag).and_return("")
    allow_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(empty_response)
  end

  it "does not save a submitted search to the searches table" do
    expect {
      get "/catalog", params: { q: "archives" }
    }.not_to change(Search, :count)

    expect(response).to have_http_status(:ok)
  end
end

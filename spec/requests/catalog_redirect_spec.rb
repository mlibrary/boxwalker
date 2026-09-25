# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Catalog redirects", type: :request do
  it "permanently redirects a former id to its final current id" do
    stub_const("REDIRECT_MAP", {
      "former.id" => "renamed.id",
      "renamed.id" => "current.id"
    }.freeze)

    get "/catalog/former.id"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id")
  end

  it "redirects an intermediate id directly to the final current id" do
    stub_const("REDIRECT_MAP", {
      "former.id" => "renamed.id",
      "renamed.id" => "current.id"
    }.freeze)

    get "/catalog/renamed.id"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id")
  end

  it "matches former ids case-insensitively" do
    stub_const("REDIRECT_MAP", { "former.id" => "current.id" }.freeze)

    get "/catalog/FORMER.ID"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id")
  end
end

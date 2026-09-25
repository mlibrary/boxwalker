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

  it "preserves query parameters" do
    stub_const("REDIRECT_MAP", { "former.id" => "current.id" }.freeze)

    get "/catalog/former.id", params: { search_id: "123" }

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id?search_id=123")
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

  it "redirects a mixed-case current id to its lowercase canonical id" do
    stub_const("REDIRECT_MAP", {}.freeze)

    get "/catalog/Current.ID"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id")
  end

  it "canonicalizes ids on download routes" do
    stub_const("REDIRECT_MAP", { "former.id" => "current.id" }.freeze)

    get "/catalog/FORMER.ID/xml"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq("http://www.example.com/catalog/current.id/xml")
  end

  it "canonicalizes ids on hierarchy routes" do
    stub_const("REDIRECT_MAP", { "former.id" => "current.id" }.freeze)

    get "/catalog/FORMER.ID/hierarchy", params: { hierarchy: "true" }

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq(
      "http://www.example.com/catalog/current.id/hierarchy?hierarchy=true"
    )
  end

  it "permanently redirects a component when its finding aid id changed" do
    stub_const("REDIRECT_MAP", {
      "former-root" => "renamed.root",
      "renamed.root" => "current.root"
    }.freeze)

    get "/catalog/former-root_aspace_123"

    expect(response).to have_http_status(:moved_permanently)
    expect(response.location).to eq(
      "http://www.example.com/catalog/current.root_aspace_123"
    )
  end
end

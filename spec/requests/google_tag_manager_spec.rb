# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Google Tag Manager", type: :request do
  it "renders both snippets when the id is set" do
    allow(Rails.configuration.settings).to receive(:google_tag_manager_id).and_return("GTM-TEST000")

    get "/users/sign_in"

    expect(response.body).to include("'dataLayer','GTM-TEST000'")
    expect(response.body).to include("ns.html?id=GTM-TEST000")
  end

  it "renders neither snippet when the id is blank" do
    allow(Rails.configuration.settings).to receive(:google_tag_manager_id).and_return("")

    get "/users/sign_in"

    expect(response.body).not_to include("googletagmanager.com")
  end
end

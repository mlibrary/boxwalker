# frozen_string_literal: true

require "rails_helper"
require_relative "../../config/redirect_map"

RSpec.describe "catalog routing", type: :routing do
  it "routes a mapped id containing punctuation to the redirect action" do
    old_id = REDIRECT_MAP.keys.first

    expect(get: "/catalog/#{old_id}").to route_to(
      controller: "catalog",
      action: "permanent_id_redirect",
      id: old_id
    )
  end

  it "routes an unmapped dotted id to the normal show action" do
    expect(get: "/catalog/current.finding-aid").to route_to(
      controller: "catalog",
      action: "show",
      id: "current.finding-aid"
    )
  end

  it "routes an unmapped mixed-case id to the redirect action" do
    expect(get: "/catalog/Current.Finding-Aid").to route_to(
      controller: "catalog",
      action: "permanent_id_redirect",
      id: "Current.Finding-Aid"
    )
  end
end

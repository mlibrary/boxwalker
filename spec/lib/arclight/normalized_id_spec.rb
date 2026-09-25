# frozen_string_literal: true

require "rails_helper"

RSpec.describe Arclight::NormalizedId do
  it "preserves dots and canonicalizes case" do
    normalized_id = described_class.new(
      "  Umich-WCL-F-103.1dub  ",
      unitid: "unused",
      title: "unused",
      repository: "unused"
    )

    expect(normalized_id.to_s).to eq("umich-wcl-f-103.1dub")
  end

  it "rejects a blank id" do
    expect { described_class.new(nil).to_s }
      .to raise_error(Arclight::Exceptions::IDNotFound)
  end
end

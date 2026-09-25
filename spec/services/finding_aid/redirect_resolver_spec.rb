# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindingAid::RedirectResolver do
  subject(:resolver) { described_class.new(redirect_map: redirect_map) }

  context "when the id has been renamed multiple times" do
    let(:redirect_map) { { "A" => "B", "B" => "C", "C" => "D" } }

    it "resolves every former id directly to the current id" do
      expect(resolver.resolve("A")).to eq("D")
      expect(resolver.resolve("B")).to eq("D")
      expect(resolver.resolve("C")).to eq("D")
    end

    it "does not redirect the current id" do
      expect(resolver.resolve("D")).to be_nil
    end
  end

  context "when the ids contain dots" do
    let(:redirect_map) { { "A.1" => "B.2", "B.2" => "C.3" } }

    it "preserves the ids exactly" do
      expect(resolver.resolve("A.1")).to eq("C.3")
    end
  end

  context "when the map contains a cycle" do
    let(:redirect_map) { { "A" => "B", "B" => "C", "C" => "A" } }

    it "raises an error containing the cycle" do
      expect { resolver.resolve("A") }
        .to raise_error(described_class::CycleError, "Redirect cycle detected: A -> B -> C -> A")
    end
  end
end

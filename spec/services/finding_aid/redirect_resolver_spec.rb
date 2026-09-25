# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindingAid::RedirectResolver do
  subject(:resolver) { described_class.new(redirect_map: redirect_map) }

  context "when the id has been renamed multiple times" do
    let(:redirect_map) { { "a" => "b", "b" => "c", "c" => "d" } }

    it "resolves every former id directly to the current id" do
      expect(resolver.resolve("a")).to eq("d")
      expect(resolver.resolve("b")).to eq("d")
      expect(resolver.resolve("c")).to eq("d")
    end

    it "does not redirect the current id" do
      expect(resolver.resolve("d")).to be_nil
    end
  end

  context "when the ids contain dots" do
    let(:redirect_map) { { "a.1" => "b.2", "b.2" => "c.3" } }

    it "preserves the ids exactly" do
      expect(resolver.resolve("a.1")).to eq("c.3")
    end

    it "looks up ids case-insensitively" do
      expect(resolver.resolve("A.1")).to eq("c.3")
    end
  end

  context "when the map contains a cycle" do
    let(:redirect_map) { { "a" => "b", "b" => "c", "c" => "a" } }

    it "raises an error containing the cycle" do
      expect { resolver.resolve("a") }
        .to raise_error(described_class::CycleError, "Redirect cycle detected: a -> b -> c -> a")
    end
  end
end

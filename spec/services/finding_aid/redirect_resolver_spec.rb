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

    it "returns the current id unchanged" do
      expect(resolver.resolve("d")).to eq("d")
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

  context "when the id has not been renamed" do
    let(:redirect_map) { {} }

    it "canonicalizes its case" do
      expect(resolver.resolve("Current.ID")).to eq("current.id")
    end

    it "only redirects noncanonical ids" do
      expect(resolver).to be_redirect("Current.ID")
      expect(resolver).not_to be_redirect("current.id")
    end
  end

  context "when the map contains a cycle" do
    let(:redirect_map) { { "a" => "b", "b" => "c", "c" => "a" } }

    it "raises an error containing the cycle" do
      expect { resolver.resolve("a") }
        .to raise_error(described_class::CycleError, "Redirect cycle detected: a -> b -> c -> a")
    end
  end

  context "when a target is not lowercase" do
    let(:redirect_map) { { "former.id" => " Current.ID " } }

    it "returns a stripped, lowercase canonical target" do
      expect(resolver.resolve(" Former.ID ")).to eq("current.id")
    end
  end

  context "when the id belongs to a component" do
    let(:redirect_map) do
      {
        "former-root" => "renamed.root",
        "renamed.root" => "current.root"
      }
    end

    it "replaces the former root and preserves the component suffix" do
      expect(resolver.resolve("former-root_aspace_123"))
        .to eq("current.root_aspace_123")
    end

    it "resolves an intermediate root directly to the current root" do
      expect(resolver.resolve("renamed.root_aspace_123"))
        .to eq("current.root_aspace_123")
    end

    it "looks up the root case-insensitively" do
      expect(resolver.resolve("FORMER-ROOT_ASPACE_123"))
        .to eq("current.root_aspace_123")
    end

    it "leaves a component with a current root unchanged" do
      expect(resolver.resolve("current.root_aspace_123"))
        .to eq("current.root_aspace_123")
    end
  end

  context "when redirect roots share a prefix" do
    let(:redirect_map) do
      {
        "former" => "wrong.root",
        "former_root" => "current.root"
      }
    end

    it "uses the longest matching root" do
      expect(resolver.resolve("former_root_aspace_123"))
        .to eq("current.root_aspace_123")
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require_relative '../../config/redirect_map'

RSpec.describe 'REDIRECT_MAP' do
  it "contains only lowercase ids" do
    mixed_case_ids = REDIRECT_MAP.flat_map do |source_id, target_id|
      [ source_id, target_id ].reject { |id| id == id.downcase }
    end

    expect(mixed_case_ids).to be_empty
  end

  it 'does not contain redirect cycles' do
    resolver = FindingAid::RedirectResolver.new(redirect_map: REDIRECT_MAP)

    expect { REDIRECT_MAP.each_key { |id| resolver.resolve(id) } }.not_to raise_error
  end
end

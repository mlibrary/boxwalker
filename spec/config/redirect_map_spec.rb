# frozen_string_literal: true

require 'rails_helper'
require_relative '../../config/redirect_map'

RSpec.describe 'REDIRECT_MAP' do
  it 'does not contain redirect cycles' do
    resolver = FindingAid::RedirectResolver.new(redirect_map: REDIRECT_MAP)

    expect { REDIRECT_MAP.each_key { |id| resolver.resolve(id) } }.not_to raise_error
  end
end

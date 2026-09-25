# frozen_string_literal: true

require 'rails_helper'
require_relative '../../config/redirect_map'

RSpec.describe 'REDIRECT_MAP' do
  it 'does not contain redirect cycles' do
    cycles = REDIRECT_MAP.each_key.filter_map do |starting_id|
      path = []
      position_by_id = {}
      current_id = starting_id

      while REDIRECT_MAP.key?(current_id)
        if position_by_id.key?(current_id)
          cycle_start = position_by_id.fetch(current_id)
          break path.drop(cycle_start) + [ current_id ]
        end

        position_by_id[current_id] = path.length
        path << current_id
        current_id = REDIRECT_MAP.fetch(current_id)
      end
    end

    expect(cycles).to be_empty, lambda {
      formatted_cycles = cycles.map { |cycle| cycle.join(' -> ') }.uniq.join("\n")
      "Expected REDIRECT_MAP to contain no cycles, but found:\n#{formatted_cycles}"
    }
  end
end

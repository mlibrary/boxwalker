# frozen_string_literal: true

module FindingAid
  class RedirectResolver
    class CycleError < StandardError; end

    def initialize(redirect_map:)
      @redirect_map = redirect_map
    end

    def resolve(id)
      current_id = normalize(id)
      path = []
      position_by_id = {}

      while redirect_map.key?(current_id)
        if position_by_id.key?(current_id)
          cycle = path.drop(position_by_id.fetch(current_id)) + [ current_id ]
          raise CycleError, "Redirect cycle detected: #{cycle.join(' -> ')}"
        end

        position_by_id[current_id] = path.length
        path << current_id
        current_id = normalize(redirect_map.fetch(current_id))
      end

      current_id
    end

    def redirect?(id)
      resolve(id) != id
    end

    private

    attr_reader :redirect_map

    def normalize(id)
      UmArclight::NormalizedId.new(id).to_s
    end
  end
end

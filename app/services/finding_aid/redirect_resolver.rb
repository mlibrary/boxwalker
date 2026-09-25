# frozen_string_literal: true

module FindingAid
  class RedirectResolver
    class CycleError < StandardError; end

    def initialize(redirect_map:)
      @redirect_map = redirect_map
    end

    def resolve(id)
      current_id = normalize(id)
      return resolve_chain(current_id) if redirect_map.key?(current_id)

      source_root = matching_source_root(current_id)
      return current_id unless source_root

      current_id.sub(/\A#{Regexp.escape(source_root)}/, resolve_chain(source_root))
    end

    def redirect?(id)
      resolve(id) != id
    end

    private

    attr_reader :redirect_map

    def matching_source_root(id)
      redirect_map.each_key
                  .select { |source_id| id.start_with?("#{source_id}_") }
                  .max_by(&:length)
    end

    def resolve_chain(id)
      current_id = id
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

    def normalize(id)
      UmArclight::NormalizedId.new(id).to_s
    end
  end
end

# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "arclight/exceptions"

module UmArclight
  class NormalizedId
    def initialize(id, **_kwargs)
      @id = id
    end

    def to_s
      raise Arclight::Exceptions::IDNotFound if id.blank?

      id.strip.downcase
    end

    private

    attr_reader :id
  end
end

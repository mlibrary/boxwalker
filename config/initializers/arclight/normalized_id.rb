# frozen_string_literal: true

module Arclight
  class NormalizedId
    def initialize(id, **_kwargs)
      @id = id
    end

    def to_s
      raise Arclight::Exceptions::IDNotFound if id.blank?

      id.strip
    end

    private

    attr_reader :id
  end
end

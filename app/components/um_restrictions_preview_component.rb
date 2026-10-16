# frozen_string_literal: true

class UmRestrictionsPreviewComponent < ViewComponent::Base
  delegate :restrictions, :terms, to: :document

  def initialize(document:)
    @document = document
  end

  def render?
    (restrictions.present? || terms.present?) && !document.children?
  end

  attr_reader :document
end

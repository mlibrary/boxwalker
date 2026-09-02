# frozen_string_literal: true

class UmRestrictionsPreviewComponent < ViewComponent::Base
  delegate :restrictions, to: :document

  def initialize(document:)
    @document = document
  end

  def render?
    restrictions.present? && !document.children?
  end

  attr_reader :document
end
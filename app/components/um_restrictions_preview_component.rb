# frozen_string_literal: true

class UmRestrictionsPreviewComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  def render?
    restrictions.present?
  end

  def restrictions
    @document.restrictions
  end
end

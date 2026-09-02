# frozen_string_literal: true

class UmAeonRequestCheckboxComponent < ViewComponent::Base
  def initialize(document:, label: nil)
    @document = document
    @label = label
  end
  attr_reader :document, :label
end

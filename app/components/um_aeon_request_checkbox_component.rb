# frozen_string_literal: true

class UmAeonRequestCheckboxComponent < ViewComponent::Base
  def initialize(document:, label: "Request")
    @document = document
    @label = label
  end

  attr_reader :document, :label
end

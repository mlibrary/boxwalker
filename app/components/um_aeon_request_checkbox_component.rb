# frozen_string_literal: true

class UmAeonRequestCheckboxComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  attr_reader :document
end

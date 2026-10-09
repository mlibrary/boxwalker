# frozen_string_literal: true

class UmBlacklightSearchBarComponent < Blacklight::SearchBarComponent
  # Searches submitted from the form always start "Grouped by collection".
  # Browse links (e.g. repository pages) don't use this form, so they're unaffected.
  def initialize(params: {}, **kwargs)
    super(params: params.merge("group" => "true"), **kwargs)
  end
end
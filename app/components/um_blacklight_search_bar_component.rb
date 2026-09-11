# frozen_string_literal: true

class UmBlacklightSearchBarComponent < Blacklight::SearchBarComponent
  def advanced_search_enabled?
    false
  end
end

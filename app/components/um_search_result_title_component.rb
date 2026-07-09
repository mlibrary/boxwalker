# frozen_string_literal: true

class UmSearchResultTitleComponent < Arclight::SearchResultTitleComponent
  def actions
    return [] unless @actions

    if block_given?
      @has_actions_slot = true
      return super
    end

    # Keep explicit slot/document_component actions, but skip Blacklight fallback
    (@has_actions_slot && get_slot(:actions)) ||
      ([ @document_component&.actions ] if @document_component&.actions.present?) ||
      []
  end
end

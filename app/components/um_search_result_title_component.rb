# frozen_string_literal: true

class UmSearchResultTitleComponent < Arclight::SearchResultTitleComponent
  def actions
    return [] unless @actions

    if block_given?
      @has_actions_slot = true
      return super
    end

    (@has_actions_slot && get_slot(:actions)) ||
      ([@document_component&.actions] if @document_component&.actions.present?) ||
      [helpers.render_index_doc_actions(presenter.document, wrapping_class: nil)]
  end
end

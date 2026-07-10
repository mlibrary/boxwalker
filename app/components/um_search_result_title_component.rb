# frozen_string_literal: true

class UmSearchResultTitleComponent < Arclight::SearchResultTitleComponent
  def title_col_class
    if presenter.document.containers.blank?
      "col-md-11 col-sm-10 col-10"
    else
      "col-md-8 col-sm-8 col-8"
    end
  end

  def actions
    return [] unless @actions
    if block_given?
      @has_actions_slot = true
      return
    end

    (@has_actions_slot && get_slot(:actions)) ||
      ([ @document_component&.actions ] if @document_component&.actions.present?) ||
      [ helpers.render_index_doc_actions(presenter.document, wrapping_class: "actions-wrapping-class col-md-1 col-sm-1 col-1") ]
  end
end

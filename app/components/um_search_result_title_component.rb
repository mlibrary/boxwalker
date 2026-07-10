# frozen_string_literal: true

class UmSearchResultTitleComponent < Arclight::SearchResultTitleComponent
  def title_col_class
    if presenter.document.containers.present? && actions.present?
      "col-md-8"
    elsif presenter.document.containers.present? && actions.blank?
      "col-md-10"
    elsif presenter.document.containers.blank? && actions.present?
      "col-md-11"
    else
      "col"
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
    [ helpers.render_index_doc_actions(presenter.document, wrapping_class: "actions-wrapping-class col-md-1") ]
  end
end

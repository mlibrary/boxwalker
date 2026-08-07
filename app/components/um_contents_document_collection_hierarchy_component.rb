# frozen_string_literal: true

class UmContentsDocumentCollectionHierarchyComponent < Arclight::DocumentCollectionHierarchyComponent
  def abstract_or_scope
    field = if document.abstract
      "abstract_html_tesm"
    elsif document.scope
      "scopecontent_html_tesm"
    else
      nil
    end
    return unless field

    render Arclight::IndexMetadataFieldComponent.new(
      field: Blacklight::FieldPresenter.new(
        view_context,
        document,
        Blacklight::Configuration::Field.new(
          field: field, key: "abstract_or_scope", truncate: true, helper_method: :render_html_tags
        )
      )
    )
  end
end

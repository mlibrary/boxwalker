# frozen_string_literal: true

class UmContentsDocumentCollectionHierarchyComponent < Arclight::DocumentCollectionHierarchyComponent
  def abstract_or_scope
    render Arclight::IndexMetadataFieldComponent.new(
      field: Blacklight::FieldPresenter.new(
        view_context,
        document,
        Blacklight::Configuration::Field.new(
          field: "abstract_or_scope",
          key: "abstract_or_scope",
          accessor: true,
          truncate: true,
          helper_method: :render_html_tags
        )
      )
    )
  end
end

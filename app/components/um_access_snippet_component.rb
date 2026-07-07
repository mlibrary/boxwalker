class UmAccessSnippetComponent < Arclight::DocumentComponent

  def materials_access
    render UmMaterialsAccessComponent.new(document: document)
  end

  def restrictions_field
    field_config = helpers.blacklight_config.terms_fields["restrictions"]
    render Blacklight::MetadataFieldComponent.new(
      field: Blacklight::FieldPresenter.new(helpers, document, field_config), show: true)
  end
end

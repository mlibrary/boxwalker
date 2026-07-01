class UmDocumentComponent < Arclight::DocumentComponent

  def digital_materials_filter
    render UmDigitalMaterialsFilterComponent.new(document: @document)
  end
end

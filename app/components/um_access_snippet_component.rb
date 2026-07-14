class UmAccessSnippetComponent < Arclight::DocumentComponent
  def materials_access
    render UmMaterialsAccessComponent.new(document: document, small_button: true)
  end

  def restrictions_value
    @document.restrictions
  end
end

class UmMaterialsAccessComponent < ViewComponent::Base
  def initialize(document:, small_button: false)
    @document = document
    @small_button = small_button
  end

  def button_class
    button_base = "btn btn-primary pdf-download-button"
    button_base += " btn-sm" if @small_button
    button_base
  end

  def repository
    @document.repository_config
  end
end

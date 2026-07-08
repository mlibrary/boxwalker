class UmMaterialsAccessComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  def repository
    @document.repository_config
  end
end

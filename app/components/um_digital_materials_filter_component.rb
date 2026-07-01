class UmDigitalMaterialsFilterComponent < Blacklight::Component
  attr_accessor :document

  def initialize(document:)
    @document = document
    super()
  end
end

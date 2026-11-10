# frozen_string_literal: true

class UmCollapsibleHierarchyComponent < Blacklight::Component
  def initialize(presenters:, blacklight_config:, nest_path:, frame_key:, collapsible: false)
    super()
    @presenters = presenters
    @blacklight_config = blacklight_config
    @nest_path = nest_path
    @frame_key = frame_key
    @collapsible = collapsible
  end

  def collapsible?
    @collapsible
  end

  def list_id
    "al-hierarchy-collapse-#{@frame_key}"
  end

  def list_classes
    [ "documents", ("collapse show" if collapsible?) ].compact.join(" ")
  end

  def hierarchy_collection
    UmDocumentCollectionHierarchyComponent.with_collection(
      @presenters,
      blacklight_config: @blacklight_config,
      nest_path: @nest_path
    )
  end
end

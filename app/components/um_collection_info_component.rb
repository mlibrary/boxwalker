# frozen_string_literal: true

class UmCollectionInfoComponent < Arclight::CollectionInfoComponent
  delegate :total_component_count, :online_item_count, :last_indexed, :collection_unitid, to: :collection
  delegate :blacklight_icon, to: :helpers

  def info_icon
    content_tag(:i, "", class: "bi bi-info-circle-fill")
  end
end

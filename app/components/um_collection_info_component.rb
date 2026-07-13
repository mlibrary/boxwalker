# frozen_string_literal: true

class UmCollectionInfoComponent < Arclight::CollectionInfoComponent
  def info_icon
    content_tag(:i, "", class: "bi bi-info-circle-fill")
  end
end
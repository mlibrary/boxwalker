# frozen_string_literal: true

class UmBreadcrumbsHierarchyComponent < Arclight::BreadcrumbsHierarchyComponent
  def render?
    document.present? && !document.collection?
  end
end

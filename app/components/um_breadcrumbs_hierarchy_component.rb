# frozen_string_literal: true

class UmBreadcrumbsHierarchyComponent < Arclight::BreadcrumbsHierarchyComponent
    def render?
      collection.present?
    end
  end

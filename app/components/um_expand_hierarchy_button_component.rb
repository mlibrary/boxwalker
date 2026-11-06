# frozen_string_literal: true

class UmExpandHierarchyButtonComponent < Arclight::ExpandHierarchyButtonComponent
  def expand_link
    link_to t("arclight.views.show.expand"), collapsible_path, class: @classes
  end

  private

  def collapsible_path
    separator = @path.include?("?") ? "&" : "?"
    "#{@path}#{separator}collapsible=true"
  end
end
